{pkgs, ...}: let
  geminiHosts = [
    "gemini.google.com"
    "aistudio.google.com"
    "generativelanguage.googleapis.com"
    "alkalimakersuite-pa.clients6.google.com"
    "webchannel-alkalimakersuite-pa.clients6.google.com"
    "proactivebackend-pa.googleapis.com"
    "alkalicore-pa.clients6.google.com"
    "waa-pa.clients6.google.com"
    "apis.google.com"
    "ai.google.dev"
    "bard.google.com"
    "notebooklm.google.com"
    "signaler-pa.clients6.google.com"
    "labs.google"
  ];

  # mafioznik maps opencode.ai to the same proxy pool, but the resolver
  # returns the dead members first, so OpenCode stalls on them before
  # reaching the live one. Pin it to the working proxy too.
  opencodeHosts = [
    "opencode.ai"
    "api.opencode.ai"
  ];
in {
  networking.networkmanager.enable = true;
  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeShellScript "resolved-scope-lan" ''
        if [ "$1" = "enp6s0" ]; then
          ${pkgs.systemd}/bin/resolvectl domain enp6s0 localnet '~localnet' || true
        fi
      '';
    }
  ];
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];
  # Claude hosts stay pinned to the fastest live COMSS ai-pool member. COMSS
  # DNS rotates between four relays; 176.12.72.184 stopped answering TCP on
  # 443, while 157.22.178.170 does (TLS ~0.2 s; .234 ~0.5 s, .18 ~1.5 s).
  # Pinning one relay avoids the DNS rotation handing out dead addresses.
  #
  # mafioznik DNS (the WARP profile DNS) returns four proxies for the Gemini
  # hosts and opencode.ai. Only 159.194.200.33 completes TLS through this PC's
  # WARP egress; .67/.68/.88 accept TCP and then stall for 15-20 s. Pin the
  # live proxy so browsers and OpenCode never pick a dead address.
  # geo-split.nix routes both proxy ranges through awg0.
  #
  # Gemini API health check:
  #   curl -fsS -H "x-goog-api-key: $(cat /run/agenix/gemini-api-key)" \
  #     https://generativelanguage.googleapis.com/v1beta/models >/dev/null
  networking.hosts = {
    "157.22.178.170" = [
      "claude.ai"
      "anthropic.com"
      "assets-proxy.anthropic.com"
      "assets.claude.ai"
      "api.anthropic.com"
      "statsig.anthropic.com"
    ];
    "159.194.200.33" = geminiHosts ++ opencodeHosts;
  };
  services.resolved.enable = true;
  services.resolved.settings.Resolve.Domains = ["~speedtest.net"];
}
