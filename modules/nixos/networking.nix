{pkgs, ...}: {
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
  # COMSS SNI relay (end-to-end TLS with Google certificates). The WARP
  # egress is geolocated to RU and the real Google IPs are rejected with
  # "User location is not supported"; COMSS's gemini-pool/flow-pool
  # answers (142.251.x) are currently rejected too, and the old gemini-pool
  # members (157.22.181.209, 132.243.112.221, 95.81.102.20) no longer
  # answer. ai-pool's 157.22.178.37 is the live relay, so pin the Google AI
  # hosts to it. labs.google stays on COMSS DNS because this relay does not
  # serve its SNI. vpn-split.nix adds the relay's /32 route around awg0 via
  # getent.
  #
  # Health check (the pin makes the request take the relay path):
  #   curl -fsS -H "x-goog-api-key: $(cat /run/agenix/gemini-api-key)" \
  #     https://generativelanguage.googleapis.com/v1beta/models >/dev/null
  networking.hosts = {
    "157.22.178.37" = [
      "generativelanguage.googleapis.com"
      "aistudio.google.com"
      "gemini.google.com"
      "alkalimakersuite-pa.clients6.google.com"
      "webchannel-alkalimakersuite-pa.clients6.google.com"
      "signaler-pa.clients6.google.com"
      "ogads-pa.clients6.google.com"
      "jnn-pa.googleapis.com"
      "proactivebackend-pa.googleapis.com"
      "alkalicore-pa.clients6.google.com"
      "waa-pa.clients6.google.com"
      "apis.google.com"
      "ai.google.dev"
      "csp.withgoogle.com"
      "bard.google.com"
      "notebooklm.google.com"
    ];
  };
  services.resolved.enable = true;
  services.resolved.settings.Resolve.Domains = ["~speedtest.net"];
}
