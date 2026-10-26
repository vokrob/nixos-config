{
  pkgs,
  config,
  ...
}: {
  age.secrets."amneziawg-awg0" = {
    file = ../../../secrets/amneziawg-awg0.age;
    owner = "root";
    group = "root";
    mode = "0400";
  };

  environment.systemPackages = with pkgs; [
    amneziawg-tools
    amneziawg-go
  ];

  environment.etc."amnezia/amneziawg/awg0.conf".source = config.age.secrets."amneziawg-awg0".path;

  systemd.services.amneziawg = {
    description = "AmneziaWG VPN Tunnel";
    after = [
      "network-online.target"
      "nss-lookup.target"
    ];
    wants = [
      "network-online.target"
      "nss-lookup.target"
    ];
    wantedBy = ["multi-user.target"];
    path = with pkgs; [amneziawg-tools amneziawg-go iproute2 bash iptables];
    environment = {
      WG_QUICK_USERSPACE_IMPLEMENTATION = "amneziawg-go";
      WG_ENDPOINT_RESOLUTION_RETRIES = "infinity";
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.amneziawg-tools}/bin/awg-quick up awg0";
      ExecStop = "${pkgs.amneziawg-tools}/bin/awg-quick down awg0";
    };
  };

  # The WARP egress IPv6 gets abusively flagged by Google ("suspicious
  # traffic") and mixed into sessions that otherwise use the COMSS relays,
  # so all IPv6 egress stays disabled. It cannot be disabled through
  # boot.kernel.sysctl globally: awg-quick would fail adding the IPv6
  # address from the tunnel config and the tunnel would not come up.
  systemd.services.awg-no-ipv6 = {
    description = "Disable IPv6 on the AmneziaWG interface";
    after = ["amneziawg.service"];
    wants = ["amneziawg.service"];
    wantedBy = [
      "multi-user.target"
      "amneziawg.service"
    ];
    partOf = ["amneziawg.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.procps}/bin/sysctl -w net.ipv6.conf.awg0.disable_ipv6=1";
    };
  };

  # The AmneziaWG config ships COMSS resolvers and sets them on awg0 with
  # ~., so systemd-resolved sends every query to them. They intermittently
  # time out (uncached drive.google.com took 5-30 s), and COMSS is only
  # needed for the relay domains that dns-bypass.nix already routes to its
  # own dummy link. Keep normal DNS for everything else.
  systemd.services.awg-dns = {
    description = "Use normal DNS on the AmneziaWG interface";
    after = [
      "amneziawg.service"
      "systemd-resolved.service"
    ];
    wants = [
      "amneziawg.service"
      "systemd-resolved.service"
    ];
    wantedBy = [
      "multi-user.target"
      "amneziawg.service"
    ];
    partOf = [
      "amneziawg.service"
      "systemd-resolved.service"
    ];
    script = ''
      ${pkgs.systemd}/bin/resolvectl dns awg0 1.1.1.1 8.8.8.8
      ${pkgs.systemd}/bin/resolvectl domain awg0 '~.'
      ${pkgs.systemd}/bin/resolvectl flush-caches
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
