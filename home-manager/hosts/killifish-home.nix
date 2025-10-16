{ config, ... }:

{ # killifish-home.nix

  # Enable compositor programs
  # programs.hyprland = { enable = true; enableStylix = true; };
  # programs.sway = { enable = true; enableStylix = true; };
  # programs.wayfire = { enable = true; enableStylix = true; };
  # programs.river = { enable = true; enableStylix = true; };

  imports = [
    ../home-modules/home-commonConfig.nix
    ../home-modules/sh-env.nix	
    ../home-modules/dotfiles-controller.nix
    ../home-modules/home-theme.nix 
    ../home-modules/wm-homeController.nix
    # Task-specific
    ../home-modules/whisper-controller.nix
    # ../home-modules/screen-recording.nix
    
    # Compositor and Desktop Environment configurations - Enable/disable as needed
    ../home-modules/compositor-configs/hyprland-config.nix
    ../home-modules/compositor-configs/niri-config.nix
    ../home-modules/compositor-configs/wayfire-config.nix
    ../home-modules/compositor-configs/sway-config.nix
    ../home-modules/compositor-configs/river-config.nix
    
    # Device-specific
    ../home-modules/compositor-configs/highdpi-hyprland.nix
  ];

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
