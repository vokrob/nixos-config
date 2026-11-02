{pkgs, ...}: let
  aiStudioHosts = [
    "aistudio.google.com"
    "alkalimakersuite-pa.clients6.google.com"
    "webchannel-alkalimakersuite-pa.clients6.google.com"
    "alkalicore-pa.clients6.google.com"
    "waa-pa.clients6.google.com"
    "proactivebackend-pa.googleapis.com"
    "signaler-pa.clients6.google.com"
    "generativelanguage.googleapis.com"
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
  # Gemini web is deliberately not pinned. The mafioznik DNS/proxy scheme that
  # used to serve it is dead, and pinning the web hosts to an SNI relay makes
  # Google see two egress IPs (WARP plus the relay) and return its "suspicious
  # traffic" page. Direct WARP access is clean but geo-blocked.
  #
  # AI Studio and its Gemini backend hosts are pinned to the live COMSS
  # gemini-pool relay: WARP egress is geolocated to RU, which AI Studio treats
  # as an unsupported region, while 206.223.250.249 serves the app from a
  # supported region and also serves generativelanguage.googleapis.com (~1 s).
  # Hosts the relay does not proxy (accounts.google.com, gstatic,
  # cloudconsole-pa) stay on normal DNS and WARP.
  #
  # opencode.ai and api.opencode.ai are deliberately absent: they resolve via
  # normal DNS to Cloudflare and must work with and without the tunnel. Pinning
  # them here to a Gemini proxy broke every OpenCode model.
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
    "206.223.250.249" = aiStudioHosts;
  };
  services.resolved.enable = true;
  services.resolved.settings.Resolve.Domains = ["~speedtest.net"];
}
