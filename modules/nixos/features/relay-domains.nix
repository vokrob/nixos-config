# Domains resolved through the COMSS relay DNS by dns-bypass.nix and routed
# directly around awg0 by vpn-split.nix. Gemini/Google AI hosts are
# deliberately absent: they are pinned to the live mafioznik proxy in
# networking.nix and stay on awg0.
[
  "claude.ai"
  "anthropic.com"
  "openrouter.ai"
]
