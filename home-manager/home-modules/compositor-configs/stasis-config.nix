{ config, lib, pkgs, username, ... }:

let
  # Determine which compositor/DE is active
  hyprlandEnabled = config.sessionProfiles.hyprland.enable or false;
  niriEnabled = config.sessionProfiles.niri.enable or false;
  swayEnabled = config.sessionProfiles.sway.enable or false;
  riverEnabled = config.sessionProfiles.river.enable or false;
  wayfireEnabled = config.sessionProfiles.wayfire.enable or false;
  cosmicEnabled = config.sessionProfiles.cosmic.enable or false;

  # Check if any Wayland compositor/DE is enabled
  anyWaylandEnabled = hyprlandEnabled || niriEnabled || swayEnabled || riverEnabled || wayfireEnabled || cosmicEnabled;

  # Dynamic lock command wrapper that detects current session at runtime
  stasis-lock = pkgs.writeShellScriptBin "stasis-lock" ''
    # Detect which compositor is currently running
    if ${pkgs.procps}/bin/pgrep -x Hyprland > /dev/null; then
      # Hyprland session - use hyprlock
      if ${pkgs.procps}/bin/pidof hyprlock > /dev/null; then
        echo "hyprlock already running"
        exit 0
      fi
      exec ${pkgs.hyprlock}/bin/hyprlock
    else
      # All other compositors - use swaylock
      exec ${pkgs.swaylock-effects}/bin/swaylock -f -c 000000
    fi
  '';

  lockCommand = "stasis-lock";

  # Determine DPMS commands based on active compositor/DE
  dpmsOffCommand =
    if hyprlandEnabled then "hyprctl dispatch dpms off"
    else if niriEnabled then "niri msg action power-off-monitors"
    else if swayEnabled then "swaymsg 'output * power off'"
    else if riverEnabled then "wlopm --off \\*"
    else if cosmicEnabled then "wlopm --off \\*"
    else "wlr-randr --output '*' --off";

  dpmsOnCommand =
    if hyprlandEnabled then "hyprctl dispatch dpms on"
    else if niriEnabled then "niri msg action power-on-monitors"
    else if swayEnabled then "swaymsg 'output * power on'"
    else if riverEnabled then "wlopm --on \\*"
    else if cosmicEnabled then "wlopm --on \\*"
    else "wlr-randr --output '*' --on";

  # Moderate timeout profile: 5min dim → 10min lock → 15min display-off → 30min suspend
  stasisConfig = ''
    @author "fortydeux"
    @description "Stasis idle manager configuration for NixOS Wayland compositors"

    stasis:
      # Enable smart media detection
      monitor_media true
      ignore_remote_media true

      # Respect Wayland idle inhibitor protocol
      respect_idle_inhibitors true

      # Enable notifications
      notify_before_action true
      notify_seconds_before 10
      notify_on_unpause true

      # Pre-suspend: always lock screen before suspending
      pre_suspend_command "${lockCommand}"

      # Sensible default app inhibitors
      # Blocks idle when these apps are running
      inhibit_apps [
        # Video conferencing
        r"[Dd]iscord"
        r"[Ss]lack"
        r"[Zz]oom"
        r"teams"
        r"[Mm]eet"
        r"[Ss]kype"

        # Media players and streaming
        r"[Vv]lc"
        r"mpv"
        r"celluloid"

        # Gaming
        r"[Ss]team"
        r"steam_app_.*"
        r"gamemode"
        r".*\.exe"
        r"wine.*"
        r"proton.*"

        # Screen recording and streaming
        r"[Oo][Bb][Ss]"
        r"obs-studio"
        r"SimpleScreenRecorder"
        r"[Kk]den[Ll]ive"

        # Browsers in fullscreen (for presentations, videos)
        r"firefox.*"
        r"chromium.*"
        r"chrome.*"
        r"brave.*"

        # Presentations
        r"libreoffice-impress"
        r"soffice.*impress"
      ]

      # Desktop idle actions
      # These apply when on desktop or when no power profile matches

      brightness:
        timeout 300
        command "brightnessctl -s set 10%"
        resume-command "brightnessctl -r"
      end

      keyboard-backlight:
        timeout 300
        command "brightnessctl -sd rgb:kbd_backlight set 0"
        resume-command "brightnessctl -rd rgb:kbd_backlight"
      end

      lock_screen:
        timeout 600
        command "loginctl lock-session"
        lock-command "${lockCommand}"
        notification "Locking screen in 10 seconds..."
      end

      dpms:
        timeout 900
        command "${dpmsOffCommand}"
        resume-command "${dpmsOnCommand}"
      end

      suspend:
        timeout 1800
        command "systemctl suspend"
        notification "Suspending system in 10 seconds..."
      end

      # Laptop-specific profiles
      # More conservative on AC power, more aggressive on battery

      on_ac:
        # Standard desktop timeouts apply here
        # (inherits from desktop actions above)
      end

      on_battery:
        # More aggressive power saving on battery
        brightness:
          timeout 180  # 3 minutes
          command "brightnessctl -s set 5%"
          resume-command "brightnessctl -r"
        end

        keyboard-backlight:
          timeout 120  # 2 minutes
          command "brightnessctl -sd rgb:kbd_backlight set 0"
          resume-command "brightnessctl -rd rgb:kbd_backlight"
        end

        lock_screen:
          timeout 480  # 8 minutes
          command "loginctl lock-session"
          lock-command "${lockCommand}"
        end

        dpms:
          timeout 600  # 10 minutes
          command "${dpmsOffCommand}"
          resume-command "${dpmsOnCommand}"
        end

        suspend:
          timeout 900  # 15 minutes
          command "systemctl suspend"
        end
      end

      # Laptop lid handling
      lid_close_action "lock-screen"
      lid_open_action "wake"
      debounce_seconds 3
    end
  '';

  # Waybar status script for Stasis
  stasis-status = pkgs.writeShellScriptBin "stasis-status" ''
    # Check if stasis is running
    if ! ${pkgs.procps}/bin/pgrep -x stasis > /dev/null; then
      echo '{"text": "󰒲", "tooltip": "Stasis: Not running", "class": "disabled"}'
      exit 0
    fi

    # Get stasis info in JSON format
    INFO=$(${pkgs.stasis}/bin/stasis info --json 2>/dev/null)

    if [ $? -ne 0 ] || [ -z "$INFO" ]; then
      echo '{"text": "󰒲", "tooltip": "Stasis: Error getting status", "class": "error"}'
      exit 0
    fi

    # Parse the JSON to determine status
    PAUSED=$(echo "$INFO" | ${pkgs.jq}/bin/jq -r '.paused // false')
    IDLE_INHIBITED=$(echo "$INFO" | ${pkgs.jq}/bin/jq -r '.idle_inhibited // false')
    MANUALLY_INHIBITED=$(echo "$INFO" | ${pkgs.jq}/bin/jq -r '.manually_inhibited // false')
    APP_BLOCKING=$(echo "$INFO" | ${pkgs.jq}/bin/jq -r '.app_blocking // false')
    MEDIA_BLOCKING=$(echo "$INFO" | ${pkgs.jq}/bin/jq -r '.media_blocking // false')

    if [ "$PAUSED" = "true" ]; then
      echo '{"text": "󰒳", "tooltip": "Stasis: Paused - system will stay awake", "class": "paused"}'
    elif [ "$MANUALLY_INHIBITED" = "true" ]; then
      echo '{"text": "󰅶", "tooltip": "Stasis: Keeping system awake (click to allow sleep)", "class": "inhibited-manual"}'
    elif [ "$MEDIA_BLOCKING" = "true" ]; then
      echo '{"text": "󰝚", "tooltip": "Stasis: Keeping awake - media playing", "class": "inhibited-media"}'
    elif [ "$APP_BLOCKING" = "true" ]; then
      echo '{"text": "󰀲", "tooltip": "Stasis: Keeping awake - app blocking idle", "class": "inhibited-app"}'
    elif [ "$IDLE_INHIBITED" = "true" ]; then
      echo '{"text": "󰅶", "tooltip": "Stasis: Keeping system awake", "class": "inhibited"}'
    else
      echo '{"text": "󰾪", "tooltip": "Stasis: Idle detection ON (click to keep awake)", "class": "active"}'
    fi
  '';
in
{
  config = lib.mkIf anyWaylandEnabled {
    # Install Stasis package and utility scripts
    home.packages = with pkgs; [
      stasis
      stasis-status
      stasis-lock
      wlopm  # Display power management for COSMIC and River
    ];

    # Write Stasis configuration
    home.file.".config/stasis/stasis.rune" = {
      text = stasisConfig;
    };

    # Stasis systemd service - DISABLED (reverting to swayidle)
    # To re-enable: uncomment the systemd.user.services.stasis block below
    # systemd.user.services.stasis = {
    #   Unit = {
    #     Description = "Stasis Wayland idle manager";
    #     Documentation = "https://github.com/saltnpepper97/stasis";
    #     PartOf = [ "graphical-session.target" ];
    #     After = [ "graphical-session.target" ];
    #   };
    #
    #   Service = {
    #     Type = "simple";
    #     ExecStart = "${pkgs.stasis}/bin/stasis";
    #     Restart = "on-failure";
    #     RestartSec = 3;
    #   };
    #
    #   Install = {
    #     WantedBy = [ "graphical-session.target" ];
    #   };
    # };
  };
}
