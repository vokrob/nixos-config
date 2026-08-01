{pkgs, ...}: {
  home.packages = with pkgs; [
    ayugram-desktop
    kitty
    waybar
    grim
    slurp
    wl-clipboard
    rofi
    papirus-icon-theme
    swaynotificationcenter
    swaybg
    thunar
    mousepad
    xfconf
    thunar-volman
    zsh-powerlevel10k
    zoxide
    fzf
    fastfetch
    wakatime-cli
    discord
    anytype
    socat
    jq
    wf-recorder
    imv
    mpv
    mangohud
    gamescope

    libreoffice-fresh
    vscode
    android-studio
    android-tools

    (writeShellScriptBin "rec-toggle" ''
      SINK_ID=$(wpctl status | grep -A20 'Sinks:' | grep '\*' | grep -oP '\s+\*\s+\K\d+')
      SINK_NAME=$(pw-cli info "$SINK_ID" 2>&1 | grep 'node.name' | cut -d'"' -f2)
      SINK_MONITOR="$SINK_NAME.monitor"

      case "''${1}" in
        stop)
          pkill -INT wf-recorder 2>/dev/null \
            && hyprctl notify 0 2000 "rgb(89dceb)" "Recording stopped" \
            || hyprctl notify 0 2000 "rgb(f38ba8)" "Not recording"
          ;;
        full)
          wf-recorder -a --audio="$SINK_MONITOR" \
            -f "$HOME/video-$(date +%Y%m%d-%H%M%S).mp4" &>/dev/null &
          hyprctl notify 0 2000 "rgb(a6e3a1)" "Recording full screen"
          ;;
        region)
          wf-recorder -g "$(slurp)" -a --audio="$SINK_MONITOR" \
            -f "$HOME/video-$(date +%Y%m%d-%H%M%S).mp4" &>/dev/null &
          hyprctl notify 0 2000 "rgb(a6e3a1)" "Recording region"
          ;;
        window)
          geom=$(hyprctl -j activewindow | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
          [ -z "$geom" ] && { hyprctl notify 0 2000 "rgb(f38ba8)" "No active window"; exit 1; }
          wf-recorder -g "$geom" -a --audio="$SINK_MONITOR" \
            -f "$HOME/video-$(date +%Y%m%d-%H%M%S).mp4" &>/dev/null &
          hyprctl notify 0 2000 "rgb(a6e3a1)" "Recording window"
          ;;
      esac
    '')

    lua-language-server
    nil
    pyright
    rust-analyzer
    typescript-language-server
    gopls
    yaml-language-server
    bash-language-server

    stylua
    alejandra
    black
    isort
    prettierd
    rustfmt
    gofumpt
    shfmt

    zip
    unzip
    unrar
  ];
}
