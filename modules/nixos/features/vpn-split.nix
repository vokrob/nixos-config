{
  lib,
  pkgs,
  ...
}: let
  # The relay domains (see relay-domains.nix) resolve to COMSS SNI relays that
  # are reachable directly and need /32 routes around awg0. opencode.ai stays
  # on WARP: the ISP silently drops TLS to its Cloudflare addresses, while the
  # tunnel serves them fine. Gemini hosts are not in the relay list: they use
  # the WARP profile DNS and stay on awg0.
  relayDomains = import ./relay-domains.nix;
  domains = relayDomains;

  sync = pkgs.writeShellApplication {
    name = "vpn-split-sync";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      glibc.getent
      gnugrep
      iproute2
    ];
    text = ''
      MODE="''${1:-sync}"
      STATE_DIR=/run/vpn-split
      ROUTES_FILE="$STATE_DIR/routes"

      mkdir -p "$STATE_DIR"
      touch "$ROUTES_FILE"

      # First default route in the main table that is not the tunnel.
      get_default() {
        ip "$1" route show default table main 2>/dev/null |
          awk '
            {
              gw = ""
              dev = ""
              for (i = 1; i <= NF; i++) {
                if ($i == "via") gw = $(i + 1)
                if ($i == "dev") dev = $(i + 1)
              }
              if (gw != "" && dev != "awg0") {
                print gw, dev
                exit
              }
            }'
      }

      remove_routes() {
        while read -r fam addr; do
          [ -n "''${fam:-}" ] || continue
          ip "$fam" route del "$addr" table main 2>/dev/null || true
        done < "$ROUTES_FILE"
      }

      if [ "$MODE" = "clean" ]; then
        remove_routes
        : > "$ROUTES_FILE"
        exit 0
      fi

      new_routes=$(mktemp)
      trap 'rm -f "$new_routes"' EXIT

      # shellcheck disable=SC2043
      for domain in ${lib.escapeShellArgs domains}; do
        for fam in -4 -6; do
          gw=""
          dev=""
          read -r gw dev <<<"$(get_default "$fam")" || true
          [ -n "$gw" ] || continue

          if [ "$fam" = "-4" ]; then
            plen=32
            getent_cmd=ahostsv4
          else
            plen=128
            getent_cmd=ahostsv6
          fi

          mapfile -t addrs < <(getent "$getent_cmd" "$domain" 2>/dev/null | awk '{print $1}' | sort -u || true)
          for addr in "''${addrs[@]}"; do
            ip "$fam" route replace "$addr/$plen" via "$gw" dev "$dev" table main
            printf '%s %s/%s\n' "$fam" "$addr" "$plen" >>"$new_routes"
          done
        done
      done

      # Drop routes for addresses the domain no longer resolves to.
      while read -r fam addr; do
        [ -n "''${fam:-}" ] || continue
        grep -qxF -- "$fam $addr" "$new_routes" || ip "$fam" route del "$addr" table main 2>/dev/null || true
      done <"$ROUTES_FILE"

      mv "$new_routes" "$ROUTES_FILE"
    '';
  };
in {
  systemd.services.vpn-split = {
    description = "Route ${lib.concatStringsSep ", " domains} around the AmneziaWG tunnel";
    after = [
      "amneziawg.service"
      "dns-bypass.service"
      "network-online.target"
    ];
    wants = [
      "amneziawg.service"
      "dns-bypass.service"
      "network-online.target"
    ];
    partOf = ["amneziawg.service"];
    wantedBy = [
      "multi-user.target"
      "amneziawg.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = lib.getExe sync;
      ExecStop = "${lib.getExe sync} clean";
    };
  };

  systemd.services.vpn-split-refresh = {
    description = "Refresh direct routes for ${lib.concatStringsSep ", " domains}";
    after = [
      "amneziawg.service"
      "dns-bypass.service"
    ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = lib.getExe sync;
    };
  };

  systemd.timers.vpn-split = {
    description = "Refresh direct routes for ${lib.concatStringsSep ", " domains}";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "30s";
      OnUnitActiveSec = "5min";
      AccuracySec = "10s";
      Unit = "vpn-split-refresh.service";
    };
  };
}
