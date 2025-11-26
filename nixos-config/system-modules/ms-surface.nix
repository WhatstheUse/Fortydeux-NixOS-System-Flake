{ config, pkgs, lib, inputs, ... }:

{
  # MS-Surface.nix

  imports = [
	  #MS-Surface-specific modules:
	  # inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
	  inputs.nixos-hardware.nixosModules.microsoft-surface-common
    inputs.home-manager.nixosModules.home-manager 
  ];
  
  # Kernel version for MS Surface kernel
  hardware.microsoft-surface.kernelVersion = "stable";  

  # Surface-specific cachix substituter
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://fortydeux-surface.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "fortydeux-surface.cachix.org-1:FFouI4YY62YGdnQbABdRu+jGfhMDnO+zNWGocIFd3rs="
    ];
  };

  # Surface Laptop Support
  environment.systemPackages = [
    pkgs.libwacom-surface
    # Both below are enabled in surface-pro-intel module
    # pkgs.iptsd
    pkgs.surface-control
  ];
  # Enabled by default in microsoft-surface-pro-intel module
  services.iptsd.enable = true;

  # Enable better power management
  # services.tlp.enable = true;

  # Enable touchscreen and pen support
  hardware.sensor.iio.enable = true;

  # Uncomment if you need to blacklist webcam and camera-related kernel modules
  boot.blacklistedKernelModules = [ 
  #   "uvcvideo"
  #   "videobuf2_common"
  #   "videobuf2_v4l2"
  #   "videobuf2_memops"
  #   "videobuf2_vmalloc"
      "ipu3_imgu"
  ];
  boot.kernelPatches = [
    {
      name = "disable-rust";
      patch = null;
      extraConfig = ''
        RUST n
      '';
    }
  ];
}
