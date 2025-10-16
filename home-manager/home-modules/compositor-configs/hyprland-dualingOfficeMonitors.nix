{ config, lib, ... }:

let
  sessionEnabled = config.sessionProfiles.hyprland.enable or false;
in
{
  config = lib.mkIf sessionEnabled {
    wayland.windowManager.hyprland = {
      extraConfig = ''
        # Dual Monitors Setup:
        monitor=DP-1,preferred,0x0,auto
        monitor=HDMI-A-1,preferred,3440x200,auto
        # monitor=HDMI-A-1,preferred,3440x0,auto,transform,3
      '';
    };
  };
}
