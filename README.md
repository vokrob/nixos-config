# NixOS + Hyprland

![Desktop](desktop.png)

## Description

My personal NixOS setup, built with Flakes and Home Manager. Everything is in Catppuccin Mocha: Kitty, Zsh, Rofi, SwayNC, btop, Firefox, Neovim, Waybar (CPU/RAM indicators) and opencode. OpenClaw (AI assistant) works over Telegram, AmneziaWG starts the tunnel at boot, and Steam is enabled with Gamescope and MangoHud available for gaming.

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

You need an x86_64 NixOS installation with flakes enabled, Git, sudo, and an age key.
The repository's CI uses Nix 2.34 or newer because older Nix versions cannot lock a nested `nix-openclaw` input.

```bash
mkdir -p ~/.config/agenix && nix shell nixpkgs#age -c age-keygen -o ~/.config/agenix/age-key.txt
```

```bash
sudo mv /etc/nixos /etc/nixos.bak
nix shell nixpkgs#git -c git clone https://github.com/vokrob/nixos-config.git ~/nixos-config
sudo ln -s ~/nixos-config /etc/nixos

nixos-generate-config --show-hardware-config > ~/nixos-config/hosts/nixos/hardware-configuration.nix

grep -oP 'age1\w+' ~/.config/agenix/age-key.txt
# put this key into secrets.nix
```

Hyprland expects a wallpaper at `~/Pictures/desktop.jpg`; create the directory and copy an image there before rebuilding.

Note: `openclaw-workspace` in `flake.nix` is a local `path:` input (`/home/vokrob/.config/openclaw`
with `AGENTS.md`, `SOUL.md`, `TOOLS.md`, `IDENTITY.md`, `USER.md`, not committed to GitHub).
On a fresh clone create these files (see the placeholder trick in `.github/workflows/check.yml`)
and run `nix flake update openclaw-workspace --flake ~/nixos-config`. To remove the OpenClaw integration instead,
remove the input and all references to it from `flake.nix`, `hosts/nixos/default.nix`, and
`modules/home/default.nix`, then remove `modules/home/features/openclaw.nix`. Also remove
`nix flake update openclaw-workspace` from the `nix-switch` alias in
`modules/home/programs/zsh.nix`, remove the OpenClaw placeholder and `--override-input`
from `.github/workflows/check.yml`, and regenerate `flake.lock` with `nix flake lock ~/nixos-config`.

If removing OpenClaw completely, also remove `nix-openclaw` from `flake.nix`,
`modules/nixos/base.nix`, and `hosts/nixos/default.nix`, and remove the OpenClaw-only
secret entries from `hosts/nixos/users.nix` and `secrets.nix`; delete the corresponding
`secrets/openclaw-*.age` files if they are no longer needed.

Before enabling Telegram, replace the user ID `5748618304` in both allowlists in
`modules/home/features/openclaw.nix` with your own Telegram user ID.

The current configuration is tied to the `vokrob` user and `/home/vokrob`; before
using another username, update the hardcoded paths in `flake.nix`, `modules/home/`,
and `hosts/nixos/`.

The secrets live as encrypted `.age` files. Have the plaintext values ready before running this:
the command removes the existing ciphertext, and `agenix -e` opens an editor for each replacement file.
Re-encrypt them with your key:

```bash
cd ~/nixos-config
rm -f /etc/nixos/secrets/*.age
nix run github:ryantm/agenix -- -e secrets/codestats-api-key.age -i ~/.config/agenix/age-key.txt
# repeat for the remaining files listed in secrets.nix
```

```bash
sudo nixos-rebuild switch --flake ~/nixos-config#vokrob
```

## Usage

| alias         | what it does               |
|---------------|----------------------------|
| `nix-switch`  | update the OpenClaw workspace lock, stage all changes, rebuild |
| `nix-commit`  | stage everything and commit with a message |
| `nix-log`     | commit graph              |
| `v`           | nvim                      |

### Customization

- Home Manager packages: `modules/home/packages.nix`
- system packages/services: `modules/nixos/`
- AI models/provider: `modules/home/programs/opencode.nix`; OpenClaw provider: `modules/home/features/openclaw.nix`
- theme accent: primary sources are `blue` in `modules/home/features/catppuccin.nix`, `#89b4fa` in `modules/home/features/dotfiles.nix`, and `@blue` in `dotfiles/waybar/catppuccin-mocha.css`; also review hardcoded colors in `modules/home/programs/firefox.nix`, `modules/home/programs/btop.nix`, `dotfiles/kitty.conf`, `modules/home/features/hyprland.nix`, and `dotfiles/swaync/style.css`
- hotkeys: `modules/home/features/hyprland.nix`
- neovim: `modules/home/programs/neovim.nix`
- shell (prompt, aliases): `modules/home/programs/zsh.nix`; prompt configuration: `dotfiles/p10k.zsh`
- terminal: `dotfiles/kitty.conf`
- waybar: `dotfiles/waybar/config.jsonc`, `dotfiles/waybar/style.css`, `dotfiles/waybar/scripts/cpu.sh`, `dotfiles/waybar/scripts/memory.sh`
- vpn: `modules/nixos/features/vpn.nix`
- new host: copy `hosts/nixos/` to `hosts/<host>/`, generate a new `hardware-configuration.nix`,
  review the hostname, timezone, disk UUID rules, keyboard name, user, home, and age-key paths,
  set an initial password (enable OpenSSH before using an authorized SSH key), add a matching `nixosConfigurations.<host>`
  with the required `specialArgs`, and update the rebuild target (`#<host>`) and `nix-switch`
