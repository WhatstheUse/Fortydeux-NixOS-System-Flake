{
  config,
  pkgs,
  inputs,
  ...
}:

{
  # Configuration.nix - Blacktetra
  imports = [
    ../../system-modules/common-config.nix
    ../../system-modules/extraPackages.nix
    ../../system-modules/extraLargePackages.nix
    ../../system-modules/display-manager.nix
    ../../system-modules/window-managers.nix
    # ../../system-modules/pcloud.nix
    ../../system-modules/virtualisation.nix
    ../../system-modules/extraFonts.nix
    # ../../system-modules/audio-prod.nix
    # ../../system-modules/fun-and-games.nix
    
    # Compositor and Desktop Environment configurations - Enable/disable as needed
    ../../system-modules/compositor-configs/plasma.nix
    ../../system-modules/compositor-configs/cosmic-desktop.nix
    ../../system-modules/compositor-configs/hyprland-config.nix
    ../../system-modules/compositor-configs/sway-config.nix
    # ../../system-modules/compositor-configs/river-config.nix  # Disabled: upstream Zig build issue
    ../../system-modules/compositor-configs/wayfire-config.nix
    ../../system-modules/compositor-configs/niri-config.nix
    
    # Home-manager
    inputs.home-manager.nixosModules.home-manager
    # Device-specific
    ./hardware-configuration.nix
  ];

  # Be sure to generate your own hardware-configuration.nix before building
  # sudo nixos-generate-config --show-hardware-config > nixos-config/hosts/blackfin/hardware-configuration.nix

  # Hostname
  networking.hostName = "blacktetra-nixos"; # Define your hostname.

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 8;

  # Kernel - Turn off when MS-Surface Kernel is enabled
  boot.kernelPackages = pkgs.linuxPackages_zen;
  # inputs.musnix.kernel.realtime = true;

  sessionProfiles = {
    plasma.enable = true;
    cosmic.enable = true;
    hyprland.enable = true;
    niri.enable = true;
    sway.enable = true;
    # river.enable = true;  # Disabled: upstream Zig build issue
    wayfire.enable = true;
  };
}
