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
  # "User location is not supported"; COMSS DNS maps these hosts to
  # gemini-pool, which is live again. The ai-pool members 80.74.30.162 and
  # 176.12.72.184 are geo-rejected and 85.137.95.145 no longer answers, so
  # pin the Google AI hosts to the live gemini-pool member 199.189.253.237.
  # labs.google stays on COMSS DNS because this relay does not serve its
  # SNI. vpn-split.nix adds the relay's /32 route around awg0 via getent.
  #
  # Health check (the pin makes the request take the relay path):
  #   curl -fsS -H "x-goog-api-key: $(cat /run/agenix/gemini-api-key)" \
  #     https://generativelanguage.googleapis.com/v1beta/models >/dev/null
  networking.hosts = {
    "199.189.253.237" = [
      "generativelanguage.googleapis.com"
      "aistudio.google.com"
      "gemini.google.com"
      "alkalimakersuite-pa.clients6.google.com"
      "webchannel-alkalimakersuite-pa.clients6.google.com"
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
      "signaler-pa.clients6.google.com"
    ];
  };
  services.resolved.enable = true;
  services.resolved.settings.Resolve.Domains = ["~speedtest.net"];
}
