# Domains resolved through the COMSS relay DNS by dns-bypass.nix and routed
# directly around awg0 by vpn-split.nix. Gemini/Google AI hosts are
# deliberately absent: they use the WARP profile DNS (see vpn.nix) and stay on
# awg0, matching the phone setup.
[
  "claude.ai"
  "anthropic.com"
  "openrouter.ai"
]
