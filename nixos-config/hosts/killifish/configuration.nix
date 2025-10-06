{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  # Configuration.nix - Killifish
  imports = [
    ../../system-modules/common-config.nix
    ../../system-modules/extraPackages.nix
    # ../../system-modules/extraLargePackages.nix
    ../../system-modules/display-manager.nix
    ../../system-modules/plasma.nix
    ../../system-modules/window-managers.nix
    ../../system-modules/cosmic-desktop.nix
    ../../system-modules/extraFonts.nix
    # ../../system-modules/virtualisation.nix
    # ../../system-modules/audio-prod.nix
    # ../../system-modules/fun-and-games.nix
    # Home-manager
    inputs.home-manager.nixosModules.home-manager
    # Device-specific
    ./hardware-configuration.nix
    # Remember to also comment out MS-Surface lines in flake.nix if disabling
    ../../system-modules/ms-surface-cachix.nix
    ../../system-modules/ms-surface.nix
  ];
  # Kernel - Turn off when MS-Surface Kernel is enabled
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable iptsd & surface-control for touch & stylus
  # services.iptsd.enable = lib.mkDefault true;
  # environment.systemPackages = [ pkgs.surface-control ];


  # The most common options you'll want to change for a new host machine reside here
  # For most machines, you'll want to comment out ./ms-surface.nix
  # and change your hostname

  # You may also want to enable the latest kernel line

  # And also comment out the MS-Surface lines in flake.nix for most machines

  # Be sure to generate your own hardware-configuration.nix before building
  # sudo nixos-generate-config --show-hardware-config > nixos-config/hosts/archerfish/hardware-configuration.nix

  # Hostname
  networking.hostName = "killifish-nixos"; # Define your hostname.

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 8;

  # Real-time kernel settings for audio production
  # musnix.kernel = {
  #   realtime = true;
  #   packages = pkgs.linuxPackages_latest_rt;
  # };
}
