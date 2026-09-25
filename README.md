# NixOS + Hyprland

![Desktop](desktop.png)

## Description

Personal NixOS setup built with Flakes and Home Manager, themed in Catppuccin Mocha. OpenClaw (AI
assistant) works over Telegram, AmneziaWG starts the tunnel at boot, and Steam is enabled with
Gamescope and MangoHud available for gaming.

## Tech Stack

- NixOS + Flakes
- Home Manager
- agenix
- Hyprland
- Catppuccin Mocha
- OpenClaw
- opencode
- AmneziaWG

## Installation

You need an x86_64 NixOS installation with flakes enabled, Git, sudo, and an age key. CI uses Nix
2.34 or newer, because older versions cannot lock the nested `nix-openclaw` input.

```bash
mkdir -p ~/.config/agenix && nix shell nixpkgs#age -c age-keygen -o ~/.config/agenix/age-key.txt

sudo mv /etc/nixos /etc/nixos.bak
nix shell nixpkgs#git -c git clone https://github.com/vokrob/nixos-config.git ~/nixos-config
sudo ln -s ~/nixos-config /etc/nixos

nixos-generate-config --show-hardware-config > ~/nixos-config/hosts/nixos/hardware-configuration.nix
```

Two local prerequisites are not in the repository: a wallpaper at `~/Pictures/desktop.jpg`, and the
`openclaw-workspace` path input at `~/.config/openclaw`. On a fresh clone create the `.md`
placeholders listed in `.github/workflows/check.yml`, then run
`nix flake update openclaw-workspace --flake ~/nixos-config`.

The config is tied to the `vokrob` user and `/home/vokrob` — update those paths in `flake.nix`,
`modules/` and `hosts/` before using another username. Before enabling Telegram, replace both
allowlists in `modules/home/features/openclaw.nix` with your own user ID instead of `5748618304`.

The secrets are encrypted `.age` files. Have the plaintext values ready: the command removes the
existing ciphertext, and `agenix -e` opens an editor for each replacement file.

```bash
cd ~/nixos-config
grep -oP 'age1\w+' ~/.config/agenix/age-key.txt  # put the key into secrets.nix
rm -f /etc/nixos/secrets/*.age
nix run github:ryantm/agenix -- -e secrets/codestats-api-key.age -i ~/.config/agenix/age-key.txt
# repeat for the remaining files listed in secrets.nix

sudo nixos-rebuild switch --flake ~/nixos-config#vokrob
```

Not using OpenClaw? It is isolated in its own modules: `git grep -i openclaw` lists every
reference to prune — `flake.nix`, `hosts/`, `modules/`, `secrets.nix`, `.github/` — plus the
`secrets/openclaw-*.age` files themselves. Regenerate the lock with `nix flake lock ~/nixos-config`.

## Usage

| alias         | what it does               |
|---------------|----------------------------|
| `nix-switch`  | update the OpenClaw workspace lock, stage all changes, rebuild |
| `nix-commit`  | stage everything and commit with a message |
| `nix-log`     | commit graph              |
| `v`           | nvim                      |

## Customization

- Home Manager packages: `modules/home/packages.nix`
- system packages/services: `modules/nixos/`
- AI models/provider: `modules/home/programs/opencode.nix`; OpenClaw provider:
  `modules/home/features/openclaw.nix`
- hotkeys: `modules/home/features/hyprland.nix`; neovim: `modules/home/programs/neovim.nix`
- shell prompt and aliases: `modules/home/programs/zsh.nix`, `dotfiles/p10k.zsh`; terminal:
  `dotfiles/kitty.conf`
- waybar: `dotfiles/waybar/`; vpn: `modules/nixos/features/vpn.nix`
- theme accent: `blue` in `modules/home/features/catppuccin.nix`, `#89b4fa` in
  `modules/home/features/dotfiles.nix`, `@blue` in `dotfiles/waybar/catppuccin-mocha.css`;
  hardcoded colors also sit in `firefox.nix`, `btop.nix`, `kitty.conf`, `hyprland.nix` and
  `dotfiles/swaync/style.css`
- new host: copy `hosts/nixos/` to `hosts/<host>/`, generate a new `hardware-configuration.nix`,
  review the hostname, timezone, disk UUID rules, keyboard name, user, home and age-key paths,
  set an initial password, add a matching `nixosConfigurations.<host>` with the required
  `specialArgs`, then update the rebuild target and `nix-switch`
