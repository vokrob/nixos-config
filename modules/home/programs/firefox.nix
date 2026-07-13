{ pkgs, ... }: let
  ffExtid = "{2adf0361-e6d8-4b74-b3bc-3f450e8ebb69}";
  catppuccin-firefox-theme = pkgs.stdenv.mkDerivation {
    name = "catppuccin-firefox-theme";
    src = pkgs.fetchurl {
      url = "https://github.com/catppuccin/firefox/releases/download/old/catppuccin_mocha_blue.xpi";
      sha256 = "c7835b8d8c80228d8686e0fe7cba5f7217a113d28add71df2c77c0d2993cf439";
    };
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}
      cp $src $out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${ffExtid}.xpi
    '';
    passthru.addonId = ffExtid;
  };
in {
  programs.firefox = {
    enable = true;
    profiles.default = {
      id = 0;
      isDefault = true;
      path = "uichu0vs.default";
      extensions.packages = [catppuccin-firefox-theme];
      settings = {
        "extensions.activeThemeID" = ffExtid;
        "extensions.autoDisableScopes" = 0;
        "browser.download.dir" = "/home/vokrob/Downloads";
        "browser.download.folderList" = 2;
      };
    };
  };
}
