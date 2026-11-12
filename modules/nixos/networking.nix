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

  # Keep the public resolvers as the default. The scoped MagicDNS link in
  # features/magicdns.nix covers the AI/gaming domains; its routing domains
  # override the awg0 ~. domain for those names only.
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];
  services.resolved.enable = true;
  services.resolved.settings.Resolve.Domains = ["~speedtest.net"];
}
