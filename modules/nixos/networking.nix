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
  # Direct Google IPs reject RU egress with "User location is not supported".
  # The pool currently rotates and its mr2 member (45.88.174.254) is
  # geo-rejected by Google, so pin the three live members; vpn-split.nix
  # adds their /32 routes around awg0 via getent.
  networking.hosts = {
    "157.22.181.209" = ["generativelanguage.googleapis.com"];
    "132.243.112.221" = ["generativelanguage.googleapis.com"];
    "95.81.102.20" = ["generativelanguage.googleapis.com"];
  };
  services.resolved.enable = true;
  services.resolved.settings.Resolve.Domains = ["~speedtest.net"];
}
