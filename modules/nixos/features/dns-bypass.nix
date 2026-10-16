{
  lib,
  pkgs,
  ...
}: let
  # COMSS.ONE bypass DNS: for blocked services it returns CNAMEs pointing at
  # SNI relays (ai-pool/gemini-pool/flow-pool.comss.one, NL). The AmneziaWG
  # tunnel egress (Cloudflare WARP) is geolocated to RU, so real Google and
  # Anthropic IPs are rejected by the web apps, while the relays work.
  bypassDns = [
    "83.220.169.155"
    "212.109.195.93"
    "195.133.25.16"
  ];

  # Domains resolved via COMSS instead of the default 1.1.1.1.
  # claude.com is deliberately absent: COMSS does not proxy it and the relay
  # drops TLS connections with that SNI; the Claude web app talks to
  # claude.ai/anthropic.com, which are covered here.
  domains = [
    "claude.ai"
    "anthropic.com"
    "gemini.google.com"
    "aistudio.google.com"
  ];

  routingDomains = map (domain: "~${domain}") domains;
in {
  systemd.services.dns-bypass = {
    description = "Resolve ${lib.concatStringsSep ", " domains} via COMSS relay DNS";
    after = [
      "systemd-resolved.service"
      "NetworkManager.service"
    ];
    wants = ["systemd-resolved.service"];
    wantedBy = ["multi-user.target"];
    path = [
      pkgs.iproute2
      pkgs.systemd
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "-${pkgs.iproute2}/bin/ip link del bypassdns";
    };
    script = ''
      ip link show bypassdns >/dev/null 2>&1 || ip link add bypassdns type dummy
      ip link set bypassdns up
      # resolved only considers a link relevant when it has an address better
      # than link-local; without these the link's DNS servers are ignored.
      # The ULA address (nodad) keeps AAAA queries on this link so that COMSS
      # answers get used for them too (it returns no AAAA, unlike 1.1.1.1).
      ip addr replace 198.18.0.1/32 dev bypassdns
      ip addr replace fd42:42:42::1/128 dev bypassdns nodad
      resolvectl dns bypassdns ${lib.escapeShellArgs bypassDns}
      resolvectl domain bypassdns ${lib.escapeShellArgs routingDomains}
      resolvectl flush-caches
    '';
  };
}
