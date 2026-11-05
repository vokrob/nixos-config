# Domains resolved through the COMSS relay DNS by dns-bypass.nix and routed
# directly around awg0 by vpn-split.nix. OpenRouter is not proxied by MagicDNS:
# its real Cloudflare addresses return 403 through WARP, while the COMSS relay
# works. The AI services and gaming platforms listed on magicdns.ru are handled
# by the scoped MagicDNS link instead.
[
  "openrouter.ai"
]
