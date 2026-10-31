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
  # Claude/OpenRouter hosts stay pinned to the fast COMSS ai-pool member:
  # COMSS DNS rotates between three relays, and 176.12.72.184 is several
  # times faster than 157.22.178.170 (330 KB/s versus 74 KB/s for a 530 KB
  # bundle).
  #
  # mafioznik DNS (the WARP profile DNS) returns four proxies for the Gemini
  # hosts. The .67/.68 members are unreachable through this PC's WARP egress,
  # so pin the two that work to keep Gemini from stalling on dead addresses.
  # geo-split.nix routes both proxy ranges through awg0.
  #
  # Gemini API health check:
  #   curl -fsS -H "x-goog-api-key: $(cat /run/agenix/gemini-api-key)" \
  #     https://generativelanguage.googleapis.com/v1beta/models >/dev/null
  networking.hosts = {
    "176.12.72.184" = [
      "claude.ai"
      "anthropic.com"
      "assets-proxy.anthropic.com"
      "assets.claude.ai"
      "api.anthropic.com"
      "statsig.anthropic.com"
    ];
    "193.233.112.88" = geminiHosts;
    "159.194.200.33" = geminiHosts;
  };
  services.resolved.enable = true;
  services.resolved.settings.Resolve.Domains = ["~speedtest.net"];
}
