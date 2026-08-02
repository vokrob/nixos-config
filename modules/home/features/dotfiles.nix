{...}: let
  accentColor = "#89b4fa";
in {
  xdg.configFile = {
    "kitty/kitty.conf".source = ../../../dotfiles/kitty.conf;
    "fastfetch/config.jsonc".source = ../../../dotfiles/fastfetch.jsonc;
    "waybar/config.jsonc".source = ../../../dotfiles/waybar/config.jsonc;
    "waybar/style.css".source = ../../../dotfiles/waybar/style.css;
    "waybar/catppuccin-mocha.css".source = ../../../dotfiles/waybar/catppuccin-mocha.css;
    "waybar/scripts/keyboard-layout.sh" = {
      source = ../../../dotfiles/waybar/scripts/keyboard-layout.sh;
      executable = true;
    };
    "waybar/scripts/cpu.sh" = {
      source = ../../../dotfiles/waybar/scripts/cpu.sh;
      executable = true;
    };
    "waybar/scripts/memory.sh" = {
      source = ../../../dotfiles/waybar/scripts/memory.sh;
      executable = true;
    };
    "swaync/config.json".source = ../../../dotfiles/swaync/config.json;
    "swaync/style.css".source = ../../../dotfiles/swaync/style.css;
  };

  xdg.configFile."rofi/config.rasi" = {
    text = ''
      * {
          red:     #f38ba8;
          blue:    #89b4fa;
          green:   #a6e3a1;
          yellow:  #f9e2af;
          orange:  #fab387;
          purple:  #cba6f7;
          pink:    #f5c2e7;
          teal:    #94e2d5;
          sky:     #89dceb;
          lavender: #b4befe;
          white:   #cdd6f4;
          black:   #1e1e2e;
          gray:    #6c7086;

          background:     @black;
          foreground:     @white;
          background-alt: #313244;
          foreground-alt: #bac2de;
          selected:       ${accentColor};
          selected-fg:    #1e1e2e;
          border-color:   #45475a;
          urgent-color:   #f38ba8;
          surface0:       #313244;
          surface1:       #45475a;
          lightbg:        #45475a;
          lightfg:        #cdd6f4;
      }

      configuration {
          show-icons: true;
          drun-icon-theme: "Papirus";
          drun-display-format: "{name}";
      }

      window {
          transparency: "real";
          background-color: @background;
          text-color: @foreground;
          border: 2px;
          border-color: @border-color;
          border-radius: 16px;
          width: 650px;
          padding: 8px;
      }

      mainbox {
          background-color: transparent;
          text-color: @foreground;
          spacing: 8px;
          margin: 0;
      }

      inputbar {
          enabled: false;
      }

      listview {
          background-color: transparent;
          text-color: @foreground;
          border: 0;
          spacing: 2px;
          margin: 0;
          scrollbar: false;
          columns: 1;
          lines: 10;
          dynamic: true;
          layout: vertical;
      }

      element {
          background-color: transparent;
          text-color: @foreground;
          border-radius: 10px;
          padding: 8px 12px;
          spacing: 10px;
          cursor: pointer;
      }

      element normal {
          background-color: transparent;
          text-color: @foreground;
      }

      element alternate.normal {
          background-color: transparent;
          text-color: @foreground;
      }

      element selected {
          background-color: @surface1;
          text-color: @foreground;
      }

      element selected.normal {
          background-color: @surface1;
          text-color: @foreground;
      }

      element selected.urgent {
          background-color: @surface1;
          text-color: @foreground;
      }

      element selected.active {
          background-color: @surface1;
          text-color: @foreground;
      }

      element-icon {
          background-color: transparent;
          text-color: @foreground;
          size: 28px;
          padding: 0;
          margin: 0;
          vertical-align: 0.5;
          horizontal-align: 0.5;
      }

      element-text {
          background-color: transparent;
          text-color: @foreground;
          padding: 0;
          margin: 0;
          vertical-align: 0.5;
          horizontal-align: 0;
          cursor: pointer;
      }

      element selected.element-text {
          background-color: transparent;
          text-color: @foreground;
      }

      element selected element-text {
          text-color: @foreground;
      }

      element selected.element-icon {
          background-color: transparent;
          text-color: @foreground;
      }

      element selected element-icon {
          text-color: @foreground;
      }

      button {
          background-color: transparent;
          text-color: @foreground;
          border-radius: 10px;
          padding: 8px 12px;
      }

      mode-switcher {
          background-color: transparent;
          text-color: @foreground;
          border: 0;
          spacing: 4px;
          margin: 8px 0 0 0;
      }

      message {
          background-color: transparent;
          text-color: @foreground;
          border-radius: 10px;
          padding: 8px 12px;
          margin: 8px 0 0 0;
      }

      error-message {
          background-color: @background;
          text-color: @red;
          border-radius: 10px;
          padding: 8px 12px;
      }

      scrollbar {
          background-color: transparent;
          text-color: @foreground;
          handle-color: @gray;
          border-radius: 4px;
          width: 6px;
      }
    '';
  };

  xdg.configFile."xfce4/xfconf/xfce-perchannel-xml/thunar.xml" = {
    force = true;
    text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      <channel name="thunar" version="1.0">
        <property name="misc-single-click" type="bool" value="false"/>
        <property name="last-show-delete-trash" type="bool" value="false"/>
        <property name="last-details-view-zoom-level" type="string" value="THUNAR_ZOOM_LEVEL_50_PERCENT"/>
        <property name="last-window-maximized" type="bool" value="true"/>
        <property name="misc-confirm-move-to-trash" type="bool" value="false"/>
        <property name="hidden-bookmarks" type="array">
          <value type="string" value="computer:///"/>
          <value type="string" value="recent:///"/>
          <value type="string" value="file:///"/>
          <value type="string" value="network:///"/>
        </property>
      </channel>
    '';
  };

  xdg.dataFile = {
    "applications/firefox.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
    "applications/thunar-bulk-rename.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
    "applications/thunar-settings.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
    "applications/kitty.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
    "applications/nixos-manual.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
    "applications/thunar.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
    "applications/thunar-volman-settings.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
    "applications/rofi.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
    "applications/rofi-theme-selector.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
    "applications/nvim.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
    "applications/mpv.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
    "applications/base.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
    "applications/calc.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
    "applications/draw.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
    "applications/impress.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
    "applications/math.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
    "applications/writer.desktop".text = "[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true";
  };

  xdg.desktopEntries."android-studio" = {
    name = "Android Studio";
    exec = "android-studio %F";
    icon = "android-studio";
    categories = ["Development" "IDE"];
  };
}
