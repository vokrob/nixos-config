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
  # "User location is not supported"; COMSS DNS maps these hosts to its
  # relays. The web/AI hosts go to the ai-pool member 176.12.72.184, which
  # serves them on both the direct path and WARP. The API endpoint is
  # pinned separately to the gemini-pool member 206.223.247.81, whose WARP
  # path is not geo-rejected: ai-pool .184/.170 answer the API with "User
  # location is not supported", and .251.18 is slow. .247.81 drops direct
  # connections, so vpn-split.nix excludes generativelanguage from its /32
  # routes and that pin stays on awg0. COMSS now answers gemini-pool with
  # real Google IPs, so the pins stay necessary. labs.google stays on COMSS
  # DNS because these relays do not serve its SNI.
  #
  # Health check (the pin keeps the request on the relay):
  #   curl -fsS -H "x-goog-api-key: $(cat /run/agenix/gemini-api-key)" \
  #     https://generativelanguage.googleapis.com/v1beta/models >/dev/null
  networking.hosts = {
    "176.12.72.184" = [
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
    "206.223.247.81" = ["generativelanguage.googleapis.com"];
  };
  services.resolved.enable = true;
  services.resolved.settings.Resolve.Domains = ["~speedtest.net"];
}
