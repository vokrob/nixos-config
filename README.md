# NixOS + Hyprland

![Desktop](desktop.png)

## Description

Personal NixOS setup built with Flakes and Home Manager, using Catppuccin Mocha, Hyprland,
OpenClaw, AmneziaWG, and gaming tools.

## Tech Stack

- NixOS, Flakes, Home Manager
- Hyprland (Lua config), Catppuccin Mocha
- greetd, systemd-boot, zram swap
- Waybar, SwayNC, Kitty, Rofi, Thunar, fastfetch
- zsh + powerlevel10k, zoxide, fzf
- Steam, GameMode, Gamescope, MangoHud
- Docker, agenix, AmneziaWG
- wakatime, Codestats, Gemini API keys
- nvim, opencode
- OpenClaw (Telegram gateway)
- Garnix cache, alejandra

## Installation

Requires x86_64 NixOS, sudo, an age key and Nix >= 2.34.

```bash
echo 'experimental-features = nix-command flakes' | sudo tee -a /etc/nix/nix.conf
mkdir -p ~/.config/agenix && nix shell nixpkgs#age -c age-keygen -o ~/.config/agenix/age-key.txt
nix shell nixpkgs#git -c git clone https://github.com/vokrob/nixos-config.git ~/nixos-config
nixos-generate-config --show-hardware-config > ~/nixos-config/hosts/nixos/hardware-configuration.nix
```

Before the first rebuild:

- replace `vokrob` with your own name everywhere it appears (`flake.nix`, `hosts/nixos/`, `modules/home/`, `.github/workflows/check.yml`) and in the `nix-switch` alias;
- put your public key on line 2 of `secrets.nix`, delete `secrets/*.age` and re-encrypt the six entries with `nix run github:ryantm/agenix -- -e secrets/<name>.age`;
- create `~/.config/openclaw/{AGENTS,SOUL,TOOLS,IDENTITY,USER}.md`, then run `nix flake update openclaw-workspace --flake ~/nixos-config`;
- fix the settings that are hardcoded without the user name: `Asia/Barnaul` in `hosts/nixos/default.nix` and `dotfiles/waybar/config.jsonc`, `ru_RU.UTF-8` in `modules/nixos/base.nix`, your Telegram ID in both `allowFrom` blocks in `modules/home/features/openclaw.nix`.

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#<you>
passwd <you>
```

`passwd` is needed right after the first rebuild, since the config sets no password and `greetd`
authenticates through PAM.

`hosts/nixos/hardware-configuration.nix` must stay tracked by git (it is imported by `hosts/nixos/default.nix`),
but the shipped copy holds this machine's disk UUIDs, so regenerate it and do not commit it.

The config does not install `git`, which the `nix-*` aliases call; add `programs.git.enable = true;` to
`modules/nixos/base.nix` after the first rebuild.

`modules/home/base.nix` sets `xdg.userDirs.createDirectories = false`, so the wallpaper directory is not
created for you. Run `mkdir -p ~/Pictures ~/Downloads` and put an image at `~/Pictures/desktop.jpg`
(`modules/home/features/hyprland.nix`), otherwise `swaybg` finds nothing and Hyprland starts with a black background.

## Usage

| alias        | what it does                       |
|--------------|------------------------------------|
| `nix-switch` | update the workspace lock, stage changes, rebuild |
| `nix-commit` | stage changes and commit           |
| `nix-log`    | show the commit graph              |
| `v`          | open nvim                          |

`rec-toggle {full,region,window,stop}` wraps wf-recorder (`Scroll_Lock` combos, `Pause` stops) and writes to
`~/video-<timestamp>.mp4`; the `PRINT` combos take screenshots with grim into `~/screenshot-<timestamp>.png`.
