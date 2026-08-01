{pkgs, ...}: {
  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.hyprland}/bin/start-hyprland";
        user = "vokrob";
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-hyprland];
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.steam.enable = true;
  programs.gamemode.enable = true;

  # Hide non-system drives from Thunar/file-manager
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

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "bak";
}
