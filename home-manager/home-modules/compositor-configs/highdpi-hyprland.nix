{ config, lib, ... }:

let
  sessionEnabled = config.sessionProfiles.hyprland.enable or false;
in
{
  config = lib.mkIf sessionEnabled {
    ### HiDPI XWayland Settings - needed for MS Surface
    wayland.windowManager.hyprland.settings = {
      monitor = [
        { output = "eDP-1"; mode = "highres";   position = "auto"; scale = 2; }
        { output = "DP-1";  mode = "preferred"; position = "auto"; scale = 1; }
      ];
      env = [
        { _args = [ "GDK_SCALE" "2" ]; }
      ];
      config = {
        xwayland = {
          force_zero_scaling = true;
        };
      };
    };
  };
}
