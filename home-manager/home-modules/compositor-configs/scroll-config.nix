{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.programs.scroll;
  sessionEnabled = config.sessionProfiles.scroll.enable or false;
  inherit (lib) mkEnableOption mkIf mkOption types;

  # Kirigami QML path for Noctalia (workaround for libplasma override issue)
  kirigamiQmlPath = "${lib.getLib pkgs.kdePackages.kirigami}/lib/qt-6/qml";
in
{
  options.programs.scroll = {
    enable = mkEnableOption "Scroll compositor (Sway fork with scrolling layout)";

    enableStylix = mkEnableOption "Enable Stylix theming integration for Scroll";

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra configuration to append to scroll config";
    };
  };

  config = mkIf (cfg.enable && sessionEnabled) {
    home.packages = with pkgs; [
      wl-clipboard
      grim
      slurp
      wf-recorder
      playerctl
      brightnessctl
      fuzzel
      anyrun
      jq
    ];

    home.file.".config/scroll/config".text = ''
      # Scroll compositor configuration
      # Sway-compatible config with scrolling layout extensions
      # Read `man 5 scroll` for a complete reference

      ### Include NixOS system snippets (required for D-Bus/systemd integration)
      include /etc/scroll/config.d/*

      ### Variables
      set $mod Mod4
      set $left h
      set $down j
      set $up k
      set $right l
      set $term kitty
      set $menu fuzzel

      input type:keyboard xkb_numlock enabled

      ### Cursor theming
      ${if cfg.enableStylix then "seat * xcursor_theme ${config.stylix.cursor.name} ${toString config.stylix.cursor.size}" else ""}

      ### Scroll-specific layout settings
      layout_default_width 0.5
      layout_default_height 1.0
      layout_widths [0.333 0.5 0.667 0.75 0.8 0.9 1.0]
      layout_heights [0.333 0.5 0.667 0.75 1.0]
      align_reset_auto true
      cycle_size_wrap false
      maximize_if_single false
      fullscreen_movefocus true nofollow
      fullscreen_on_request layout
      xwayland_output_scale true

      ### Gesture scrolling (trackpad)
      gesture_scroll_enable true
      gesture_scroll_fingers 3
      gesture_scroll_sensitivity 1.0

      ### Jump labels (easymotion)
      jump_labels_keys 1234567890abcdef
      jump_labels_scale 0.5
      ${if cfg.enableStylix then ''
      jump_labels_color #${config.lib.stylix.colors.base0D}CC
      jump_labels_background #${config.lib.stylix.colors.base00}DD
      '' else ''
      jump_labels_color #159E3080
      jump_labels_background #000000CC
      ''}

      ### Animations
      animations {
          enabled yes
          frequency_ms 16
          style scale
          default yes 300 var 3 [ 0.215 0.61 0.355 1 ]
          window_open yes 250 var 3 [ 0 0 1 1 ]
          window_move yes 300 var 3 [ 0.215 0.61 0.355 1 ]
          window_size yes 300 var 3 [ -0.35 0 0 0.5 ]
          workspace_switch yes 400 var simple [ 0.215 0.61 0.355 1 ]
          window_fullscreen yes 400 var simple [ 0.3 0.5 0.4 1 ]
      }

      ### Decorations
      ${if cfg.enableStylix then ''
      default_decoration border_radius 6 shadow true shadow_dynamic true shadow_size 30 shadow_blur 20 shadow_offset 5 5 shadow_color #${config.lib.stylix.colors.base01}70 dim false
      '' else ''
      default_decoration border_radius 6 shadow true shadow_dynamic true shadow_size 30 shadow_blur 20 shadow_offset 5 5 shadow_color #00000070 dim false
      ''}
      titlebar_border_radius 6

      ### Borders and gaps
      default_border pixel 3
      default_floating_border pixel 2
      gaps inner 5
      gaps outer 10

      ### Colors
      ${if cfg.enableStylix then ''
      # Stylix-generated colors
      client.focused          #${config.lib.stylix.colors.base0D} #${config.lib.stylix.colors.base0D} #${config.lib.stylix.colors.base00} #${config.lib.stylix.colors.base0E} #${config.lib.stylix.colors.base0D}
      client.focused_inactive #${config.lib.stylix.colors.base02} #${config.lib.stylix.colors.base02} #${config.lib.stylix.colors.base05} #${config.lib.stylix.colors.base03} #${config.lib.stylix.colors.base02}
      client.unfocused        #${config.lib.stylix.colors.base01} #${config.lib.stylix.colors.base01} #${config.lib.stylix.colors.base05} #${config.lib.stylix.colors.base03} #${config.lib.stylix.colors.base01}
      client.urgent           #${config.lib.stylix.colors.base08} #${config.lib.stylix.colors.base08} #${config.lib.stylix.colors.base00} #${config.lib.stylix.colors.base08} #${config.lib.stylix.colors.base08}
      # Scroll-specific color classes
      client.pinned           #${config.lib.stylix.colors.base0E} #${config.lib.stylix.colors.base0E} #${config.lib.stylix.colors.base00} #${config.lib.stylix.colors.base0E} #${config.lib.stylix.colors.base0E}
      client.pinned_focused   #${config.lib.stylix.colors.base0D} #${config.lib.stylix.colors.base0E} #${config.lib.stylix.colors.base00} #${config.lib.stylix.colors.base0D} #${config.lib.stylix.colors.base0D}
      client.selected         #${config.lib.stylix.colors.base0A} #${config.lib.stylix.colors.base0A} #${config.lib.stylix.colors.base00} #${config.lib.stylix.colors.base0A} #${config.lib.stylix.colors.base0A}
      client.selected_focused #${config.lib.stylix.colors.base0D} #${config.lib.stylix.colors.base0A} #${config.lib.stylix.colors.base00} #${config.lib.stylix.colors.base0E} #${config.lib.stylix.colors.base0D}
      '' else ''
      client.focused          #4c7899 #285577 #ffffff #2e9ef4 #285577
      client.focused_inactive #333333 #5f676a #ffffff #484e50 #5f676a
      client.unfocused        #333333 #222222 #888888 #292d2e #222222
      client.urgent           #2f343a #900000 #ffffff #900000 #900000
      ''}

      ### Focus behavior
      focus_wrapping no
      focus_follows_mouse yes

      ### Output configuration
      ${if cfg.enableStylix then "output * bg ${config.stylix.image} fill" else "output * bg ~/.config/wallpapers/wallpaper.jpg fill"}

      # Generic display fallbacks
      output HDMI-A-1 resolution 1920x1080 position 1920,0
      output eDP-1 resolution 3240x2160 position 0,0 scale 2
      output DP-1 resolution 1920x1080 position 1620,0

      # Specific display configurations by make/model/serial
      output "LG Electronics LG ULTRAWIDE 308NTTQD5209" resolution 3440x1440@160Hz position 0,0
      output "Ancor Communications Inc ASUS VS228 E8LMQS044730" resolution 1920x1080 position 3440,0

      workspace 1 output eDP-1
      workspace 1 output "LG Electronics LG ULTRAWIDE 308NTTQD5209"

      ### Input configuration
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

      ### Idle configuration
      exec swayidle -w \
              timeout 3000 'swaylock -f -c ${if cfg.enableStylix then config.lib.stylix.colors.base00 else "000000"}' \
              timeout 6000 'scrollmsg "output * power off"' resume 'scrollmsg "output * power on"' \
              before-sleep 'swaylock -f -c ${if cfg.enableStylix then config.lib.stylix.colors.base00 else "000000"}'

      ### Startup applications
      # Launch Noctalia with QML path set (fixes libplasma kirigami override)
      exec QML2_IMPORT_PATH="${kirigamiQmlPath}" noctalia-shell
      exec pcloud

      ### Floating modifier
      floating_modifier $mod normal

      #############################################################################
      ### Key bindings - Basics (Niri-style)
      #############################################################################

      # Terminal
      bindsym $mod+s exec $term

      # Kill focused window
      bindsym $mod+q kill

      # Application launchers
      bindsym $mod+space exec $menu
      bindsym alt+space exec anyrun
      bindsym $mod+grave exec fuzzel

      # Lock screen
      bindsym $mod+Escape exec swaylock -f -c ${if cfg.enableStylix then config.lib.stylix.colors.base00 else "000000"}

      # Reload config
      bindsym $mod+Shift+c reload

      # Exit Scroll
      bindsym $mod+Shift+e exec scrollnag -t warning -m 'Exit Scroll? This will end your Wayland session.' -B 'Yes, exit' 'scrollmsg exit'

      #############################################################################
      ### Focus navigation
      #############################################################################

      # Arrow keys - focus between columns (left/right) and within column (up/down)
      bindsym $mod+Left focus left
      bindsym $mod+Right focus right
      bindsym $mod+Up focus up
      bindsym $mod+Down focus down

      # Vim keys - same mapping
      bindsym $mod+$left focus left
      bindsym $mod+$right focus right
      bindsym $mod+$up focus up
      bindsym $mod+$down focus down

      # Beginning/end of row (Scroll extension)
      bindsym $mod+Home focus beginning
      bindsym $mod+End focus end

      # Focus parent/child
      bindsym $mod+a focus parent

      # Toggle focus between tiling and floating
      bindsym $mod+Return focus mode_toggle

      #############################################################################
      ### Window movement
      #############################################################################

      # Arrow keys
      bindsym $mod+Shift+Left move left
      bindsym $mod+Shift+Right move right
      bindsym $mod+Shift+Up move up
      bindsym $mod+Shift+Down move down

      # Vim keys
      bindsym $mod+Shift+$left move left
      bindsym $mod+Shift+$right move right
      bindsym $mod+Shift+$up move up
      bindsym $mod+Shift+$down move down

      # Move to beginning/end (Scroll extension)
      bindsym $mod+Shift+Home move beginning
      bindsym $mod+Shift+End move end

      #############################################################################
      ### Workspaces
      #############################################################################

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

      # Navigate workspaces
      bindsym $mod+Ctrl+Left workspace prev
      bindsym $mod+Ctrl+Right workspace next

      # Move container to next/prev workspace
      bindsym $mod+Ctrl+Shift+Left move container to workspace prev; workspace prev
      bindsym $mod+Ctrl+Shift+Right move container to workspace next; workspace next

      #############################################################################
      ### Floating and fullscreen
      #############################################################################

      # Toggle floating
      bindsym $mod+Shift+Return floating toggle

      # Fullscreen modes (Scroll has multiple types)
      # Layout fullscreen: fills the visible area while respecting layout
      bindsym $mod+f fullscreen toggle layout
      # Global fullscreen: covers entire output
      bindsym $mod+Shift+f fullscreen toggle global

      #############################################################################
      ### Scroll-specific: Layout mode (from Hyprscroller)
      #############################################################################

      # Toggle horizontal/vertical layout (like Hyprscroller setmode)
      bindsym $mod+bracketleft set_mode h
      bindsym $mod+bracketright set_mode v
      bindsym $mod+n layout_transpose

      #############################################################################
      ### Scroll-specific: Column/window sizing (from Hyprscroller)
      #############################################################################

      # Cycle through preset column widths (like Hyprscroller cyclewidth)
      bindsym $mod+equal cycle_size h next
      bindsym $mod+minus cycle_size h prev

      # Cycle through preset window heights (like Hyprscroller cycleheight)
      # Uses Alt modifier to avoid conflict with scratchpad on Shift+minus
      bindsym $mod+Alt+equal cycle_size v next
      bindsym $mod+Alt+minus cycle_size v prev

      # Set exact sizes
      # bindsym $mod+Ctrl+1 set_size h 0.333
      # bindsym $mod+Ctrl+2 set_size h 0.5
      # bindsym $mod+Ctrl+3 set_size h 0.667
      # bindsym $mod+Ctrl+4 set_size h 0.8
      # bindsym $mod+Ctrl+5 set_size h 1.0

      # Toggle size (maximize toggle for focused window)
      # Uses Ctrl+Shift+f to avoid conflict with mark_delete mode on Shift+m
      bindsym $mod+Ctrl+Shift+f toggle_size active 1.0 1.0

      #############################################################################
      ### Scroll-specific: Align mode (from Hyprscroller alignwindow)
      #############################################################################

      mode "align" {
          bindsym c align center; mode "default"
          bindsym m align middle; mode "default"
          bindsym Left align left; mode "default"
          bindsym Right align right; mode "default"
          bindsym Up align up; mode "default"
          bindsym Down align down; mode "default"
          bindsym r align reset; mode "default"
          bindsym Escape mode "default"
          bindsym Return mode "default"
      }
      bindsym $mod+c mode "align"

      #############################################################################
      ### Scroll-specific: Fit size mode (from Hyprscroller fitsize)
      #############################################################################

      mode "fit_size" {
          # Horizontal fit operations
          bindsym g fit_size h visible; mode "default"
          bindsym Right fit_size h toend; mode "default"
          bindsym Left fit_size h tobeg; mode "default"
          bindsym Up fit_size h active; mode "default"
          bindsym Down fit_size h all; mode "default"
          # Vertical fit operations
          bindsym Shift+g fit_size v visible; mode "default"
          bindsym Shift+Up fit_size v active; mode "default"
          bindsym Shift+Down fit_size v all; mode "default"
          bindsym Escape mode "default"
          bindsym Return mode "default"
      }
      bindsym $mod+g mode "fit_size"

      #############################################################################
      ### Scroll-specific: Overview and Jump (from Hyprscroller)
      #############################################################################

      # Overview mode (like Hyprscroller toggleoverview)
      bindsym $mod+w scale_workspace overview

      # Jump/easymotion (like Hyprscroller jump)
      bindsym $mod+Tab jump
      bindsym $mod+Shift+Tab jump workspaces

      #############################################################################
      ### Scroll-specific: Pin (from Hyprscroller pin)
      #############################################################################

      # Pin column to beginning/end of workspace
      bindsym $mod+p pin beginning
      bindsym $mod+Shift+p pin end

      #############################################################################
      ### Scroll-specific: Selection (from Hyprscroller selection)
      #############################################################################

      # Multi-window selection for batch operations
      bindsym $mod+Insert selection toggle
      bindsym $mod+Ctrl+Insert selection reset
      bindsym $mod+Shift+Insert selection move

      #############################################################################
      ### Scroll-specific: Trails (from Hyprscroller trails)
      #############################################################################

      mode "trail" {
          bindsym bracketright trail next
          bindsym bracketleft trail prev
          bindsym semicolon trail new; mode "default"
          bindsym n trail new; mode "default"
          bindsym d trail delete; mode "default"
          bindsym c trail clear; mode "default"
          bindsym Insert trail to_selection; mode "default"
          bindsym 1 trail number 1; mode "default"
          bindsym 2 trail number 2; mode "default"
          bindsym 3 trail number 3; mode "default"
          bindsym Escape mode "default"
          bindsym Return mode "default"
      }
      bindsym $mod+Shift+semicolon mode "trail"

      mode "trailmark" {
          bindsym bracketright trailmark next
          bindsym bracketleft trailmark prev
          bindsym semicolon trailmark toggle; mode "default"
          bindsym j trailmark jump; mode "default"
          bindsym Escape mode "default"
          bindsym Return mode "default"
      }
      bindsym $mod+semicolon mode "trailmark"

      #############################################################################
      ### Scroll-specific: Marks (standard Sway marks, Hyprscroller-inspired)
      #############################################################################

      mode "mark_add" {
          bindsym a mark a; mode "default"
          bindsym b mark b; mode "default"
          bindsym c mark c; mode "default"
          bindsym d mark d; mode "default"
          bindsym e mark e; mode "default"
          bindsym Escape mode "default"
      }
      bindsym $mod+m mode "mark_add"

      mode "mark_visit" {
          bindsym a [con_mark="a"] focus; mode "default"
          bindsym b [con_mark="b"] focus; mode "default"
          bindsym c [con_mark="c"] focus; mode "default"
          bindsym d [con_mark="d"] focus; mode "default"
          bindsym e [con_mark="e"] focus; mode "default"
          bindsym Escape mode "default"
      }
      bindsym $mod+apostrophe mode "mark_visit"

      mode "mark_delete" {
          bindsym a unmark a; mode "default"
          bindsym b unmark b; mode "default"
          bindsym c unmark c; mode "default"
          bindsym d unmark d; mode "default"
          bindsym e unmark e; mode "default"
          bindsym Escape mode "default"
      }
      bindsym $mod+Shift+m mode "mark_delete"

      #############################################################################
      ### Scroll-specific: Spaces (workspace save/restore)
      #############################################################################

      mode "space" {
          bindsym s exec scrollmsg space save "$(scrollmsg -t get_workspaces | jq -r '.[] | select(.focused) | .name')"; mode "default"
          bindsym l exec scrollmsg space load "$(scrollmsg -t get_workspaces | jq -r '.[] | select(.focused) | .name')"; mode "default"
          bindsym r exec scrollmsg space restore "$(scrollmsg -t get_workspaces | jq -r '.[] | select(.focused) | .name')"; mode "default"
          bindsym Escape mode "default"
      }
      bindsym $mod+Shift+space mode "space"

      #############################################################################
      ### Resize mode
      #############################################################################

      mode "resize" {
          bindsym $left resize shrink width 10px
          bindsym $down resize grow height 10px
          bindsym $up resize shrink height 10px
          bindsym $right resize grow width 10px

          bindsym Left resize shrink width 10px
          bindsym Down resize grow height 10px
          bindsym Up resize shrink height 10px
          bindsym Right resize grow width 10px

          bindsym Return mode "default"
          bindsym Escape mode "default"
      }
      bindsym $mod+r mode "resize"

      #############################################################################
      ### Scratchpad
      #############################################################################

      # Move to scratchpad
      bindsym $mod+Shift+minus move scratchpad
      # Show scratchpad
      bindsym $mod+Ctrl+minus scratchpad show
      # Scratchpad jump (Scroll extension - overview of scratchpad)
      bindsym $mod+Ctrl+Shift+minus scratchpad jump

      #############################################################################
      ### Content scaling (Scroll extension)
      #############################################################################

      # Uses Ctrl+bracketright/left to avoid conflict with scratchpad on Ctrl+minus
      bindsym $mod+Ctrl+bracketright scale_content incr 0.1
      bindsym $mod+Ctrl+bracketleft scale_content incr -0.1
      bindsym $mod+Ctrl+0 scale_content reset

      #############################################################################
      ### Gestures
      #############################################################################

      # 4-finger swipe for workspace navigation
      bindgesture swipe:4:left workspace next
      bindgesture swipe:4:right workspace prev

      # 3-finger swipe for focus navigation (scrolling through columns)
      bindgesture swipe:3:left focus right
      bindgesture swipe:3:right focus left
      bindgesture swipe:3:up scale_workspace overview
      bindgesture swipe:3:down scale_workspace overview

      #############################################################################
      ### Screenshots with Satty
      #############################################################################

      set $satty satty -f - --output-filename ${config.home.homeDirectory}/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png

      # Region screenshot
      bindsym Print exec grim -g "$(slurp -d)" -t ppm - | $satty
      # Full output screenshot
      bindsym $mod+Print exec grim -t ppm - | $satty
      # Focused window screenshot
      bindsym Ctrl+Print exec scrollmsg -t get_tree | jq -r '.. | select(.focused?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | grim -t ppm -g - - | $satty

      #############################################################################
      ### System controls
      #############################################################################

      bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindsym XF86AudioLowerVolume exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-
      bindsym XF86AudioRaiseVolume exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
      bindsym XF86AudioMicMute exec pactl set-source-mute @DEFAULT_SOURCE@ toggle
      bindsym XF86MonBrightnessDown exec brightnessctl set 5%-
      bindsym XF86MonBrightnessUp exec brightnessctl set 5%+
      bindsym XF86AudioPlay exec playerctl play-pause
      bindsym XF86AudioNext exec playerctl next
      bindsym XF86AudioPrev exec playerctl previous

      #############################################################################
      ### Voice dictation
      #############################################################################

      # Momentary push-to-talk
      bindsym --no-repeat $mod+x exec "dictate-fw-ptt-auto 5"
      bindsym --no-repeat $mod+Shift+x exec "dictate-wc-ptt-auto 5"

      # Toggle dictation
      bindsym --no-repeat $mod+backslash exec "dictate-fw-ptt-toggle"
      bindsym --no-repeat $mod+Shift+backslash exec "dictate-wc-ptt-toggle"

      #############################################################################
      ### Wooz screen magnifier
      #############################################################################

      bindsym $mod+z exec "wooz --zoom-in 10% --mouse-track"

      #############################################################################
      ### Animations toggle
      #############################################################################

      bindsym $mod+Shift+a animations_enable toggle

      #############################################################################
      ### Workspace split (for ultrawide monitors)
      #############################################################################

      # Uncomment and adjust for ultrawide monitors:
      # bindsym $mod+Shift+w workspace split h 0.5 10
      # bindsym $mod+Ctrl+w workspace split reset

      #############################################################################
      ### Bar (disabled - using Noctalia desktop shell)
      #############################################################################

      # bar {
      #     position top
      #     status_command i3status-rs
      # }

      #############################################################################
      ### Extra user configuration
      #############################################################################

      ${cfg.extraConfig}
    '';
  };
}
