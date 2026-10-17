# Domains that dns-bypass.nix resolves through the COMSS relay DNS. COMSS
# answers with CNAMEs pointing at its SNI relays (ai-pool/gemini-pool/
# flow-pool.comss.one, NL), which the web apps accept while the real
# Google/Anthropic addresses do not (the WARP tunnel egress geolocates to RU).
#
# vpn-split.nix also imports this list so the resulting relay addresses get
# /32 routes around awg0: bulk transfers to the relays through the WARP path
# collapse to ~5 KB/s versus ~150 KB/s on the direct path.
[
  "claude.ai"
  "anthropic.com"
  "openrouter.ai"
  "gemini.google.com"
  "aistudio.google.com"
  "generativelanguage.googleapis.com"
  # Google endpoints the Gemini/AI web apps use for chat streaming and
  # sign-in flows; COMSS relays them via gemini-pool/ai-pool/flow-pool.
  "signaler-pa.clients6.google.com"
  "ogads-pa.clients6.google.com"
  "apis.google.com"
  "ai.google.dev"
  "bard.google.com"
  "labs.google"
  "notebooklm.google.com"
  # Further Gemini backend endpoints COMSS relays; without relay DNS the
  # chat fails with "Something went wrong" because the real IPs are
  # answered from the RU-geolocated WARP egress.
  "jnn-pa.googleapis.com"
  "proactivebackend-pa.googleapis.com"
  "alkalicore-pa.clients6.google.com"
  "waa-pa.clients6.google.com"
  "csp.withgoogle.com"
  # AI Studio backends (ListModels RPCs and the webchannel); COMSS relays
  # both via gemini-pool. Without relay DNS the app talks to the real Google
  # IPs through the RU-geolocated WARP egress and fails with "Failed to list
  # models: permission denied".
  "alkalimakersuite-pa.clients6.google.com"
  "webchannel-alkalimakersuite-pa.clients6.google.com"
]
