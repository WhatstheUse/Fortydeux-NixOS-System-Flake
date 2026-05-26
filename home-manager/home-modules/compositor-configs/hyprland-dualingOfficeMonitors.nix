{ config, lib, ... }:

let
  sessionEnabled = config.sessionProfiles.hyprland.enable or false;
in
{
  config = lib.mkIf sessionEnabled {
    # Dual Monitors Setup (office)
    wayland.windowManager.hyprland.settings = {
      monitor = [
        { output = "HDMI-A-2"; mode = "preferred"; position = "0x0";    scale = "auto"; }
        { output = "HDMI-A-1"; mode = "preferred"; position = "1920x0"; scale = "auto"; }
        # { output = "HDMI-A-1"; mode = "preferred"; position = "3440x0"; scale = "auto"; transform = 3; }
      ];

      # Workspace pinning. NOTE: this conflicts with the dynamic
      # per-monitor numbering scheme in hyprland-config.nix (which assigns
      # workspaces 1-10 to monitor.id 0 and 11-20 to monitor.id 1). With
      # these rules in place, mod+2 will jump focus to HDMI-A-1 instead
      # of staying on the current monitor. Remove these if you want the
      # dynamic scheme to be the sole authority.
      workspace_rule = [
        { workspace = "1"; monitor = "HDMI-A-2"; }
        { workspace = "2"; monitor = "HDMI-A-1"; }
      ];
    };
  };
}
