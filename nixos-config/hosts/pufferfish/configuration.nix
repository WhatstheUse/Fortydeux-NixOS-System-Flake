{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  # Configuration.nix - Pufferfish
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
    ../../system-modules/compositor-configs/river-config.nix
    ../../system-modules/compositor-configs/wayfire-config.nix
    ../../system-modules/compositor-configs/niri-config.nix
    
    # Home-manager
    inputs.home-manager.nixosModules.home-manager
    # Device-specific
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc-laptop
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  # Be sure to generate your own hardware-configuration.nix before building
  # sudo nixos-generate-config --show-hardware-config > nixos-config/hosts/pufferfish/hardware-configuration.nix

  # Hostname
  networking.hostName = "pufferfish-nixos"; # Define your hostname.

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 8;
  # Swappiness
  boot.kernel.sysctl."vm.swappiness" = 20;


  # Kernel to use
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  sessionProfiles = {
    plasma.enable = true;
    cosmic.enable = false;
    hyprland.enable = true;
    niri.enable = true;
    sway.enable = true;
    river.enable = true;
    wayfire.enable = true;
  };
}
