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
  # COMSS gemini-pool SNI relays (end-to-end TLS with Google certificates).
  # Direct Google IPs reject RU egress with "User location is not supported";
  # COMSS DNS returns 3 pool IPs, one of them always failing - pin the two good ones.
  networking.hosts = {
    "157.22.178.170" = ["generativelanguage.googleapis.com"];
    "132.243.112.221" = ["generativelanguage.googleapis.com"];
  };

  services.resolved.enable = true;
  services.resolved.settings.Resolve.Domains = ["~speedtest.net"];
}
