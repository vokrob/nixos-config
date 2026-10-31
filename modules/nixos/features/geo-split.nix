{
  lib,
  pkgs,
  ...
}: let
  # IPv4 prefixes registered to Russia (ipdeny.com, aggregated). Update with:
  #   curl -sS https://www.ipdeny.com/ipblocks/data/aggregated/ru-aggregated.zone \
  #     > modules/nixos/features/geoip/ru-aggregated.zone
  geoipList = ./geoip/ru-aggregated.zone;

  # awg-quick routes all unmarked traffic through table 51820. This rule and
  # table take precedence for Russian destinations, so they bypass the tunnel
  # while everything else keeps using awg0. The mark excludes the tunnel's own
  # encapsulated packets.
  table = 51900;
  pref = 32763;

  # Addresses that must stay on the tunnel even if the RU list starts covering
  # them. generativelanguage.googleapis.com is pinned to this COMSS
  # gemini-pool member, which only works through WARP.
  tunnelExceptions = ["206.223.247.81"];

  sync = pkgs.writeShellApplication {
    name = "geo-split-sync";
    runtimeInputs = with pkgs; [
      coreutils
      gawk
      gnugrep
      iproute2
    ];
    text = ''
      MODE="''${1:-sync}"
      TABLE=${toString table}
      PREF=${toString pref}

      clean() {
        ip -4 rule del pref "$PREF" 2>/dev/null || true
        ip -4 route flush table "$TABLE" 2>/dev/null || true
      }

      if [ "$MODE" = "clean" ]; then
        clean
        exit 0
      fi

      # First default route in the main table that is not the tunnel.
      default_route="$(ip -4 route show default table main 2>/dev/null |
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
          }')"

      gw=""
      dev=""
      read -r gw dev <<<"$default_route" || true
      if [ -z "$gw" ] || [ -z "$dev" ]; then
        echo "geo-split: no non-tunnel default route found" >&2
        exit 1
      fi

      rules="$(ip -4 rule show)"
      if ! grep -q "^$PREF:.*lookup $TABLE$" <<<"$rules"; then
        ip -4 rule del pref "$PREF" 2>/dev/null || true
        ip -4 rule add pref "$PREF" not fwmark 51820 lookup "$TABLE"
      fi

      awk -v gw="$gw" -v dev="$dev" -v table="$TABLE" \
        '{ print "route replace " $1 " via " gw " dev " dev " table " table }' \
        ${geoipList} |
        ip -4 -batch -

      # shellcheck disable=SC2043
      for addr in ${lib.escapeShellArgs tunnelExceptions}; do
        ip -4 route replace "$addr/32" dev awg0 table "$TABLE"
      done
    '';
  };
in {
  systemd.services.geo-split = {
    description = "Route Russian IPv4 prefixes around the AmneziaWG tunnel";
    after = [
      "amneziawg.service"
      "network-online.target"
    ];
    wants = [
      "amneziawg.service"
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
      Restart = "on-failure";
      RestartSec = 10;
      ExecStart = lib.getExe sync;
      ExecStop = "${lib.getExe sync} clean";
    };
  };

  # Refresh the gateway when NetworkManager brings the link up or renews DHCP.
  # The guard keeps a manual `systemctl stop geo-split` (temporary full tunnel)
  # from being undone by later network events.
  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = pkgs.writeShellScript "geo-split-refresh" ''
        if ${pkgs.systemd}/bin/systemctl is-active --quiet geo-split.service; then
          ${lib.getExe sync} || true
        fi
      '';
    }
  ];
}
