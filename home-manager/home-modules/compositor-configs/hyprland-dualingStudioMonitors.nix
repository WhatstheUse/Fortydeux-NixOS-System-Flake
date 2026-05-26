{ config, lib, ... }:

let
  sessionEnabled = config.sessionProfiles.hyprland.enable or false;
in
{
  config = lib.mkIf sessionEnabled {
    # Dual Monitors Setup (studio)
    wayland.windowManager.hyprland.settings = {
      monitor = [
        { output = "DP-1";     mode = "preferred"; position = "0x0";      scale = "auto"; }
        { output = "HDMI-A-1"; mode = "preferred"; position = "3440x200"; scale = "auto"; }
        # { output = "HDMI-A-1"; mode = "preferred"; position = "3440x0"; scale = "auto"; transform = 3; }
      ];
    };
  };
}
