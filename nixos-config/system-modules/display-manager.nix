{ config, pkgs, lib, user, ... }:

{ # Display-manager.nix

  # Both programs.niri and services.desktopManager.plasma6 set
  # services.displayManager.defaultSession with lib.mkDefault, which collide at
  # equal priority when both are enabled. Pin the session we actually want here
  # (normal priority beats mkDefault) to break the tie.
  services.displayManager.defaultSession =
    lib.mkIf (config.sessionProfiles.niri.enable or false) "plasma";

  # Enable Cosmic Greeter / Display Manager
  # services.displayManager.cosmic-greeter.enable = true;

  #Enable SDDM Display manager
 services.displayManager = {
    enable = true;
    sddm.enable = true;
    sddm.wayland.enable = true;
    
    # Configure SDDM cursor theme to match Stylix settings
    sddm = { 
      autoNumlock = true;
      settings = {
        Theme = {
          CursorTheme = "phinger-cursors-light";
          CursorSize = "32";
        };
      };
    };
  };

   # Greetd - enable if disabling other login managers 
 #  services.greetd = {
 #    enable = true;
 #  #  settings = {
 #  #    default_session = {
 #  #      command = "${pkgs.hyprland}/bin/Hyprland --config ${hyprConfig}";
 #  #    };
 #  #  };
 #    settings = rec {
 #      initial_session = {
 #        command = "${pkgs.hyprland}/bin/Hyprland";
 #        user = ${user};
 #      };
 #      default_session = initial_session;
 #    };
 #  };	
}
