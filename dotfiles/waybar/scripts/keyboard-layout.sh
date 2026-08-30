#!/usr/bin/env bash

get_flag() {
    case "$1" in
        "English (US)") echo "🇺🇸" ;;
        "Russian") echo "🇷🇺" ;;
        *) echo "$1" ;;
    esac
}

prev=""
while true; do
    layout=$(hyprctl devices -j 2>/dev/null | awk '/"active_keymap"/ {gsub(/.*: "/,""); gsub(/",?/,""); k=$0} /"main": true/ && k {print k; exit}')
    if [ -n "$layout" ]; then
        flag=$(get_flag "$layout")
        if [ "$flag" != "$prev" ]; then
            echo "$flag"
            prev="$flag"
        fi
    fi
    sleep 0.2
done
