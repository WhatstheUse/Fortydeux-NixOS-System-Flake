{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.programs.mangowc;
  sessionEnabled = config.sessionProfiles.mangowc.enable or false;
  inherit (lib) mkEnableOption mkIf mkOption types;

  # Kirigami QML path for Noctalia (workaround for libplasma override issue)
  kirigamiQmlPath = "${lib.getLib pkgs.kdePackages.kirigami}/lib/qt-6/qml";

  # Workaround for MangoWC reload_config bug (reapply_monitor_rules uses
  # uninitialized wlr_output_state for 2nd+ monitors). Re-apply scale/position
  # via wlr-randr after reload to restore correct display settings.
  reloadScript = pkgs.writeShellScript "mango-reload" ''
    mmsg -d reload_config
    sleep 0.3
    # Re-apply monitor settings that reload_config may have reset
    if wlr-randr 2>/dev/null | grep -q "eDP-1"; then
      wlr-randr --output eDP-1 --scale 2
    fi
  '';
in
{
  options.programs.mangowc = {
    enable = mkEnableOption "MangoWC compositor";

    enableStylix = mkEnableOption "Enable Stylix theming integration for MangoWC";

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra configuration to append to MangoWC config";
    };
  };

  config = mkIf (cfg.enable && sessionEnabled) {

    home.packages = with pkgs; [
      wl-clipboard
      grim
      slurp
      playerctl
      brightnessctl
      fuzzel
      anyrun
    ];

    # MangoWC autostart script
    home.file.".config/mango/autostart.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash

        # Import environment for systemd/dbus
        systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
        systemctl --user start --no-block xdg-desktop-portal-kde.service

        # Wallpaper
        swaybg -m fill -i ${config.stylix.image} &

        # Notification daemon
        mako &

        # Idle management
        swayidle -w \
          timeout 300 'swaylock -f -c 000000' \
          timeout 600 'swaymsg "output * power off"' \
            resume 'swaymsg "output * power on"' \
          before-sleep 'swaylock -f -c 000000' &

        # Cloud sync (wait for graphical session)
        (while ! systemctl --user is-active graphical-session.target; do sleep 0.5; done && pcloud) &
      '';
    };

    # MangoWC configuration
    home.file.".config/mango/config.conf".text = ''
      # MangoWC Configuration
      # dwl/wlroots-based Wayland compositor
      # Keybindings modeled after Niri

      # ========================================
      # Environment variables
      # ========================================
      env=QML2_IMPORT_PATH,${kirigamiQmlPath}
      env=XCURSOR_THEME,${if cfg.enableStylix then config.stylix.cursor.name else "phinger-cursors-light"}
      env=XCURSOR_SIZE,${if cfg.enableStylix then toString config.stylix.cursor.size else "32"}
      env=MOZ_ENABLE_WAYLAND,1
      env=SDL_VIDEODRIVER,wayland
      env=QT_QPA_PLATFORM,wayland
      env=QT_WAYLAND_DISABLE_WINDOWDECORATION,1
      env=_JAVA_AWT_WM_NONREPARENTING,1

      # ========================================
      # Autostart
      # ========================================
      exec-once=bash ~/.config/mango/autostart.sh
      exec-once=noctalia-shell

      # ========================================
      # Monitor configuration
      # ========================================
      # Discover connected monitors and their native modes with: mmsg -O or wlr-randr
      # Format: monitorrule=name:NAME,width:W,height:H,refresh:R,x:X,y:Y,scale:S
      # Note: 'name' supports regex. Never use negative x/y coordinates.
      # Rules only apply when the named monitor is connected.

      # Surface Book 2 15" laptop display (archerfish/killifish)
      # Native: 3240x2160; at scale 2, logical width = 1620
      monitorrule=name:eDP-1,width:3240,height:2160,refresh:60,x:0,y:0,scale:2

      # External monitor via dock (reported as DP-1 on archerfish)
      # Sceptre F27 1920x1080; positioned right of eDP-1 logical edge
      monitorrule=name:DP-1,width:1920,height:1080,refresh:75,x:1620,y:0,scale:1

      # Secondary monitor via HDMI (for setups where external reports as HDMI-A-1)
      monitorrule=name:HDMI-A-1,width:1920,height:1080,refresh:60,x:1620,y:0,scale:1

      # ========================================
      # General settings
      # ========================================
      borderpx=2
      gappih=5
      gappiv=5
      gappoh=10
      gappov=10
      border_radius=6

      # Colors (0xRRGGBBAA format)
      focuscolor=${if cfg.enableStylix then "0x${config.lib.stylix.colors.base0D}ff" else "0x33ccffff"}
      bordercolor=${if cfg.enableStylix then "0x${config.lib.stylix.colors.base01}ff" else "0x595959ff"}
      rootcolor=${if cfg.enableStylix then "0x${config.lib.stylix.colors.base00}ff" else "0x002b36ff"}
      urgentcolor=${if cfg.enableStylix then "0x${config.lib.stylix.colors.base08}ff" else "0xad401fff"}
      scratchpadcolor=${if cfg.enableStylix then "0x${config.lib.stylix.colors.base0E}ff" else "0x516c93ff"}

      # Cursor
      cursor_size=${if cfg.enableStylix then toString config.stylix.cursor.size else "32"}
      cursor_theme=${if cfg.enableStylix then config.stylix.cursor.name else "phinger-cursors-light"}

      # Focus and cursor behavior
      sloppyfocus=1
      warpcursor=1
      cursor_hide_timeout=5
      focus_cross_monitor=1
      view_current_to_back=1

      # Layout
      default_mfact=0.55
      default_nmaster=1
      smartgaps=0
      new_is_master=1
      no_border_when_single=1
      circle_layout=tile,scroller,monocle,grid

      # Scroller layout settings
      scroller_default_proportion=0.9
      scroller_focus_center=0
      scroller_prefer_overspread=1
      scroller_proportion_preset=0.5,0.8,1.0

      # ========================================
      # Input configuration
      # ========================================
      repeat_rate=50
      repeat_delay=600
      xkb_rules_layout=us

      # Touchpad
      tap_to_click=1
      trackpad_natural_scrolling=1
      disable_while_typing=1
      click_method=2
      drag_lock=1

      # Mouse
      mouse_natural_scrolling=1
      accel_profile=2
      accel_speed=0.0

      # Floating window snapping
      enable_floating_snap=1
      snap_distance=30

      # ========================================
      # Animations
      # ========================================
      animations=1
      layer_animations=1
      animation_type_open=zoom
      animation_type_close=slide
      animation_duration_open=400
      animation_duration_close=300
      animation_duration_move=500
      animation_duration_tag=300

      # ========================================
      # Window effects
      # ========================================
      shadows=1
      shadow_only_floating=1
      shadows_size=10
      shadows_blur=15
      shadowscolor=${if cfg.enableStylix then "0x${config.lib.stylix.colors.base00}70" else "0x00000070"}

      focused_opacity=1.0
      unfocused_opacity=1.0

      # ========================================
      # Overview
      # ========================================
      enable_hotarea=1
      hotarea_size=10
      overviewgappi=5
      overviewgappo=30

      # ========================================
      # Tag rules (per-tag default layouts)
      # ========================================
      tagrule=id:1,layout_name:tile
      tagrule=id:2,layout_name:tile
      tagrule=id:3,layout_name:scroller

      # ========================================
      # Window rules
      # ========================================
      # Float dialog-like apps
      windowrule=isfloating:1,appid:pavucontrol
      windowrule=isfloating:1,appid:nm-connection-editor
      windowrule=isfloating:1,appid:blueman-manager
      windowrule=isfloating:1,appid:xdg-desktop-portal-gtk
      windowrule=isfloating:1,appid:wleave
      windowrule=isfloating:1,appid:wlogout

      # Terminal swallowing (GUI apps launched from terminal absorb it)
      windowrule=isterm:1,appid:kitty
      windowrule=isterm:1,appid:foot
      windowrule=isterm:1,appid:footclient
      windowrule=isterm:1,appid:Alacritty

      # Float foot as a dropdown-style terminal (matches Niri config)
      windowrule=isfloating:1,appid:foot
      windowrule=isfloating:1,appid:footclient

      # Per-app opacity
      windowrule=unfocused_opacity:0.95,appid:kitty
      windowrule=unfocused_opacity:0.95,appid:foot

      # ========================================
      # Keybindings (modeled after Niri config)
      # ========================================

      # Terminal
      bind=SUPER,S,spawn,kitty

      # Close window
      bind=SUPER,Q,killclient,

      # Application launchers
      bind=SUPER,space,spawn,fuzzel
      bind=ALT,space,spawn,anyrun

      # Lock screen
      bind=SUPER,Escape,spawn_shell,swaylock -f -c 000000

      # Overview
      bind=SUPER,W,toggleoverview,0

      # Quit compositor
      bind=SUPER+SHIFT,E,quit,

      # Reload config (uses wrapper script to work around monitor reset bug)
      bind=SUPER,R,spawn,${reloadScript}

      # Focus last window (Alt-Tab equivalent)
      bind=SUPER,Tab,focuslast,
      bind=ALT,Tab,toggleoverview,0

      # ---- Focus navigation ----
      # Arrow keys
      bind=SUPER,Left,focusdir,left
      bind=SUPER,Down,focusdir,down
      bind=SUPER,Up,focusdir,up
      bind=SUPER,Right,focusdir,right

      # Vim-style: J/K for stack navigation, H/L for master ratio
      bind=SUPER,J,focusstack,next
      bind=SUPER,K,focusstack,prev
      bind=SUPER,H,setmfact,-0.05
      bind=SUPER,L,setmfact,+0.05

      # ---- Move/swap windows ----
      # Arrow keys
      bind=SUPER+SHIFT,Left,exchange_client,left
      bind=SUPER+SHIFT,Down,exchange_client,down
      bind=SUPER+SHIFT,Up,exchange_client,up
      bind=SUPER+SHIFT,Right,exchange_client,right

      # Vim-style: Shift+J/K swap in stack, Shift+H/L adjust master count
      bind=SUPER+SHIFT,J,exchange_client,down
      bind=SUPER+SHIFT,K,exchange_client,up
      bind=SUPER+SHIFT,H,incnmaster,1
      bind=SUPER+SHIFT,L,incnmaster,-1

      # Swap with master
      bind=SUPER,grave,zoom,

      # ---- Window state ----
      bind=SUPER,Return,togglefloating,
      bind=SUPER+SHIFT,F,togglefullscreen,
      bind=SUPER,F,togglemaximizescreen,
      bind=SUPER,G,toggleglobal,
      bind=SUPER,O,toggleoverlay,
      bind=SUPER,C,centerwin,

      # ---- Tags 1-9 ----
      bind=SUPER,1,view,1,0
      bind=SUPER,2,view,2,0
      bind=SUPER,3,view,3,0
      bind=SUPER,4,view,4,0
      bind=SUPER,5,view,5,0
      bind=SUPER,6,view,6,0
      bind=SUPER,7,view,7,0
      bind=SUPER,8,view,8,0
      bind=SUPER,9,view,9,0

      # Move window to tag
      bind=SUPER+CTRL,1,tag,1,0
      bind=SUPER+CTRL,2,tag,2,0
      bind=SUPER+CTRL,3,tag,3,0
      bind=SUPER+CTRL,4,tag,4,0
      bind=SUPER+CTRL,5,tag,5,0
      bind=SUPER+CTRL,6,tag,6,0
      bind=SUPER+CTRL,7,tag,7,0
      bind=SUPER+CTRL,8,tag,8,0
      bind=SUPER+CTRL,9,tag,9,0

      # Previous/next tag (skip empty tags)
      bind=SUPER+CTRL,Left,viewtoleft_have_client,0
      bind=SUPER+CTRL,Right,viewtoright_have_client,0

      # ---- Monitor focus ----
      bind=ALT+CTRL,Left,focusmon,left
      bind=ALT+CTRL,Down,focusmon,down
      bind=ALT+CTRL,Up,focusmon,up
      bind=ALT+CTRL,Right,focusmon,right

      # Move window to monitor
      bind=ALT+SHIFT+CTRL,Left,tagmon,left
      bind=ALT+SHIFT+CTRL,Down,tagmon,down
      bind=ALT+SHIFT+CTRL,Up,tagmon,up
      bind=ALT+SHIFT+CTRL,Right,tagmon,right

      # ---- Layout ----
      bind=SUPER,N,switch_layout,
      bind=SUPER+SHIFT,N,setlayout,tile

      # Scroller layout controls
      bind=SUPER,E,switch_proportion_preset,
      bind=SUPER+SHIFT,E,set_proportion,1.0

      # Dynamic gaps
      bind=SUPER,equal,incgaps,1
      bind=SUPER,minus,incgaps,-1
      bind=SUPER+SHIFT,equal,togglegaps,

      # ---- Scratchpad ----
      bind=SUPER,P,toggle_scratchpad,
      bind=SUPER+SHIFT,P,minimized,
      bind=SUPER+SHIFT,I,restore_minimized,

      # ---- Voice dictation - Momentary ----
      bind=SUPER,X,spawn_shell,dictate-fw-ptt-auto 5
      bind=SUPER+SHIFT,X,spawn_shell,dictate-wc-ptt-auto 5

      # ---- Voice dictation - Toggle ----
      bind=SUPER,backslash,spawn,dictate-fw-ptt-toggle
      bind=SUPER+SHIFT,backslash,spawn,dictate-wc-ptt-toggle

      # ---- Wooz screen magnifier ----
      bind=SUPER,Z,spawn_shell,wooz --zoom-in 10% --mouse-track

      # ---- Screenshots (with Satty) ----
      bind=NONE,Print,spawn,screenshot-region
      bind=CTRL,Print,spawn,screenshot-output
      bind=SUPER,Print,spawn,screenshot-output
      bind=SUPER+SHIFT,Print,spawn,screenshot-window

      # ---- Volume / Brightness / Media (work when locked) ----
      bindl=NONE,XF86AudioRaiseVolume,spawn_shell,wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+
      bindl=NONE,XF86AudioLowerVolume,spawn_shell,wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-
      bindl=NONE,XF86AudioMute,spawn_shell,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      bindl=NONE,XF86AudioMicMute,spawn_shell,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
      bindl=NONE,XF86AudioPlay,spawn_shell,playerctl play-pause
      bindl=NONE,XF86AudioNext,spawn_shell,playerctl next
      bindl=NONE,XF86AudioPrev,spawn_shell,playerctl previous
      bindl=NONE,XF86MonBrightnessUp,spawn_shell,brightnessctl set 5%+
      bindl=NONE,XF86MonBrightnessDown,spawn_shell,brightnessctl set 5%-

      # ---- Mouse bindings ----
      mousebind=SUPER,btn_left,moveresize,curmove
      mousebind=SUPER,btn_right,moveresize,curresize
      mousebind=SUPER,btn_middle,togglefloating,

      # ---- Scroll wheel bindings (tag navigation) ----
      axisbind=SUPER,UP,viewtoleft_have_client,0
      axisbind=SUPER,DOWN,viewtoright_have_client,0
      axisbind=SUPER+SHIFT,UP,tagtoleft,0
      axisbind=SUPER+SHIFT,DOWN,tagtoright,0

      # ---- Touchpad gestures ----
      # 3-finger: focus navigation within tag
      gesturebind=NONE,left,3,focusdir,right
      gesturebind=NONE,right,3,focusdir,left
      gesturebind=NONE,up,3,focusstack,prev
      gesturebind=NONE,down,3,focusstack,next

      # 4-finger: tag navigation and overview
      gesturebind=NONE,left,4,viewtoright_have_client,0
      gesturebind=NONE,right,4,viewtoleft_have_client,0
      gesturebind=NONE,up,4,toggleoverview,0
      gesturebind=NONE,down,4,toggleoverview,0

      # ---- Key mode: resize ----
      keymode=resize
      bind=NONE,H,smartresizewin,left
      bind=NONE,L,smartresizewin,right
      bind=NONE,K,smartresizewin,up
      bind=NONE,J,smartresizewin,down
      bind=NONE,Left,smartresizewin,left
      bind=NONE,Right,smartresizewin,right
      bind=NONE,Up,smartresizewin,up
      bind=NONE,Down,smartresizewin,down
      bind=NONE,Escape,setkeymode,default
      bind=NONE,Return,setkeymode,default

      # Back to default mode for main bindings
      keymode=default

      # Enter resize mode
      bind=SUPER,M,setkeymode,resize

      ${cfg.extraConfig}
    '';
  };
}
