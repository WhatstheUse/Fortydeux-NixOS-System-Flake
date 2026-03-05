{ config, username, lib, ... }:

let
  sessionEnabled = config.sessionProfiles.hyprland.enable or false;
in
{
  config = lib.mkIf sessionEnabled {
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 150;
            on-timeout = "brightnessctl -s set 10";
            on-resume = "brightnessctl -r";
          }
          {
            timeout = 300;
            on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0";
            on-resume = "brightnessctl -rd rgb:kbd_backlight";
          }
          {
            timeout = 1500; # 20 min - lock
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 1600; # 25 min - screen off
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = 2500; # 35 min - suspend
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };

    # Only start hypridle when actually running Hyprland.
    # All sessionProfiles are enabled simultaneously in the host config, so
    # lib.mkIf sessionEnabled alone doesn't prevent the service from starting
    # in other compositor sessions. ConditionEnvironment provides the runtime gate.
    # lib.mkForce is required because HM's hypridle module already sets
    # ConditionEnvironment = "WAYLAND_DISPLAY"; we preserve that check and add ours.
    systemd.user.services.hypridle.Unit.ConditionEnvironment = lib.mkForce [
      "WAYLAND_DISPLAY"
      "XDG_CURRENT_DESKTOP=Hyprland"
    ];
  };
}
