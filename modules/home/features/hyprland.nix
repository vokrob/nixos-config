{lib, ...}: {
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";
    systemd.enable = false;
    settings = {
      mod = {
        _var = "SUPER";
      };

      config = {
        input = {
          kb_layout = "us,ru";
          kb_options = "grp:alt_shift_toggle";
        };

        dwindle = {
          preserve_split = true;
        };

        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          col = {
            active_border = {
              colors = [
                "rgba(89b4faee)"
                "rgba(89dcebee)"
              ];
              angle = 45;
            };
            inactive_border = "rgba(45475aaa)";
          };
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
        };

        misc = {
          disable_hyprland_logo = true;
        };
      };

      env = [
        {
          _args = [
            "XCURSOR_THEME"
            "catppuccin-mocha-blue-cursors"
          ];
        }
        {
          _args = [
            "XCURSOR_SIZE"
            "24"
          ];
        }
      ];

      curve = [
        {
          _args = [
            "easeInOutCubic"
            {
              type = "bezier";
              points = [
                [
                  0.65
                  0
                ]
                [
                  0.35
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "easeOutExpo"
            {
              type = "bezier";
              points = [
                [
                  0.16
                  1
                ]
                [
                  0.3
                  1
                ]
              ];
            }
          ];
        }
      ];

      animation = [
        {
          leaf = "windows";
          enabled = true;
          speed = 4;
          bezier = "easeOutExpo";
          style = "slide bottom";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 4;
          bezier = "easeOutExpo";
          style = "slide bottom";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 4;
          bezier = "easeInOutCubic";
        }
        {
          leaf = "fadeDim";
          enabled = true;
          speed = 4;
          bezier = "easeInOutCubic";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 5;
          bezier = "easeOutExpo";
          style = "slidefade";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 8;
          bezier = "easeOutExpo";
        }
        {
          leaf = "layersIn";
          enabled = true;
          speed = 4;
          bezier = "easeOutExpo";
          style = "slide bottom";
        }
        {
          leaf = "layersOut";
          enabled = true;
          speed = 4;
          bezier = "easeOutExpo";
          style = "slide bottom";
        }
        {
          leaf = "windowsMove";
          enabled = true;
          speed = 4;
          bezier = "easeOutExpo";
          style = "slide";
        }
        {
          leaf = "borderangle";
          enabled = true;
          speed = 15;
          bezier = "easeOutExpo";
          style = "once";
        }
        {
          leaf = "specialWorkspace";
          enabled = true;
          speed = 5;
          bezier = "easeOutExpo";
          style = "slidefadevert";
        }
      ];

      layer_rule = [
        {
          match = {
            namespace = "selection";
          };
          no_anim = true;
        }
        {
          match = {
            namespace = "waybar";
          };
          no_anim = true;
        }
        {
          match = {
            namespace = "swaync";
          };
          no_anim = true;
        }
      ];

      workspace_rule = [
        {
          workspace = "1";
          persistent = true;
        }
        {
          workspace = "2";
          persistent = true;
        }
        {
          workspace = "3";
          persistent = true;
        }
        {
          workspace = "4";
          persistent = true;
        }
        {
          workspace = "5";
          persistent = true;
        }
      ];

      bind = [
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + RETURN"'')
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"kitty\")")
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + B"'')
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"firefox\")")
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + C"'')
            (lib.generators.mkLuaInline "hl.dsp.window.close()")
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + R"'')
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"rofi -show drun\")")
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + E"'')
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"thunar\")")
          ];
        }
        {
          _args = [
            "PRINT"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd([[grim -g \"$(slurp)\" - | tee ~/screenshot-$(date +%Y%m%d-%H%M%S).png | wl-copy]])")
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + PRINT"'')
            (lib.generators.mkLuaInline ''
              hl.dsp.exec_cmd([[grim -g "$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" - | tee ~/screenshot-$(date +%Y%m%d-%H%M%S).png | wl-copy]])
            '')
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + SHIFT + PRINT"'')
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd([[grim - | tee ~/screenshot-$(date +%Y%m%d-%H%M%S).png | wl-copy]])")
          ];
        }
        {
          _args = [
            "Scroll_Lock"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"rec-toggle region\")")
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + Scroll_Lock"'')
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"rec-toggle window\")")
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + SHIFT + Scroll_Lock"'')
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"rec-toggle full\")")
          ];
        }
        {
          _args = [
            "PAUSE"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"rec-toggle stop\")")
          ];
        }
        {
          _args = [
            "XF86AudioRaiseVolume"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+\")")
            {locked = true;}
          ];
        }
        {
          _args = [
            "XF86AudioLowerVolume"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-\")")
            {locked = true;}
          ];
        }
        {
          _args = [
            "XF86AudioMute"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\")")
            {locked = true;}
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + mouse_up"'')
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"+1\" })")
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + mouse_down"'')
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"-1\" })")
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + J"'')
            (lib.generators.mkLuaInline "hl.dsp.layout(\"togglesplit\")")
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + 1"'')
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 1 })")
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + 2"'')
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 2 })")
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + 3"'')
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 3 })")
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + 4"'')
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 4 })")
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + 5"'')
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 5 })")
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + mouse:272"'')
            (lib.generators.mkLuaInline "hl.dsp.window.drag()")
            {mouse = true;}
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + mouse:273"'')
            (lib.generators.mkLuaInline "hl.dsp.window.resize()")
            {mouse = true;}
          ];
        }
      ];

      on = {
        _args = [
          "hyprland.start"
          (lib.generators.mkLuaInline ''
            function()
              hl.exec_cmd("systemctl --user start gvfs-daemon")
              hl.exec_cmd("swaybg -i /home/vokrob/Pictures/desktop.jpg")
              hl.exec_cmd("swaync")
              hl.exec_cmd("waybar")
              hl.exec_cmd("xfconfd")
            end
          '')
        ];
      };
    };
  };
}
