#!/usr/bin/env bash
cpu=$(top -bn1 2>/dev/null | awk '/^%Cpu/ {printf "%.0f", 100 - $8}')
[ -z "$cpu" ] && cpu=0

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

color=$(get_color "$cpu")
text="<span color='$color'> ${cpu}%</span>"

grep "^cpu" /proc/stat > /tmp/wb-cpu-1
sleep 0.15
grep "^cpu" /proc/stat > /tmp/wb-cpu-2

cores=()
exec 3</tmp/wb-cpu-1
exec 4</tmp/wb-cpu-2
while IFS=' ' read -r name u1 n1 s1 i1 _ <&3 && IFS=' ' read -r _ u2 n2 s2 i2 _ <&4; do
  [ "$name" = "cpu" ] && continue
  pt=$((u1 + n1 + s1 + i1))
  ct=$((u2 + n2 + s2 + i2))
  dt=$((ct - pt))
  di=$((i2 - i1))
  [ "$dt" -le 0 ] && continue
  usage=$((100 * (dt - di) / dt))
  [ "${usage#-}" -gt 100 ] && usage=100
  [ "$usage" -lt 0 ] && usage=0
  cores+=("${name}: ${usage}%")
done
exec 3<&- 4<&-

tooltip=$(printf '%s\\n' "${cores[@]}")
tooltip="${tooltip%\\n}"
printf '{"text": "%s", "tooltip": "%s"}\n' "$text" "$tooltip"
