{ config, lib, ... }:

let
  sessionEnabled = config.sessionProfiles.hyprland.enable or false;
in
{
  config = lib.mkIf sessionEnabled {
    wayland.windowManager.hyprland = {
      extraConfig = ''
        ### HiDPI XWayland Settings - needed for MS Surface:
        ### -----------------------------------------------
        monitor=eDP-1,highres,auto,2
        monitor=DP-1,preferred,auto,1
        env = GDK_SCALE,2
        xwayland {
            force_zero_scaling = true
        }
      '';
    };
  };
}
