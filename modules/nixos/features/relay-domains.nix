# Domains resolved through the COMSS relay DNS by dns-bypass.nix and routed
# directly around awg0 by vpn-split.nix. OpenRouter is not proxied by QUIC DNS:
# its real Cloudflare addresses return 403 through WARP, while the COMSS relay
# works. The AI services and gaming platforms are handled by the scoped QUIC
# DNS link instead.
[
  "openrouter.ai"
]
