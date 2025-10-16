# AGENT.md - Fortydeux NixOS Flake

## Build/Test Commands
- **Build NixOS system**: `sudo nixos-rebuild switch --flake .#<host>-nixos` (hosts: archerfish, killifish, pufferfish, blackfin, blacktetra)
- **Build Home Manager**: `home-manager switch --flake .#fortydeux@<host>-nixos`
- **Generate hardware config**: `sudo nixos-generate-config --show-hardware-config > nixos-config/hosts/<host>/hardware-configuration.nix`
- **Check syntax**: `nix flake check`
- **Update flake inputs**: `nix flake update`

## Architecture
- Multi-host NixOS flake supporting 5 systems (archerfish, killifish, pufferfish, blackfin, blacktetra)
- **nixos-config/**: System-level NixOS configurations per host under `nixos-config/hosts/<host>/`
- **home-manager/**: User-level configuration modules and host files in `home-manager/hosts/<host>-home.nix`
- **home-manager/home-modules/dotfiles/**: Raw config assets linked via `home-manager/home-modules/dotfiles-controller.nix` into `$HOME/.config/`
- Key desktops/compositors: KDE Plasma plus Hyprland, Niri, River, Sway, Wayfire
- Desktop/compositor availability toggled via `sessionProfiles.*.enable` (system definitions in `nixos-config/system-modules/window-managers.nix`, Home Manager counterpart in `home-manager/home-modules/wm-homeController.nix`)
- Inputs currently pinned to GitHub sources (Flakehub variants remain commented out); notable extras include Hyprland, Stylix, musnix

## Code Style
- Nix expressions use 2-space indentation
- Host configs live under `nixos-config/hosts/<host>/`; Home Manager entries are single files such as `home-manager/hosts/archerfish-home.nix`
- Dotfiles managed through `home.file.<path>.source` symlinks and targeted `.text` definitions within compositor modules
- Module imports follow pattern: `./path/to/module.nix`; compositor modules gate config behind the corresponding `sessionProfiles.<name>.enable`
- Special args passed via `specialArgs = { inherit inputs username; }`
- Home Manager configs use `extraSpecialArgs = { inherit inputs username; }`
