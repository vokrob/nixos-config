{pkgs, ...}: {
  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.hyprland}/bin/start-hyprland";
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

  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "bak";
}
