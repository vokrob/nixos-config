# Domains resolved through the COMSS relay DNS by dns-bypass.nix and routed
# directly around awg0 by vpn-split.nix. OpenRouter is not proxied by MagicDNS:
# its real Cloudflare addresses return 403 through WARP, while the COMSS relay
# works. Claude, Gemini, ChatGPT/OpenAI, Midjourney, Copilot, Xbox and
# PlayStation are handled by the scoped MagicDNS link instead.
[
  "openrouter.ai"
]
