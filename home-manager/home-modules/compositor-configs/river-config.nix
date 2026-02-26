{ config, lib, pkgs, ... }:

let
  cfg = config.programs.river;
  sessionEnabled = config.sessionProfiles.river.enable or false;
  inherit (lib) mkEnableOption mkIf mkOption types;

  # Kirigami QML path for Noctalia (workaround for libplasma override issue)
  # kirigamiQmlPath = "${lib.getLib pkgs.kdePackages.kirigami}/lib/qt-6/qml";
in
{
  options.programs.river = {
    enable = mkEnableOption "River window manager";
    
    enableStylix = mkEnableOption "Enable Stylix theming integration for River";
    
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra configuration to append to river init";
    };
  };

  config = mkIf (cfg.enable && sessionEnabled) {

    wayland.windowManager.river = {
      enable = true;
      package = pkgs.river-classic;
      systemd.enable = true;
      xwayland.enable = true;
      
      extraSessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
        SDL_VIDEODRIVER = "wayland";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        _JAVA_AWT_WM_NONREPARENTING = "1";
        # Noctalia QML path (fixes libplasma kirigami override)
        # QML2_IMPORT_PATH = kirigamiQmlPath;
      };

      settings = {
        # Cursor theming with Stylix
        xcursor-theme = if cfg.enableStylix then "${config.stylix.cursor.name} ${toString config.stylix.cursor.size}" else "phinger-cursors 32";
        
        # Focus and cursor behavior
        focus-follows-cursor = "normal";
        set-cursor-warp = "on-focus-change";
        attach-mode = "bottom";
        
        # Hide cursor
        hide-cursor = {
          timeout = "5000";
          when-typing = "enabled";
        };
        
        # Keyboard repeat rate
        set-repeat = "50 300";
        
        # Background and border colors with Stylix integration
        background-color = lib.mkForce (if cfg.enableStylix then "0x${lib.removePrefix "#" config.lib.stylix.colors.base00}" else "0x002b36");
        border-color-focused = lib.mkForce (if cfg.enableStylix then "0x${lib.removePrefix "#" config.lib.stylix.colors.base0D}" else "0x33ccff");
        border-color-unfocused = lib.mkForce (if cfg.enableStylix then "0x${lib.removePrefix "#" config.lib.stylix.colors.base01}" else "0x595959");
        
        # Declare modes
        declare-mode = [ "passthrough" ];
        
        # Input device configuration
        input = {
          "pointer-1118-2338-Microsoft_Surface_Keyboard_Touchpad" = {
            natural-scroll = "enabled";
            click-method = "clickfinger";
            tap = "enabled";
            dwt = "enabled";
          };
          "pointer-9354-33639-Telink_Wireless_Receiver_Mouse" = {
            natural-scroll = "enabled";
          };
          # Generic touchpad configuration
          "type:pointer" = {
            dwt = "enabled";
          };
        };
        
        # Key mappings
        map = {
          normal = {
            # Reload config
            "Super+Shift C" = "spawn 'kill -SIGUSR1 $(pidof river)'";
            
            # Terminal
            "Control+Alt T" = "spawn foot";
            "Super S" = "spawn kitty";
            
            # Window management
            "Super Q" = "close";
            "Super+Shift E" = "exit";
            "Super Return" = "toggle-float";
            "Super F" = "toggle-fullscreen";
            "Super grave" = "zoom";
            
            # Launchers
            "Super Space" = "spawn 'fuzzel -w 80 -b 181818ef -t ccccccff'";
            "Super W" = "spawn 'rofi -show drun -show-icons'";
            "Control+Super P" = "spawn wleave";
            
            # Navigation
            "Super J" = "focus-view next";
            "Super K" = "focus-view previous";
            "Super+Shift J" = "swap next";
            "Super+Shift K" = "swap previous";
            "Super Period" = "focus-output next";
            "Super Comma" = "focus-output previous";
            "Super+Shift Period" = "send-to-output next";
            "Super+Shift Comma" = "send-to-output previous";
            
            # Voice dictation
            "Super X" = "spawn 'dictate-fw-ptt-auto 5'";
            "Super+Shift X" = "spawn 'dictate-wc-ptt-auto 5'";
            "Super backslash" = "spawn dictate-fw-ptt-toggle";
            "Super+Shift backslash" = "spawn dictate-wc-ptt-toggle";

            # Wooz screen magnifier
            "Super Z" = "spawn 'wooz --zoom-in 10% --mouse-track'";

            # Layout control
            "Super H" = "send-layout-cmd rivertile 'main-ratio -0.05'";
            "Super L" = "send-layout-cmd rivertile 'main-ratio +0.05'";
            "Super+Shift H" = "send-layout-cmd rivertile 'main-count +1'";
            "Super+Shift L" = "send-layout-cmd rivertile 'main-count -1'";
            
            # Layout orientation
            "Super Up" = "send-layout-cmd rivertile 'main-location top'";
            "Super Right" = "send-layout-cmd rivertile 'main-location right'";
            "Super Down" = "send-layout-cmd rivertile 'main-location bottom'";
            "Super Left" = "send-layout-cmd rivertile 'main-location left'";
            
            # View movement
            "Super+Alt H" = "move left 100";
            "Super+Alt J" = "move down 100";
            "Super+Alt K" = "move up 100";
            "Super+Alt L" = "move right 100";
            
            # View snapping
            "Super+Alt+Control H" = "snap left";
            "Super+Alt+Control J" = "snap down";
            "Super+Alt+Control K" = "snap up";
            "Super+Alt+Control L" = "snap right";
            
            # View resizing
            "Super+Alt+Shift H" = "resize horizontal -100";
            "Super+Alt+Shift J" = "resize vertical 100";
            "Super+Alt+Shift K" = "resize vertical -100";
            "Super+Alt+Shift L" = "resize horizontal 100";
            
            # Passthrough mode
            "Super F11" = "enter-mode passthrough";
            
            # Screenshots with Satty
            "None Print" = "spawn screenshot-region";
            "Super Print" = "spawn screenshot-output";
            "Super+Shift Print" = "spawn screenshot-window";
            
            # Scratchpad
            "Super P" = "toggle-focused-tags 1048576";
            "Super+Shift P" = "set-view-tags 1048576";
            
            # Media controls
            "None XF86AudioRaiseVolume" = "spawn 'amixer sset Master 2%+'";
            "None XF86AudioLowerVolume" = "spawn 'amixer sset Master 2%-'";
            "None XF86AudioMute" = "spawn 'amixer set Master 1+ toggle'";
            "None XF86AudioMedia" = "spawn 'playerctl play-pause'";
            "None XF86AudioPlay" = "spawn 'playerctl play-pause'";
            "None XF86AudioPrev" = "spawn 'playerctl previous'";
            "None XF86AudioNext" = "spawn 'playerctl next'";
            "None XF86MonBrightnessUp" = "spawn 'brightnessctl set 2%+'";
            "None XF86MonBrightnessDown" = "spawn 'brightnessctl set 2%-'";
          };
          
          locked = {
            # Media controls in locked mode
            "None XF86AudioRaiseVolume" = "spawn 'amixer sset Master 2%+'";
            "None XF86AudioLowerVolume" = "spawn 'amixer sset Master 2%-'";
            "None XF86AudioMute" = "spawn 'amixer set Master 1+ toggle'";
            "None XF86AudioMedia" = "spawn 'playerctl play-pause'";
            "None XF86AudioPlay" = "spawn 'playerctl play-pause'";
            "None XF86AudioPrev" = "spawn 'playerctl previous'";
            "None XF86AudioNext" = "spawn 'playerctl next'";
            "None XF86MonBrightnessUp" = "spawn 'brightnessctl set 2%+'";
            "None XF86MonBrightnessDown" = "spawn 'brightnessctl set 2%-'";
          };
          
          passthrough = {
            "Super F11" = "enter-mode normal";
          };
        };
        
        # Pointer mappings
        map-pointer = {
          normal = {
            "Super BTN_LEFT" = "move-view";
            "Super+Shift BTN_LEFT" = "resize-view";
            "Super BTN_MIDDLE" = "toggle-float";
          };
        };
        
        # Window rules
        rule-add = {
          float = {
            "-app-id" = {
              "'float*'" = {
                "-title" = {
                  "'foo'" = "float";
                };
              };
              "'mpv'" = "float";
            };
          };
          csd = {
            "-app-id" = {
              "'bar'" = "csd";
            };
          };
        };
        
        # Spawn tagmask
        spawn-tagmask = "4293918720"; # all_but_scratch_tag
      };
      
      extraConfig = ''
        spawn "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        spawn "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"

        # Launch Noctalia desktop shell
        # spawn "noctalia-shell"

        # auto starting apps
        bash $HOME/.config/river/scripts/autostart.sh

        # Output configuration is handled by Kanshi service
        # See: home-manager/home-modules/dotfiles/kanshi.nix

        # Tag mappings (1-9)
        for i in $(seq 1 9)
        do
            tags=$((1 << ($i - 1)))

            # Super+[1-9] to focus tag [0-8]
            riverctl map normal Super $i set-focused-tags $tags

            # Super+Shift+[1-9] to tag focused view with tag [0-8]
            riverctl map normal Super+Shift $i set-view-tags $tags

            # Super+Control+[1-9] to toggle focus of tag [0-8]
            riverctl map normal Super+Control $i toggle-focused-tags $tags

            # Super+Shift+Control+[1-9] to toggle tag [0-8] of focused view
            riverctl map normal Super+Shift+Control $i toggle-view-tags $tags
        done

        # Super+0 to focus all tags
        # Super+Shift+0 to tag focused view with all tags
        all_tags=$(((1 << 32) - 1))

        riverctl map normal Super 0 set-focused-tags $all_tags
        riverctl map normal Super+Shift 0 set-view-tags $all_tags

        # Set the default layout generator to be rivertile and start it.
        # River will send the process group of the init executable SIGTERM on exit.
        riverctl default-layout rivertile
        rivertile -view-padding 2 -outer-padding 2 -main-ratio 0.5 &

        ${cfg.extraConfig}
        spawn "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        spawn "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        spawn "systemctl --user start --no-block xdg-desktop-portal-kde.service"
      '';
    };
  };
}
