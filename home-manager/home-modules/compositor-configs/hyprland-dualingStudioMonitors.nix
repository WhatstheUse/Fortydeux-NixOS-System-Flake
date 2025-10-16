{ config, lib, ... }:

let
  sessionEnabled = config.sessionProfiles.hyprland.enable or false;
in
{
  config = lib.mkIf sessionEnabled {
    wayland.windowManager.hyprland = {
      extraConfig = ''
        # Dual Monitors Setup:
        monitor=HDMI-A-2,preferred,0x0,auto
        monitor=HDMI-A-1,preferred,1920x0,auto
        # monitor=HDMI-A-1,preferred,3440x0,auto,transform,3

        # Workspace assignments
        workspace=1,monitor:HDMI-A-2
        workspace=2,monitor:HDMI-A-1
      '';
    };
  };
}
