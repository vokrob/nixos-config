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
    after = ["network.target"];
    wantedBy = ["multi-user.target"];
    path = with pkgs; [amneziawg-tools amneziawg-go iproute2 bash iptables];
    environment = {
      WG_QUICK_USERSPACE_IMPLEMENTATION = "amneziawg-go";
    };
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.amneziawg-tools}/bin/awg-quick up awg0";
      ExecStop = "${pkgs.amneziawg-tools}/bin/awg-quick down awg0";
    };
  };
}
