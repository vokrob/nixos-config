{ nix-openclaw, openclaw-workspace, ... }: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  networking.hostName = "nixos";
  time.timeZone = "Asia/Barnaul";
  system.stateVersion = "26.05";

  home-manager.users.vokrob = import ../../modules/home;
  home-manager.sharedModules = [nix-openclaw.homeManagerModules.openclaw];
  home-manager.extraSpecialArgs = { inherit openclaw-workspace; };
}
