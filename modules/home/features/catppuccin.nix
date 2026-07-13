{ pkgs, ... }: let
  accent = "blue";
  cursorAccent = "blue";

  catppuccin-gtk = pkgs.catppuccin-gtk.override {
    variant = "mocha";
    accents = [accent];
    size = "standard";
  };

  catppuccin-cursor = pkgs.runCommand "catppuccin-mocha-${cursorAccent}-cursor" {
    src = pkgs.fetchzip {
      url = "https://github.com/catppuccin/cursors/releases/download/v2.0.0/catppuccin-mocha-${cursorAccent}-cursors.zip";
      hash = "sha256-m8vvsnXRE1rtPz4eQpef6kyQ9ACusVXFNOjrDhYAmPk=";
      stripRoot = false;
    };
  } ''
    mkdir -p $out/share/icons
    cp -r $src/catppuccin-mocha-${cursorAccent}-cursors $out/share/icons/
  '';
in {
  home.pointerCursor = {
    enable = true;
    name = "catppuccin-mocha-${cursorAccent}-cursors";
    package = catppuccin-cursor;
    size = 24;
  };

  home.sessionVariables = {
    GTK_THEME = "catppuccin-mocha-${accent}-standard";
    XCURSOR_THEME = "catppuccin-mocha-${cursorAccent}-cursors";
    XCURSOR_SIZE = "24";
  };

  gtk = {
    enable = true;
    theme = {
      name = "catppuccin-mocha-${accent}-standard";
      package = catppuccin-gtk;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "catppuccin-mocha-${cursorAccent}-cursors";
      package = catppuccin-cursor;
      size = 24;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
    style = {
      name = "catppuccin-mocha-${accent}-standard";
      package = catppuccin-gtk;
    };
  };
}
