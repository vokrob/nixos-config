import type { Plugin } from "@opencode-ai/plugin"

/**
 * Concurrency limiter + retry for the B.AI provider.
 *
 * opencode fires many parallel requests (main agent stream, background
 * title/summary tasks, subagents) against one API key. Upstream api.b.ai
 * enforces a per-key concurrency limit and rejects the excess with
 * "The request rate exceeds the current model Concurrency limit ...".
 *
 * This plugin:
 *   1. queues outgoing requests so no more than MAX_CONCURRENT hit api.b.ai
 *      at the same time (excess requests wait in a FIFO queue instead of
 *      being rejected by the provider);
 *   2. retries throttled responses (429 / "Concurrency limit" / rate limit
 *      messages) with exponential backoff + jitter, honoring Retry-After.
 *
 * Tuning via env vars (optional):
 *   OPENCODE_BAI_MAX_CONCURRENT  max simultaneous requests, default 3
 *   OPENCODE_BAI_MAX_RETRIES     attempts per request, default 8
 */

const MATCH_BASEURL = /api\.b\.ai/i

const MAX_CONCURRENT = positiveInt("OPENCODE_BAI_MAX_CONCURRENT") ?? 3
const MAX_RETRIES = positiveInt("OPENCODE_BAI_MAX_RETRIES") ?? 8
const INITIAL_DELAY_MS = 2000
const MAX_DELAY_MS = 45_000

const RETRYABLE_STATUS = new Set([429, 500, 502, 503, 504])
const RETRYABLE_MESSAGE =
  /concurrency limit|request rate exceeds|rate[- _]?limit|too many requests|overloaded|service unavailable|resource exhausted/i

function positiveInt(name: string): number | undefined {
  const raw = process.env[name]
  if (!raw) return undefined
  const value = Number.parseInt(raw, 10)
  return Number.isFinite(value) && value > 0 ? value : undefined
}

function abortError() {
  return new DOMException("Aborted", "AbortError")
}

// --- semaphore -------------------------------------------------------------

let active = 0
type Waiter = { resolve: () => void; onAbort: () => void }
const waiters: Waiter[] = []

function acquire(signal?: AbortSignal): Promise<void> {
  if (signal?.aborted) return Promise.reject(abortError())
  return new Promise((resolve, reject) => {
    if (active < MAX_CONCURRENT && waiters.length === 0) {
      active++
      resolve()
      return
    }
    const entry = {} as Waiter
    entry.onAbort = () => {
      const index = waiters.indexOf(entry)
      if (index === -1) return
      waiters.splice(index, 1)
      signal?.removeEventListener("abort", entry.onAbort)
      reject(abortError())
    }
    entry.resolve = () => {
      signal?.removeEventListener("abort", entry.onAbort)
      resolve()
    }
    signal?.addEventListener("abort", entry.onAbort, { once: true })
    waiters.push(entry)
  })
}

function release() {
  const next = waiters.shift()
  if (next) {
    next.resolve() // hand the slot over; active count stays the same
    return
  }
  active--
}

// --- helpers ---------------------------------------------------------------

/** Returns a Response whose body releases the semaphore slot when consumed. */
function tracked(res: Response, done: () => void): Response {
  if (!res.body) {
    done()
    return res
  }
  let released = false
  const releaseOnce = () => {
    if (released) return
    released = true
    done()
  }
  const reader = res.body.getReader()
  const stream = new ReadableStream<Uint8Array>({
    async pull(controller) {
      try {
        const { done: finished, value } = await reader.read()
        if (finished) {
          controller.close()
          releaseOnce()
          return
        }
        controller.enqueue(value)
      } catch (error) {
        releaseOnce()
        controller.error(error)
      }
    },
    async cancel(reason) {
      releaseOnce()
      try {
        await reader.cancel(reason)
      } catch {}
    },
  })
  return new Response(stream, {
    status: res.status,
    statusText: res.statusText,
    headers: res.headers,
  })
}

async function describe(res: Response): Promise<string> {
  try {
    const text = await res.clone().text()
    if (!text) return res.statusText
    try {
      const json = JSON.parse(text) as { error?: { message?: string }; message?: string }
      return String(json.error?.message ?? json.message ?? text)
    } catch {
      return text
    }
  } catch {
    return res.statusText
  }
}

function delay(attempt: number, res: Response): number {
  const ms = res.headers.get("retry-after-ms")
  if (ms) {
    const parsed = Number.parseFloat(ms)
    if (Number.isFinite(parsed) && parsed >= 0) return Math.min(parsed, MAX_DELAY_MS)
  }
  const seconds = res.headers.get("retry-after")
  if (seconds) {
    const parsed = Number.parseFloat(seconds)
    if (Number.isFinite(parsed) && parsed >= 0) return Math.min(parsed * 1000, MAX_DELAY_MS)
    const until = Date.parse(seconds) - Date.now()
    if (Number.isFinite(until) && until > 0) return Math.min(until, MAX_DELAY_MS)
  }
  const base = Math.min(INITIAL_DELAY_MS * 2 ** (attempt - 1), MAX_DELAY_MS)
  return Math.round(base * (0.75 + Math.random() * 0.5))
}

function sleep(ms: number, signal?: AbortSignal): Promise<void> {
  return new Promise((resolve, reject) => {
    if (signal?.aborted) {
      reject(abortError())
      return
    }
    const onAbort = () => {
      clearTimeout(timer)
      reject(abortError())
    }
    const timer = setTimeout(() => {
      signal?.removeEventListener("abort", onAbort)
      resolve()
    }, ms)
    signal?.addEventListener("abort", onAbort, { once: true })
  })
}

// --- limited fetch ---------------------------------------------------------

async function limitedFetch(input: RequestInfo | URL, init?: RequestInit): Promise<Response> {
  const signal = init?.signal
  for (let attempt = 1; ; attempt++) {
    await acquire(signal)
    let res: Response
    try {
      res = await fetch(input, init)
    } catch (error) {
      release()
      throw error
    }
    if (res.status < 400) return tracked(res, release)

    const message = await describe(res)
    const retryable = RETRYABLE_STATUS.has(res.status) || RETRYABLE_MESSAGE.test(message)
    if (!retryable || attempt >= MAX_RETRIES) {
      return tracked(res, release)
    }

    const wait = delay(attempt, res)
    release()
    await sleep(wait, signal)
  }
}

// --- plugin ----------------------------------------------------------------

export const RateLimitPlugin: Plugin = async () => {
  return {
    config: (config) => {
      for (const provider of Object.values(config.provider ?? {})) {
        const baseURL = provider.options?.baseURL
        if (typeof baseURL !== "string" || !MATCH_BASEURL.test(baseURL)) continue
        provider.options = provider.options ?? {}
        provider.options.fetch = limitedFetch
      }
    },
  }
}

export default RateLimitPlugin
