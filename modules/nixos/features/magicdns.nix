{
  lib,
  pkgs,
  ...
}: let
  # MagicDNS returns SNI gateway addresses for Claude, Gemini/AI Studio,
  # ChatGPT/OpenAI, Midjourney, Copilot and PlayStation, which work from the
  # RU-geolocated WARP egress. Xbox resolves to normal Microsoft addresses but
  # benefits from clean MagicDNS answers. Only these domains use it; everything
  # else keeps the public resolvers from networking.nix.
  magicDns = [
    "94.249.177.102"
    "109.120.132.43"
  ];

  # ~ routing domains also cover subdomains, so ~anthropic.com handles
  # api/assets/statsig.anthropic.com as well.
  domains = [
    "claude.ai"
    "claude.com"
    "anthropic.com"
    "gemini.google.com"
    "aistudio.google.com"
    "generativelanguage.googleapis.com"
    "alkalimakersuite-pa.clients6.google.com"
    "webchannel-alkalimakersuite-pa.clients6.google.com"
    "alkalicore-pa.clients6.google.com"
    "waa-pa.clients6.google.com"
    "proactivebackend-pa.googleapis.com"
    "signaler-pa.clients6.google.com"
    # ChatGPT/OpenAI, including auth/API and static/upload CDNs.
    "chatgpt.com"
    "openai.com"
    "oaistatic.com"
    "oaiusercontent.com"
    # Midjourney.
    "midjourney.com"
    # Microsoft Copilot.
    "copilot.microsoft.com"
    "edgeservices.bing.com"
    # Xbox / Game Pass.
    "xbox.com"
    "xboxlive.com"
    "xboxservices.com"
    "gamepass.com"
    # PlayStation / Sony.
    "playstation.com"
    "playstation.net"
    "sonyentertainmentnetwork.com"
    "sony.com"
  ];

  routingDomains = map (domain: "~${domain}") domains;
in {
  systemd.services.magicdns = {
    description = "Resolve ${lib.concatStringsSep ", " domains} via MagicDNS";
    after = [
      "systemd-resolved.service"
      "NetworkManager.service"
    ];
    wants = ["systemd-resolved.service"];
    wantedBy = ["multi-user.target"];
    path = [
      pkgs.iproute2
      pkgs.systemd
    ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "-${pkgs.iproute2}/bin/ip link del magicdns";
    };
    script = ''
      ip link show magicdns >/dev/null 2>&1 || ip link add magicdns type dummy
      ip link set magicdns up
      # resolved only considers a link relevant when it has an address better
      # than link-local; the ULA keeps AAAA queries on this link too.
      ip addr replace 198.18.0.2/32 dev magicdns
      ip addr replace fd42:42:42::2/128 dev magicdns nodad
      resolvectl dns magicdns ${lib.escapeShellArgs magicDns}
      resolvectl domain magicdns ${lib.escapeShellArgs routingDomains}
      # Plain DNS keeps cold lookups fast; DoT adds ~300 ms through WARP.
      resolvectl dnsovertls magicdns no
      resolvectl flush-caches
    '';
  };
}
