{
  imports = [
    ./base.nix
    ./networking.nix
    ./services.nix
    ./security.nix
    ./features/vpn.nix
    ./features/vpn-split.nix
    ./features/dns-bypass.nix
  ];
}
