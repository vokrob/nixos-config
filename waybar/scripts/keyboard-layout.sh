#!/usr/bin/env bash

get_flag() {
    case "$1" in
        "English (US)") echo "🇺🇸" ;;
        "Russian") echo "🇷🇺" ;;
        *) echo "$1" ;;
    esac
}

layout=$(hyprctl devices -j 2>/dev/null | awk '/"active_keymap"/ {gsub(/.*: "/,""); gsub(/",?/,""); k=$0} /"main": true/ && k {print k; exit}')
[ -n "$layout" ] && get_flag "$layout"

socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" 2>/dev/null | while read -r line; do
    case "$line" in
        activelayout*)
            layout="${line#*,}"
            get_flag "$layout"
            ;;
    esac
done
