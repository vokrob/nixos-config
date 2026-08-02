{
  nix-openclaw,
  openclaw-workspace,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ../../modules/nixos
  ];

  networking.hostName = "nixos";
  time.timeZone = "Asia/Barnaul";
  system.stateVersion = "26.05";

  services.greetd.settings.default_session.user = "vokrob";
  nix.settings.trusted-users = ["vokrob"];

  # Hide non-system drives from Thunar/file-manager
  # (host-specific: UUIDs of this machine's dual-boot partitions)
  services.udev.extraRules = ''
    # Windows recovery partition
    ENV{ID_FS_UUID}=="0A8E08058E07E851", ENV{UDISKS_IGNORE}="1"
    # EFI/system partition
    ENV{ID_FS_UUID}=="E408-5A35", ENV{UDISKS_IGNORE}="1"
    # Windows data partition
    ENV{ID_FS_UUID}=="18500CE5500CCC06", ENV{UDISKS_IGNORE}="1"
    # Secondary storage drive
    ENV{ID_FS_UUID}=="602A765B2A762E62", ENV{UDISKS_IGNORE}="1"
  '';

  home-manager.users.vokrob = import ../../modules/home;
  home-manager.sharedModules = [nix-openclaw.homeManagerModules.openclaw];
  home-manager.extraSpecialArgs = {inherit openclaw-workspace;};
}
