{ pkgs, ... }: {
  users.users."vokrob" = {
    isNormalUser = true;
    description = "Danil";
    extraGroups = ["networkmanager" "wheel" "kvm"];
    shell = pkgs.zsh;
  };

  age.secrets = {
    "codestats-api-key" = {
      file = ../../secrets/codestats-api-key.age;
      owner = "vokrob";
      group = "users";
      mode = "0400";
    };
    "amneziawg-awg0" = {
      file = ../../secrets/amneziawg-awg0.age;
      owner = "root";
      group = "root";
      mode = "0400";
    };
    "wakatime-api-key" = {
      file = ../../secrets/wakatime-api-key.age;
      owner = "vokrob";
      group = "users";
      mode = "0400";
    };
    "openclaw-telegram-token" = {
      file = ../../secrets/openclaw-telegram-token.age;
      owner = "vokrob";
      group = "users";
      mode = "0400";
    };
    "openclaw-zhipu-key" = {
      file = ../../secrets/openclaw-zhipu-key.age;
      owner = "vokrob";
      group = "users";
      mode = "0400";
    };
    "openclaw-gateway-token" = {
      file = ../../secrets/openclaw-gateway-token.age;
      owner = "vokrob";
      group = "users";
      mode = "0400";
    };
  };

  age.identityPaths = ["/home/vokrob/.config/agenix/age-key.txt"];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    promptInit = "";
    shellAliases = {
      nix-switch = "git -C ~/nixos-config add . && sudo nixos-rebuild switch --flake ~/nixos-config#vokrob";
      nix-commit = "git -C ~/nixos-config add . && git -C ~/nixos-config commit -m";
      nix-log = "git -C ~/nixos-config log --graph --oneline --decorate --all";
      v = "nvim";
    };
    interactiveShellInit = ''
      zmodload zsh/datetime 2>/dev/null
      setopt NO_BEEP

      export CODESTATS_API_KEY="$(cat /run/agenix/codestats-api-key)"
      source "${pkgs.writeText "codestats.plugin.zsh" (builtins.readFile ../../zsh-codestats.plugin.zsh)}"

      wakatime_preexec() {
        (WAKATIME_API_KEY="$(cat /run/agenix/wakatime-api-key)" \
          wakatime-cli --write --plugin "zsh/1.0.0" \
            --entity-type app --entity "$1" --time "$EPOCHSECONDS" \
          2>/dev/null &)
      }
      preexec_functions+=(wakatime_preexec)

      source "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
      source "${pkgs.writeText "p10k.zsh" (builtins.readFile ../../dotfiles/p10k.zsh)}"
      eval "$(zoxide init zsh)"
      eval "$(fzf --zsh)"

      bindkey '^[[A' history-beginning-search-backward
      bindkey '^[[B' history-beginning-search-forward
      bindkey '^[OA' history-beginning-search-backward
      bindkey '^[OB' history-beginning-search-forward

      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      bindkey '^[[1;3C' forward-word
      bindkey '^[[1;3D' backward-word

      bindkey '^[[1;5H' beginning-of-buffer-or-history
      bindkey '^[[1;5F' end-of-buffer-or-history
      bindkey '^[[1;3H' beginning-of-buffer-or-history
      bindkey '^[[1;3F' end-of-buffer-or-history

      bindkey '^[[3;5~' kill-word
      bindkey '^[[3;3~' kill-word

      bindkey '^[[1;5A' up-line-or-history
      bindkey '^[[1;5B' down-line-or-history

      fastfetch
    '';
  };
}
