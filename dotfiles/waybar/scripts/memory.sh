#!/usr/bin/env bash
mem_pct=$(free | awk '/^Mem:/ {printf "%.0f", $3/$2 * 100}')
mem_used=$(free -h | awk '/^Mem:/ {print $3}')
[ -z "$mem_pct" ] && mem_pct=0
[ -z "$mem_used" ] && mem_used="0B"

interpolate() {
  local c1=$1 c2=$2 t=$3
  local r1=$((16#${c1:0:2})) g1=$((16#${c1:2:2})) b1=$((16#${c1:4:2}))
  local r2=$((16#${c2:0:2})) g2=$((16#${c2:2:2})) b2=$((16#${c2:4:2}))
  local r=$(awk "BEGIN{printf \"%d\", $r1 + ($r2 - $r1) * $t}")
  local g=$(awk "BEGIN{printf \"%d\", $g1 + ($g2 - $g1) * $t}")
  local b=$(awk "BEGIN{printf \"%d\", $b1 + ($b2 - $b1) * $t}")
  printf "#%02x%02x%02x" $r $g $b
}

get_color() {
  local pct=$1
  if [ "$pct" -le 50 ]; then
    local t=$(awk "BEGIN{printf \"%.3f\", $pct / 50}")
    [ "$t" = "0.000" ] && t="0"
    interpolate "a6e3a1" "f9e2af" "$t"
  else
    local t=$(awk "BEGIN{printf \"%.3f\", ($pct - 50) / 50}")
    [ "$t" = "0.000" ] && t="0"
    interpolate "f9e2af" "f38ba8" "$t"
  fi
}

color=$(get_color "$mem_pct")
text="<span color='$color'> ${mem_pct}%</span>"
tooltip="${mem_used}"

printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
