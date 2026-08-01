{pkgs, ...}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      nix-switch = "git -C ~/nixos-config add . && sudo nixos-rebuild switch --flake ~/nixos-config#vokrob";
      nix-commit = "git -C ~/nixos-config add . && git -C ~/nixos-config commit -m";
      nix-log = "git -C ~/nixos-config log --graph --oneline --decorate --all";
      v = "nvim";
    };
    initContent = ''
      zmodload zsh/datetime 2>/dev/null
      setopt NO_BEEP

      export CODESTATS_API_KEY="$(cat /run/agenix/codestats-api-key)"
      source "${pkgs.writeText "codestats.plugin.zsh" (builtins.readFile ../../../dotfiles/zsh-codestats.plugin.zsh)}"

      wakatime_preexec() {
        (WAKATIME_API_KEY="$(cat /run/agenix/wakatime-api-key)" \
          wakatime-cli --write --plugin "zsh/1.0.0" \
            --entity-type app --entity "$1" --time "$EPOCHSECONDS" \
          2>/dev/null &)
      }
      preexec_functions+=(wakatime_preexec)

      source "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
      source "${pkgs.writeText "p10k.zsh" (builtins.readFile ../../../dotfiles/p10k.zsh)}"
      eval "$(zoxide init zsh)"
      eval "$(fzf --zsh)"

      bindkey '^[[A' history-beginning-search-backward
      bindkey '^[[B' history-beginning-search-forward
      bindkey '^[OA' history-beginning-search-backward
      bindkey '^[OB' history-beginning-search-forward

      bindkey '^[[127;3u' backward-kill-word
      bindkey '^[[127;5u' backward-kill-word
      bindkey '\e^?' backward-kill-word
      bindkey '\e^H' backward-kill-word
      bindkey '^H' backward-kill-word

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
