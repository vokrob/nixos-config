{
  lib,
  pkgs,
  ...
}: let
  # The scoped link is still named magicdns, but the AI/gaming domains below
  # are now resolved through QUIC DNS (https://dns.quic.best/), which returns
  # SNI proxy addresses for the services it supports. Everything else keeps
  # the public resolvers from networking.nix.
  # de.magicdns.ru (94.249.177.102) became unusable: TCP/853 accepts
  # connections, but the DoT handshake times out. QUIC DNS publishes
  # 194.238.57.69 and serves DoT on 853. resolved cannot speak DoH, so pin the
  # address and use w.quic.best as the TLS server name; its certificate is
  # valid.
  magicDns = [
    "194.238.57.69#w.quic.best"
  ];

  # ~ routing domains also cover subdomains, so ~anthropic.com handles
  # api/assets/statsig.anthropic.com as well.
  domains = [
    # Claude / Anthropic.
    "claude.ai"
    "claude.com"
    "anthropic.com"
    # Google Gemini and AI Studio.
    "gemini.google.com"
    "aistudio.google.com"
    "generativelanguage.googleapis.com"
    "alkalimakersuite-pa.clients6.google.com"
    "webchannel-alkalimakersuite-pa.clients6.google.com"
    "alkalicore-pa.clients6.google.com"
    "waa-pa.clients6.google.com"
    "proactivebackend-pa.googleapis.com"
    "signaler-pa.clients6.google.com"
    # Gemini web chat/session backends. The frontend opens processSession
    # channels and backend RPCs on these hosts; through the RU WARP egress
    # Google cancels the stream and the UI shows "Something went wrong (1)".
    "geminiweb-pa.clients6.google.com"
    "jnn-pa.googleapis.com"
    "ogads-pa.clients6.google.com"
    "apis.google.com"
    "csp.withgoogle.com"
    "content-push.googleapis.com"
    "push.clients6.google.com"
    # Google Antigravity.
    "antigravity.google"
    "antigravity.google.com"
    # ChatGPT/OpenAI, including auth/API and static/upload CDNs.
    "chatgpt.com"
    "openai.com"
    "oaistatic.com"
    "oaiusercontent.com"
    # Perplexity.
    "perplexity.ai"
    # Cursor AI.
    "cursor.com"
    "cursor.sh"
    "cursorapi.com"
    # xAI Grok.
    "grok.com"
    "x.ai"
    # v0 by Vercel (v0.app is not intercepted by QUIC DNS).
    "v0.dev"
    # ElevenLabs.
    "elevenlabs.io"
    # Suno and Udio.
    "suno.com"
    "suno.ai"
    "udio.com"
    # Mistral Le Chat.
    "mistral.ai"
    # Hugging Face.
    "huggingface.co"
    "hf.co"
    # Runway.
    "runwayml.com"
    "runway.com"
    # Poe by Quora.
    "poe.com"
    # Midjourney.
    "midjourney.com"
    # Microsoft Copilot.
    "copilot.microsoft.com"
    "edgeservices.bing.com"
    # GitHub Copilot (github.com itself resolves normally).
    "api.github.com"
    "githubcopilot.com"
    "copilot.github.com"
    "copilot-proxy.githubusercontent.com"
    # Notion AI.
    "notion.so"
    "notion.com"
    "notion.site"
    # DeepL Pro.
    "deepl.com"
    # Adobe Firefly.
    "firefly.adobe.com"
    "firefly.adobe.io"
    # Xbox / Game Pass.
    "xbox.com"
    "xboxlive.com"
    "xboxservices.com"
    "gamepass.com"
    # PlayStation / Sony.
    "playstation.com"
    "playstation.net"
    "sonyentertainmentnetwork.com"
    "sony.com"
    # Konami (eFootball / PES / Yu-Gi-Oh).
    "konami.com"
    "konami.net"
  ];

  routingDomains = map (domain: "~${domain}") domains;
in {
  systemd.services.magicdns = {
    description = "Resolve ${lib.concatStringsSep ", " domains} via QUIC DNS";
    after = [
      "systemd-resolved.service"
      "NetworkManager.service"
    ];
    wants = ["systemd-resolved.service"];
    wantedBy = ["multi-user.target"];
    path = [
      pkgs.iproute2
      pkgs.systemd
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "-${pkgs.iproute2}/bin/ip link del magicdns";
    };
    script = ''
      ip link show magicdns >/dev/null 2>&1 || ip link add magicdns type dummy
      ip link set magicdns up
      # resolved only considers a link relevant when it has an address better
      # than link-local; the ULA keeps AAAA queries on this link too.
      ip addr replace 198.18.0.2/32 dev magicdns
      ip addr replace fd42:42:42::2/128 dev magicdns nodad
      resolvectl dns magicdns ${lib.escapeShellArgs magicDns}
      resolvectl domain magicdns ${lib.escapeShellArgs routingDomains}
      # Encrypt queries to the gateway over DoT; resolved cannot speak DoH.
      resolvectl dnsovertls magicdns yes
      resolvectl flush-caches
    '';
  };
}
