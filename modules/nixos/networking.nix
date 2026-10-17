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
  services.resolved.enable = true;
  services.resolved.settings.Resolve.Domains = ["~speedtest.net"];
}
