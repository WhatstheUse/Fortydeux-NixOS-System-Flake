{ config, lib, pkgs, ... }:

let
  cfg = config.programs.sway;
  sessionEnabled = config.sessionProfiles.sway.enable or false;
  inherit (lib) mkEnableOption mkIf mkOption types;
in
{
  options.programs.sway = {
    enable = mkEnableOption "Sway window manager";
    
    enableStylix = mkEnableOption "Enable Stylix theming integration for Sway";
    
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra configuration to append to sway config";
    };
  };

  config = mkIf (cfg.enable && sessionEnabled) {
    # Note: We're not using wayland.windowManager.sway module to avoid conflicts
    # Instead, we're using home.file to create the config directly
    # and managing packages separately
    
    home.packages = with pkgs; [
      sway
      i3status-rust
      wl-clipboard
      grim
      slurp
      wf-recorder
      playerctl
      brightnessctl
      dmenu
      wmenu
      fuzzel
      anyrun
    ];

    # Create the Sway config file using home.file (the working approach)
    home.file.".config/sway/config".text = ''
      # Config for sway
      # Read `man 5 sway` for a complete reference.

      ### Variables
      #
      # Logo key. Use Mod1 for Alt.
      set $mod Mod4
      # Home row direction keys, like vim
      set $left h
      set $down j
      set $up k
      set $right l
      # Your preferred terminal emulator
      set $term kitty
      # Your preferred application launcher
      # Note: pass the final command to swaymsg so that the resulting window can be opened
      # on the original workspace that the command was run on.
      set $menu dmenu_path | wmenu | xargs swaymsg exec --

      input type:keyboard xkb_numlock enabled

      # Cursor theming with Stylix
      ${if cfg.enableStylix then "seat * xcursor_theme ${config.stylix.cursor.name}" else ""}

      gaps inner 1
      gaps outer 1


      ### Output configuration
      #
      # Default wallpaper (more resolutions are available in @datadir@/backgrounds/sway/)
      ${if cfg.enableStylix then "output * bg ${config.stylix.image} fill" else "output * bg ~/.config/wallpapers/zetong_san_francisco.jpg fill"}
      #
      # Example configuration:
      #
      # Generic fallbacks
      output HDMI-A-1 resolution 1920x1080 position 1920,0
      output eDP-1 resolution 3440x2160 position 0,0 scale 2

      # Specific display configurations by make/model/serial
      output "LG Electronics LG ULTRAWIDE 308NTTQD5209" resolution 3440x1440@160Hz position 0,0
      output "Ancor Communications Inc ASUS VS228 E8LMQS044730" resolution 1920x1080 position 3440,0

      # Generic DP-1 fallback for other machines
      output DP-1 resolution 1920x1080 position 1620,0
      workspace 1 output eDP-1
      workspace 1 output "LG Electronics LG ULTRAWIDE 308NTTQD5209"

      # You can get the names of your outputs by running: swaymsg -t get_outputs

      ### Idle configuration
      # Replaced by Stasis idle manager
      # Previous swayidle configuration:
      #
      # exec swayidle -w \
      #         timeout 3000 'swaylock -f -c ${if cfg.enableStylix then config.lib.stylix.colors.base00 else "000000"}' \
      #         timeout 6000 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
      #         before-sleep 'swaylock -f -c ${if cfg.enableStylix then config.lib.stylix.colors.base00 else "000000"}' 

      # This will lock your screen after 300 seconds of inactivity, then turn off
      # your displays after another 300 seconds, and turn your screens back on when
      # resumed. It will also lock your screen before your computer goes to sleep.

      ### Input configuration
      #
      # Example configuration:
      #
        input "1118:2338:Microsoft_Surface_Keyboard_Touchpad" {
            accel_profile adaptive
            click_method clickfinger
            drag enabled
            pointer_accel 0.3
            dwt enabled
            tap enabled
            natural_scroll enabled
            middle_emulation enabled
        }

        input 7847:100:2.4G_Mouse {
          natural_scroll enabled
        }

        input type:touchpad {
            accel_profile adaptive
            click_method clickfinger
            drag enabled
            pointer_accel 0.3
            dwt enabled
            tap enabled
            natural_scroll enabled
            middle_emulation enabled
        }

        input type:mouse {
            natural_scroll enabled
        }

        input type:pointer {
            natural_scroll enabled
        }
      #
      # You can get the names of your inputs by running: swaymsg -t get_inputs
      # Read `man 5 sway-input` for more information about this section.

      ### Startup Applications
          exec pcloud
          exec stasis

      ### Key bindings
      #
      # Basics:
      #
          # Start a terminal
          bindsym $mod+s exec $term

          # Kill focused window
          bindsym $mod+Shift+q kill
          bindsym $mod+q kill

          # Start your launcher
          bindsym $mod+d exec $menu
          bindsym $mod+space exec $menu
          bindsym alt+space exec "anyrun"
          bindsym $mod+grave exec "fuzzel"
          
          # Voice dictation - Momentary
          bindsym --no-repeat $mod+x exec "dictate-fw-ptt-auto 5"
          bindsym --no-repeat $mod+Shift+x exec "dictate-wc-ptt-auto 5"

          # Voice dictation - Toggle
          bindsym --no-repeat $mod+backslash exec "dictate-fw-ptt-toggle"
          bindsym --no-repeat $mod+Shift+backslash exec "dictate-wc-ptt-toggle"

          # Voice dictation - True push-to-talk (hold key)
          # bindsym $mod+backslash exec "dictate-fw-ptt-start"
          # bindsym --on-release $mod+backslash exec "dictate-fw-ptt-stop"
          # bindsym $mod+Shift+backslash exec "dictate-wc-ptt-start"
          # bindsym --on-release $mod+Shift+backslash exec "dictate-wc-ptt-stop"

          # Wooz screen magnifier
          bindsym $mod+z exec "wooz --zoom-in 10% --mouse-track"

          # Drag floating windows by holding down $mod and left mouse button.
          # Resize them with right mouse button + $mod.
          # Despite the name, also works for non-floating windows.
          # Change normal to inverse to use left mouse button for resizing and right
          # mouse button for dragging.
          floating_modifier $mod normal

          # Reload the configuration file
          bindsym $mod+Shift+c reload

          # Exit sway (logs you out of your Wayland session)
          bindsym $mod+Shift+e exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'
      #
      # Moving around:
      #
          # Move your focus around
          bindsym $mod+$left focus left
          bindsym $mod+$down focus down
          bindsym $mod+$up focus up
          bindsym $mod+$right focus right
          # Or use $mod+[up|down|left|right]
          bindsym $mod+Left focus left
          bindsym $mod+Down focus down
          bindsym $mod+Up focus up
          bindsym $mod+Right focus right

          # Move the focused window with the same, but add Shift
          bindsym $mod+Shift+$left move left
          bindsym $mod+Shift+$down move down
          bindsym $mod+Shift+$up move up
          bindsym $mod+Shift+$right move right
          # Ditto, with arrow keys
          bindsym $mod+Shift+Left move left
          bindsym $mod+Shift+Down move down
          bindsym $mod+Shift+Up move up
          bindsym $mod+Shift+Right move right
      #
      # Workspaces:
      #
          # Switch to workspace
          bindsym $mod+1 workspace number 1
          bindsym $mod+2 workspace number 2
          bindsym $mod+3 workspace number 3
          bindsym $mod+4 workspace number 4
          bindsym $mod+5 workspace number 5
          bindsym $mod+6 workspace number 6
          bindsym $mod+7 workspace number 7
          bindsym $mod+8 workspace number 8
          bindsym $mod+9 workspace number 9
          bindsym $mod+0 workspace number 10
          bindsym $mod+Ctrl+Left workspace prev
          bindsym $mod+Ctrl+Right workspace next

          bindgesture swipe:4:right workspace prev
          bindgesture swipe:4:left exec ~/.config/sway/scripts/swipe-left.sh
          bindgesture swipe:3:up focus down
          bindgesture swipe:3:down focus up
          bindgesture swipe:3:right focus left
          bindgesture swipe:3:left focus right

          
          # Move focused container to workspace
          bindsym $mod+Shift+1 move container to workspace number 1
          bindsym $mod+Shift+2 move container to workspace number 2
          bindsym $mod+Shift+3 move container to workspace number 3
          bindsym $mod+Shift+4 move container to workspace number 4
          bindsym $mod+Shift+5 move container to workspace number 5
          bindsym $mod+Shift+6 move container to workspace number 6
          bindsym $mod+Shift+7 move container to workspace number 7
          bindsym $mod+Shift+8 move container to workspace number 8
          bindsym $mod+Shift+9 move container to workspace number 9
          bindsym $mod+Shift+0 move container to workspace number 10
          bindsym $mod+Ctrl+Shift+Left exec ~/.config/sway/scripts/sway-left.sh
      #   bindsym $mod+Ctrl+Shift+Left workspace prev
          bindsym $mod+Ctrl+Shift+Right exec ~/.config/sway/scripts/sway-right.sh
      #   bindsym $mod+Ctrl+Shift+Right workspace prev

          # Note: workspaces can have any name you want, not just numbers.
          # We just use 1-10 as the default.

      #
      # System controls
      #
      bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindsym XF86AudioLowerVolume exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-
      bindsym XF86AudioRaiseVolume exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
      bindsym XF86AudioMicMute exec pactl set-source-mute @DEFAULT_SOURCE@ toggle
      bindsym XF86MonBrightnessDown exec brightnessctl set 5%-
      bindsym XF86MonBrightnessUp exec brightnessctl set 5%+
      bindsym XF86AudioPlay exec playerctl play-pause
      bindsym XF86AudioNext exec playerctl next
      bindsym XF86AudioPrev exec playerctl previous

      # Screenshots with Satty
      set $satty satty -f - --output-filename ${config.home.homeDirectory}/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png
      
      # Quick screenshot bindings (consistent with other compositors)
      bindsym Print exec grim -g "$(slurp -d)" -t ppm - | $satty
      bindsym $mod+Print exec grim -t ppm - | $satty
      
      # Advanced screenshot mode
      set $printscreen_mode 'printscreen (r:region, f:full, w:window)'
      mode $printscreen_mode {
          bindsym r exec swaymsg 'mode "default"' && grim -t ppm -g "$(slurp -d)" - | $satty
          bindsym f exec swaymsg 'mode "default"' && grim -t ppm - | $satty
          bindsym w exec swaymsg 'mode "default"' && swaymsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | grim -t ppm -g - - | $satty

          bindsym Return mode "default"
          bindsym Escape mode "default"
      }
      bindsym $mod+Shift+Print mode $printscreen_mode
          
      #
      # Layout stuff:
      #
          # You can "split" the current object of your focus with
          # $mod+b or $mod+v, for horizontal and vertical splits
          # respectively.
          bindsym $mod+b splith
          bindsym $mod+v splitv

          # Switch the current container between different layout styles
          bindsym $mod+Shift+s layout stacking
          bindsym $mod+w layout tabbed
          bindsym $mod+e layout toggle split

          # Make the current focus fullscreen
          bindsym $mod+f fullscreen

          # Toggle the current focus between tiling and floating mode
          bindsym $mod+Shift+f floating toggle

          # Swap focus between the tiling area and the floating area
          bindsym $mod+Return focus mode_toggle

          # Move focus to the parent container
          bindsym $mod+a focus parent
      #
      # Scratchpad:
      #
          # Sway has a "scratchpad", which is a bag of holding for windows.
          # You can send windows there and get them back later.

          # Move the currently focused window to the scratchpad
          bindsym $mod+Shift+minus move scratchpad

          # Show the next scratchpad window or hide the focused scratchpad window.
          # If there are multiple scratchpad windows, this command cycles through them.
          bindsym $mod+minus scratchpad show
      #
      # Resizing containers:
      #
      mode "resize" {
          # left will shrink the containers width
          # right will grow the containers width
          # up will shrink the containers height
          # down will grow the containers height
          bindsym $left resize shrink width 10px
          bindsym $down resize grow height 10px
          bindsym $up resize shrink height 10px
          bindsym $right resize grow width 10px

          # Ditto, with arrow keys
          bindsym Left resize shrink width 10px
          bindsym Down resize grow height 10px
          bindsym Up resize shrink height 10px
          bindsym Right resize grow width 10px

          # Return to default mode
          bindsym Return mode "default"
          bindsym Escape mode "default"
      }
      bindsym $mod+r mode "resize"

      #
      # Status Bar:
      #
      # Read `man 5 sway-bar` for more information about this section.
      bar {
          position top

          # When the status_command prints a new line to stdout, swaybar updates.
          # The default just shows the current date and time.
      #   status_command while date +'%Y-%m-%d %X'; do sleep 1; done

          status_command i3status-rs ~/.config/i3status-rust/config-default.toml;


          colors {
              statusline ${if cfg.enableStylix then config.lib.stylix.colors.base05 else "#ffffff"}
              background ${if cfg.enableStylix then config.lib.stylix.colors.base00 else "#323232"}
              inactive_workspace ${if cfg.enableStylix then config.lib.stylix.colors.base02 else "#32323277"} ${if cfg.enableStylix then config.lib.stylix.colors.base01 else "#32323244"} ${if cfg.enableStylix then config.lib.stylix.colors.base05 else "#5c5c5c"}
              active_workspace ${if cfg.enableStylix then config.lib.stylix.colors.base0D else "#ffffff"} ${if cfg.enableStylix then config.lib.stylix.colors.base0D else "#ffffff"} ${if cfg.enableStylix then config.lib.stylix.colors.base05 else "#ffffff"}
              urgent_workspace ${if cfg.enableStylix then config.lib.stylix.colors.base08 else "#ff0000"} ${if cfg.enableStylix then config.lib.stylix.colors.base08 else "#ff0000"} ${if cfg.enableStylix then config.lib.stylix.colors.base00 else "#ffffff"}
          }
      }

             include @sysconfdir@/sway/config.d/*
     '';
   };
 }
