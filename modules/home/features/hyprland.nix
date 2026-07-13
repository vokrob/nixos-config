{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    systemd.enable = false;
    settings = {
      "$mod" = "SUPER";

      exec-once = [
        "systemctl --user start gvfs-daemon"
        "swaybg -i /home/vokrob/Pictures/hero.jpg"
        "swaync"
        "waybar"
        "xfconfd"
      ];

      env = [
        "XCURSOR_THEME,catppuccin-mocha-blue-cursors"
        "XCURSOR_SIZE,24"
      ];

      input = {
        kb_layout = "us,ru";
        kb_options = "grp:alt_shift_toggle";
      };

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bind = [
        "$mod, RETURN, exec, kitty"
        "$mod, B, exec, firefox"
        "$mod, C, killactive,"
        "$mod, R, exec, rofi -show drun"
        "$mod, E, exec, thunar"
        ", PRINT, exec, grim -g \"$(slurp)\" - | tee ~/screenshot-$(date +%Y%m%d-%H%M%S).png | wl-copy"
        ''$mod, PRINT, exec, grim -g "$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | tee ~/screenshot-$(date +%Y%m%d-%H%M%S).png | wl-copy''
        "$mod SHIFT, PRINT, exec, grim - | tee ~/screenshot-$(date +%Y%m%d-%H%M%S).png | wl-copy"
        ", Scroll_Lock, exec, rec-toggle region"
        "$mod, Scroll_Lock, exec, rec-toggle window"
        "$mod SHIFT, Scroll_Lock, exec, rec-toggle full"
        ", PAUSE, exec, rec-toggle stop"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        "$mod, mouse_up, workspace, +1"
        "$mod, mouse_down, workspace, -1"
        "$mod, J, layoutmsg, togglesplit"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
      ];

      layerrule = [
        "no_anim on, match:namespace selection"
        "no_anim on, match:namespace waybar"
        "no_anim on, match:namespace swaync"
      ];

      dwindle = {
        preserve_split = true;
      };
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(89b4faee) rgba(89dcebee) 45deg";
        "col.inactive_border" = "rgba(45475aaa)";
      };

      decoration = {
        rounding = 8;
        active_opacity = 1.0;
        inactive_opacity = 0.92;
        fullscreen_opacity = 1.0;

        shadow = {
          enabled = true;
          range = 20;
          render_power = 3;
          color = "rgba(11111b66)";
        };

        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          ignore_opacity = true;
          noise = 0.01;
          xray = true;
          contrast = 0.9;
          brightness = 1.0;
          vibrancy = 0.2;
          vibrancy_darkness = 0.0;
        };
      };

      animations = {
        enabled = true;

        bezier = [
          "easeInOutCubic, 0.65, 0, 0.35, 1"
          "easeOutExpo, 0.16, 1, 0.3, 1"
        ];

        animation = [
          "windows, 1, 4, easeOutExpo, slide bottom"
          "windowsOut, 1, 4, easeOutExpo, slide bottom"
          "fade, 1, 4, easeInOutCubic"
          "fadeDim, 1, 4, easeInOutCubic"
          "workspaces, 1, 5, easeOutExpo, slidefade"
          "border, 1, 8, easeOutExpo"
          "layersIn, 1, 4, easeOutExpo, slide bottom"
          "layersOut, 1, 4, easeOutExpo, slide bottom"
          "windowsMove, 1, 4, easeOutExpo, slide"
          "borderangle, 1, 15, easeOutExpo, once"
          "specialWorkspace, 1, 5, easeOutExpo, slidefadevert"
        ];
      };

      misc = {
        disable_hyprland_logo = true;
      };
    };
  };
}
