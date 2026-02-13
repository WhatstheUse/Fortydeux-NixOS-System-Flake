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
    # ../../system-modules/compositor-configs/river-config.nix  # Disabled: upstream Zig build issue
    ../../system-modules/compositor-configs/wayfire-config.nix
    ../../system-modules/compositor-configs/niri-config.nix
    
    # Home-manager
    inputs.home-manager.nixosModules.home-manager
    # Device-specific - iMac 12,2 (2011 mid-year, 27")
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
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

  zramSwap = {
    enable = true;
    memoryPercent = 40;
  };

  # iMac 12,2 specific hardware configuration
  # Hardware: Intel Core i5-2400, AMD Radeon HD 6970M + Intel HD Graphics
  # Display: 2560x1440 built-in, 12GB RAM

  # Load Apple-specific kernel modules
  boot.kernelModules = [ "applesmc" ];

  # Video drivers for dual GPU setup (AMD primary, Intel integrated)
  services.xserver.videoDrivers = [ "radeon" "modesetting" ];

  # Enable Broadcom WiFi firmware (BCM4321) - uncomment if needed
  # networking.enableB43Firmware = true;

  # If experiencing graphics issues, uncomment these kernel parameters:
  # boot.kernelParams = [
  #   "radeon.modeset=1"  # Enable kernel mode-setting for Radeon
  #   "video=2560x1440@60" # Force native resolution
  # ];

  # Kernel to use
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  # boot.kernelPackages = pkgs.linuxPackages_latest;

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
