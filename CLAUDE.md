# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal NixOS flake featuring multiple Wayland compositors and desktop environments. The system supports five host configurations and includes KDE Plasma, COSMIC Desktop, and five compositors (Hyprland, Niri, Sway, River, Wayfire), each with customized configurations.

**Important**: The username is abstracted to a single variable in `flake.nix` (line 72). When changing the username, you MUST set a password for the new user to avoid lockout (see README.md for details).

## Build Commands

### System-Level (NixOS)
```bash
# Build system configuration for a specific host
sudo nixos-rebuild switch --flake .#<host>-nixos

# Available hosts: blacktetra, blackfin, archerfish, killifish, pufferfish
# Recommended host for new users: blacktetra

# Generate hardware configuration for a host
sudo nixos-generate-config --show-hardware-config > nixos-config/hosts/<host>/hardware-configuration.nix
```

### User-Level (Home Manager)
```bash
# Build home-manager configuration
nix run home-manager/master -- switch --flake .#fortydeux@<host>-nixos

# Replace 'fortydeux' with the username defined in flake.nix
```

### Maintenance
```bash
# Check flake syntax and validity
nix flake check

# Update all flake inputs
nix flake update

# Update specific input
nix flake lock --update-input <input-name>
```

## Repository Architecture

### High-Level Structure
```
fortyflake/
├── flake.nix                    # Main flake definition, username variable (line 72)
├── nixos-config/                # System-level NixOS configurations
│   ├── hosts/                   # Host-specific configurations
│   │   ├── blacktetra/          # General-purpose (Zen kernel)
│   │   ├── blackfin/            # Music production (Musnix, RT kernel)
│   │   ├── archerfish/          # MS Surface Book (surface kernel)
│   │   ├── killifish/           # MS Surface Book variant
│   │   └── pufferfish/          # Barebones (Xanmod kernel)
│   └── system-modules/          # Shared system modules
│       └── compositor-configs/  # System-level compositor setup
└── home-manager/                # User-level configurations
    ├── hosts/                   # Host-specific home configs
    └── home-modules/            # Shared home modules
        ├── compositor-configs/  # Main compositor configurations (Nix modules)
        └── dotfiles/            # Raw config files for smaller utilities
```

### Key Architecture Concepts

**Two-Layer Configuration System:**
1. **NixOS Layer** (`nixos-config/`): System-level packages, services, kernel configuration
2. **Home Manager Layer** (`home-manager/`): User-level configurations, dotfiles, per-user programs

**Compositor Configuration Pattern:**
- Compositors are enabled by uncommenting imports in host configuration files
- System-level enabling: `nixos-config/hosts/<host>/configuration.nix` imports from `nixos-config/system-modules/compositor-configs/`
- User-level config: `home-manager/hosts/<host>-home.nix` imports from `home-manager/home-modules/compositor-configs/`
- Both must be enabled for a compositor to work properly

**Configuration Management Strategy:**
- Major compositor configs (Hyprland, Niri, Sway, River, Wayfire) are now **Nix modules** in `home-manager/home-modules/compositor-configs/`
- Smaller utilities (dunst, mako, ranger, etc.) are still managed as **dotfiles** in `home-manager/home-modules/dotfiles/`
- Check `dotfiles-controller.nix` to see which configs are managed as Nix modules vs dotfiles
- Original dotfiles for compositors have been moved to backup files (labeled with "-backup")
- **Editing backup files has no effect** - you must edit the Nix modules

**Module System:**
- Common system config: `nixos-config/system-modules/common-config.nix`
- Common home config: `home-manager/home-modules/home-commonConfig.nix`
- Shared Wayland infrastructure: `nixos-config/system-modules/window-managers.nix`
- Modular design allows easy enabling/disabling of features

**Special Arguments Pattern:**
- `inputs` and `username` are passed through flake outputs
- NixOS: `specialArgs = { inherit inputs username; }`
- Home Manager: `extraSpecialArgs = { inherit inputs username; }`

## Host Configurations

- **blacktetra** (Recommended): General-purpose, Zen kernel, suitable for reasonably specced hardware
- **blackfin**: Music production optimized with Musnix, real-time kernel, Firewire audio support
- **archerfish**: Microsoft Surface Book with surface kernel and GitHub Actions for kernel caching
- **killifish**: Another Microsoft Surface Book variant with surface kernel support
- **pufferfish**: Barebones configuration for older, underpowered machines, Xanmod kernel

## Compositor Workflow Notes

**Critical Configuration Workflow:**
- When compositors are managed as Nix modules (most major ones are now), you must:
  1. Edit the Nix file in `home-manager/home-modules/compositor-configs/`
  2. Run `nix run home-manager/master -- switch --flake .#fortydeux@<host>-nixos`
  3. May need to logout/login (SUPER+SHIFT+E) or reboot to see changes
- This is **much more cumbersome** than typical compositor workflows with hot-reload
- For heavy development/customization:
  1. Comment out the config module or home.file write lines in the host file
  2. Run home-manager switch to disable management
  3. Edit configs directly in `$HOME/.config/` for immediate feedback
  4. Once stable, copy changes back to Nix modules and re-enable management

**Hyprland Hyprscroller Plugin:**
- Default Hyprland config uses the Hyprscroller plugin for PaperWM-like scrolling behavior
- This is **NOT** Hyprland's default tiling behavior
- To use traditional Hyprland tiling, comment out the Hyprscroller plugin in `hyprland-config.nix` and reassign keybindings

**Compositor-Specific Notes:**
- **Niri**: Recommended for new users - provides heads-up keybinding display on launch
- **Hyprland**: Uses UWSM (Universal Wayland Session Manager) for session management
- **Sway/Niri**: Have issues with UWSM, use direct launches
- **River**: Uses tag system instead of standard workspaces

## Theming

- Most theming applied via **Stylix** flake input
- System theming: `nixos-config/system-modules/system-theme.nix`
- Home theming: `home-manager/home-modules/home-theme.nix`

## Important Files

- `flake.nix:72` - Username variable (critical for all configurations)
- `nixos-config/system-modules/common-config.nix` - Core system configuration
- `nixos-config/system-modules/window-managers.nix` - Shared Wayland infrastructure
- `home-manager/home-modules/home-commonConfig.nix` - Core home configuration
- `home-manager/home-modules/dotfiles-controller.nix` - Dotfile management (shows which configs are Nix modules vs dotfiles)
- `home-manager/home-modules/wm-homeController.nix` - Common window manager functionality

## Development Notes

**Configuration Style:**
- Use 2-space indentation for Nix expressions
- Keep dotfiles in raw format when possible for easier sharing to non-Nix machines
- Use `home.file` for writing dotfiles rather than inline Nix strings
- Module imports follow pattern: `./path/to/module.nix`

**When Modifying Configurations:**
- Always check both NixOS and Home Manager layers when enabling features
- For compositor changes, verify both system and home imports are uncommented
- Test with `nix flake check` before building
- Remember that changing username requires password setup to avoid lockout

**Common Pitfalls:**
- Forgetting to set password after changing username
- Only enabling compositor at one layer (system or home) instead of both
- Editing backup dotfiles instead of Nix modules for major compositors
- Missing hardware-configuration.nix for new hosts

**Nix Garbage Collection:**
- Automatic optimization enabled
- Weekly garbage collection
- Keeps builds from last 20 days
- Systemd-boot limited to 8 configurations

## Flake Inputs

Key upstream projects:
- **nixpkgs**: NixOS unstable from GitHub (switched from Flakehub)
- **home-manager**: User environment management
- **stylix**: System-wide theming
- **hyprland**: Hyprland compositor with plugins (hyprland-plugins, hyprscroller, hyprgrass)
- **niri**: Niri compositor
- **nixvim**: Neovim configuration framework
- **anyrun**: Application launcher
- **atuin**: Shell history management
- **musnix**: Real-time audio production
- **nixos-hardware**: Hardware-specific configurations

Note: Recently reverted to GitHub URLs from Flakehub due to Determinate pricing changes.
