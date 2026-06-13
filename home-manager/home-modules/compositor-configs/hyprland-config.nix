{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.programs.hyprland;
  sessionEnabled = config.sessionProfiles.hyprland.enable or false;
  inherit (lib) mkEnableOption mkIf mkOption types;
  inherit (lib.generators) mkLuaInline;

  # Kirigami QML path for Noctalia (workaround for libplasma override issue)
  kirigamiQmlPath = "${lib.getLib pkgs.kdePackages.kirigami}/lib/qt-6/qml";

  # Script to turn off monitors with automatic wake on input
  monitorOffScript = pkgs.writeShellScript "hypr-monitor-off" ''
    pkill -f "swayidle.*hypr-monitor-off" || true
    hyprctl dispatch dpms off
    swayidle \
      timeout 1 'true' \
      resume 'hyprctl dispatch dpms on; pkill -f "swayidle.*hypr-monitor-off"' &
  '';
in
{
  options.programs.hyprland = {
    enable = mkEnableOption "Hyprland window manager";

    enableStylix = mkEnableOption "Enable Stylix theming integration for Hyprland";

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra configuration to append to hyprland config";
    };
  };

  imports = [
    ./waybar-config.nix
    ./hypridle-config.nix
    ./hyprlock-config.nix
    # inputs.hyprshell.homeModules.hyprshell
  ];

  config = mkIf (cfg.enable && sessionEnabled) {

    services.hyprpaper = {
      enable = true;
      settings = mkIf cfg.enableStylix {
        preload = [ config.stylix.image ];
        wallpaper = [ ",${config.stylix.image}" ];
      };
    };

    # Only start hyprpaper when Hyprland is actually running.
    # Without this, hyprpaper crashes on every other Wayland compositor
    # because it can't find the Hyprland IPC socket.
    systemd.user.services.hyprpaper.Unit.ConditionEnvironment =
      lib.mkForce [ "WAYLAND_DISPLAY" "HYPRLAND_INSTANCE_SIGNATURE" ];

    home.packages = with pkgs; [
      # inputs.hyprland-qtutils.packages.${pkgs.stdenv.hostPlatform.system}.default
      iio-hyprland # Hyprland tablet layout listener/changer
      wvkbd # On-screen virtual keyboard for wlroots
      # Add hyprscrolling plugin to system packages
      # hyprlandPlugins.hyprscrolling
      # hyprlandPlugins.hyprexpo
      # hyprlandPlugins.hyprgrass
      # hyprshell
    ];
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false; # UWSM manages the session; HM's own systemd integration conflicts with it
      package = pkgs.hyprland;
      # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.default;
      configType = "lua";
      plugins = [
        # Use system packages instead of flake inputs to avoid NIX_MAIN_PROGRAM conflicts
        # Hyprgrass plugin
        # pkgs.hyprlandPlugins.hyprgrass
        # inputs.hyprgrass.packages.${pkgs.stdenv.hostPlatform.system}.hyprgrass
        # Hyprscroller plugin - commented out, switching to hyprscrolling
        # pkgs.hyprlandPlugins.hyprscroller
        # HyprExpo
        # pkgs.hyprlandPlugins.hyprexpo
        # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprexpo
        # inputs.hyprscroller.packages.${pkgs.stdenv.hostPlatform.system}.default
        # New official hyprscrolling plugin from hyprland-plugins flake input
        # pkgs.hyprlandPlugins.hyprscrolling
        # inputs.hyprland-plugins.packages.${pkgs.stdenv.hostPlatform.system}.hyprscrolling
      ];
      settings = let
        stylixColors = lib.attrByPath [ "lib" "stylix" "colors" ] {} config;
        stylixGtkTheme = lib.attrByPath [ "stylix" "gtk" "theme" "name" ] null config;
        stylixHexOr = name: fallback:
          if cfg.enableStylix then
            let value = stylixColors.${name} or null;
            in if value == null then fallback else value
          else fallback;
        hyprcursorTheme =
          if cfg.enableStylix then config.stylix.cursor.name else "phinger-cursors";
        hyprcursorSize =
          if cfg.enableStylix then toString config.stylix.cursor.size else "32";

        # Bind helpers
        # Pass `mod = "S"` (or "SHIFT + T", etc.) for a mainMod-prefixed bind, or
        # `key = "ALT + Tab"` (or "PRINT", etc.) for a literal-key bind.
        bind = { mod ? null, key ? null, dispatcher, flags ? null }:
          let
            keyArg =
              if mod != null
              then mkLuaInline ''mainMod .. " + ${mod}"''
              else key;
            dsp = mkLuaInline dispatcher;
          in
          { _args = [ keyArg dsp ] ++ lib.optional (flags != null) flags; };
      in {
        # === Lua local variables (rendered as `local x = ...`) ===
        mainMod = { _var = "SUPER"; };
        hyprlock = { _var = "hyprlock"; };
        hypridle = { _var = "hypridle"; };

        # === Bezier / spring curves (must precede animations) ===
        curve = [
          { _args = [ "myBezier" { type = "bezier"; points = [ [ 0.05 0.9 ] [ 0.1 1.05 ] ]; } ]; }
          # Added from garden theme
          { _args = [ "slow"      { type = "bezier"; points = [ [ 0    0.85 ] [ 0.3 1    ] ]; } ]; }
          { _args = [ "overshot"  { type = "bezier"; points = [ [ 0.7  0.6  ] [ 0.1 1.1  ] ]; } ]; }
          { _args = [ "bounce"    { type = "bezier"; points = [ [ 1    1.6  ] [ 0.1 0.85 ] ]; } ]; }
          # 0.55+ clamps bezier Y to [-1, 2], which broke the original
          # overshoot-style beziers for these two. Rewritten as spring
          # curves, which natively express snap/bounce without point clamps.
          # Tune stiffness for speed, dampening for bounce (lower = bouncier).
          { _args = [ "slingshot" { type = "spring"; mass = 1; stiffness = 90;  dampening = 6; } ]; }
          { _args = [ "nice"      { type = "spring"; mass = 1; stiffness = 100; dampening = 4; } ]; }
        ];

        # === Animations ===
        animation = [
          { leaf = "windows";    enabled = true; speed = 5; bezier = "bounce";   style = "slide"; }
          { leaf = "windowsOut"; enabled = true; speed = 7; bezier = "default";  style = "popin 80%"; }
          { leaf = "border";     enabled = true; speed = 20; bezier = "default"; }
          { leaf = "borderangle"; enabled = true; speed = 8; bezier = "default"; }
          { leaf = "fade";       enabled = true; speed = 7; bezier = "default"; }
          { leaf = "workspaces"; enabled = true; speed = 5; bezier = "overshot"; style = "slidevert"; }
        ];

        # === Hyprland variables (sections under hl.config({...})) ===
        config = {
          input = {
            kb_layout = "us";
            numlock_by_default = true;
            repeat_rate = 50;
            follow_mouse = 1;
            natural_scroll = true;
            sensitivity = 0.3;
            touchpad = {
              natural_scroll = true;
              middle_button_emulation = false;
              disable_while_typing = true;
              clickfinger_behavior = true;
              scroll_factor = 2;
            };
          };

          general = {
            # See https://wiki.hypr.land/Configuring/Basics/Variables/ for more
            gaps_in = 4;
            gaps_out = 9;
            border_size = 2;
            # ["col.active_border"]   = "$activeBorderColor1 $activeBorderColor2 8deg";
            # ["col.inactive_border"] = "$inactiveBorderColor";
            # allow_session_lock_restore = true;
            # layout = "dwindle";
            # layout = "scroller";  # Old hyprscroller layout
            layout = "scrolling"; # New official hyprscrolling layout
          };

          decoration = {
            rounding = 5;
            blur = {
              enabled = true;
              size = 3;
              passes = 1;
            };
          };

          animations = {
            enabled = true;
          };

          dwindle = {
            # 0.55 removed the global pseudotile toggle; use the
            # hl.dsp.window.pseudo() dispatcher (bound to mainMod+P) instead.
            preserve_split = true;
          };

          master = {
            new_status = "master";
          };

          # Group / groupbar styling. Hyprland's groupbar always sits
          # above the window (no side-mount option like Niri), so we just
          # keep it as a slim horizontal strip with titles. Stylix injects
          # col.active, col.inactive, text_color etc. separately.
          group = {
            groupbar = {
              stacked = false;
              render_titles = false;
              # height = 18;
              indicator_height = 7;
              font_size = 11;
              rounding = 10;
              gaps_in = 6;
              gaps_out = 3;
              keep_upper_gap = false;
            };
          };

          gestures = {
            # workspace_swipe, workspace_swipe_fingers and workspace_swipe_min_fingers
            # were removed in 0.55 in favor of the new gesture system below.
            workspace_swipe_invert = true;
          };

          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
          };

          debug = {
            disable_logs = false; # Temporarily enable logs to debug plugin loading
          };

          # Scrolling layout config (applies when hyprscrolling plugin is loaded)
          scrolling = {
            fullscreen_on_one_column = false;
            column_width = 0.8;
            explicit_column_widths = "0.333, 0.5, 0.667, 0.75, 0.8, 0.9, 1.0";
            focus_fit_method = 0;
            follow_focus = true;
          };
        };

        # === Per-device input config ===
        device = [
          { name = "microsoft-arc-mouse"; sensitivity = 1; }
        ];

        # === Environment variables ===
        env = [
          { _args = [ "XDG_CURRENT_DESKTOP" "Hyprland" ]; }
          { _args = [ "XDG_SESSION_TYPE" "wayland" ]; }
          { _args = [ "XDG_SESSION_DESKTOP" "Hyprland" ]; }
          { _args = [ "_JAVA_AWT_WM_NONREPARENTING" "1" ]; }
          { _args = [ "QT_WAYLAND_DISABLE_WINDOWDECORATION" "1" ]; }
          { _args = [ "MOZ_ENABLE_WAYLAND" "1" ]; }
          { _args = [ "QT_QPA_PLATFORM" "wayland;xcb" ]; }
          { _args = [ "GDK_BACKEND" "wayland,x11" ]; }
          { _args = [ "WLR_NO_HARDWARE_CURSORS" "1" ]; }
          { _args = [ "SDL_VIDEODRIVER" "wayland" ]; }
          { _args = [ "CLUTTER_BACKEND" "wayland" ]; }
          { _args = [ "QT_AUTO_SCREEN_SCALE_FACTOR" "1" ]; }
          # Noctalia QML path (fixes libplasma kirigami override)
          { _args = [ "QML2_IMPORT_PATH" kirigamiQmlPath ]; }
          # KWallet6 configuration - required for Signal and other apps that use kwallet
          { _args = [ "KDE_FULL_SESSION" "true" ]; }
          { _args = [ "KDE_SESSION_VERSION" "6" ]; }
          { _args = [ "QT_QPA_PLATFORMTHEME" "kde" ]; }
          { _args = [ "SSH_AUTH_SOCK" "/run/user/1000/kwallet6.socket" ]; }
          { _args = [ "HYPRCURSOR_SIZE" hyprcursorSize ]; }
          { _args = [ "XDG_MENU_PREFIX" "plasma-" ]; }
        ]
        ++ lib.optional cfg.enableStylix
             { _args = [ "HYPRCURSOR_THEME" hyprcursorTheme ]; }
        ++ lib.optional (cfg.enableStylix && stylixGtkTheme != null)
             { _args = [ "GTK_THEME" stylixGtkTheme ]; };

        # === Startup commands (replaces exec-once) ===
        on = {
          _args = [
            "hyprland.start"
            (mkLuaInline ''
              function()
                  hl.exec_cmd("hyprctl setcursor ${hyprcursorTheme} ${hyprcursorSize}")
                  -- hl.exec_cmd("emacs --daemon")
                  hl.exec_cmd("foot -s")
                  -- hl.exec_cmd("waybar")  -- Removed - now using noctalia
                  hl.exec_cmd("noctalia")
                  hl.exec_cmd("mako")
                  hl.exec_cmd("nm-applet --indicator")
                  hl.exec_cmd("blueman-applet")
                  hl.exec_cmd("iio-hyprland")
                  -- hl.exec_cmd("pcloud")  -- XDG autostart handles this (~/.config/autostart/pcloud.desktop)
                  hl.exec_cmd("wlsunset -l 40.6 -L -75.4 -t 2300 -T 6500")
                  hl.exec_cmd("kwalletd6")
                  hl.exec_cmd("kded6")
                  hl.exec_cmd(hypridle)
                  -- hl.exec_cmd("stasis")  -- Disabled - reverting to hypridle
              end
            '')
          ];
        };

        # === Monitor configuration ===
        monitor = [
          { output = "eDP-1"; mode = "preferred"; position = "auto"; scale = 2; transform = 0; }
        ];

        # === Keybinds ===
        bind = [
          (bind { key = "ALT + SPACE";          dispatcher = ''hl.dsp.exec_cmd("anyrun")''; })
          (bind { mod = "S";                    dispatcher = ''hl.dsp.exec_cmd("kitty")''; })
          (bind { key = "CTRL + ALT + T";       dispatcher = ''hl.dsp.exec_cmd("wezterm")''; })
          (bind { mod = "SHIFT + T";            dispatcher = ''hl.dsp.exec_cmd("alacritty")''; })
          (bind { mod = "Q";                    dispatcher = ''hl.dsp.window.close()''; })
          # UWSM: use uwsm stop instead of exit dispatcher for clean session shutdown
          (bind { mod = "SHIFT + E";            dispatcher = ''hl.dsp.exec_cmd("uwsm stop")''; })
          (bind { mod = "E";                    dispatcher = ''hl.dsp.exec_cmd("nautilus")''; })
          (bind { mod = "Return";               dispatcher = ''hl.dsp.window.float({ action = "toggle" })''; })
          (bind { mod = "D";                    dispatcher = ''hl.dsp.exec_cmd("rofi -show drun -show-icons")''; })
          # (bind { mod = "W";                  dispatcher = ''hl.dsp.exec_cmd("pkill wofi || wofi -S drun -GIm -w 3 -W 100% -H 96%")''; })
          (bind { mod = "CTRL + W";             dispatcher = ''hl.dsp.exec_cmd("pkill wofi || wofi -S drun -GIm -w 3 -W 100% -H 96%")''; })
          # Alt window switcher (rofi)
          (bind { key = "ALT + Tab";            dispatcher = ''hl.dsp.exec_cmd("rofi -show window")''; })
          (bind { key = "ALT + grave";          dispatcher = ''hl.dsp.exec_cmd("rofi -show window")''; })
          (bind { mod = "P";                    dispatcher = ''hl.dsp.window.pseudo()''; })
          (bind { mod = "L";                    dispatcher = ''hl.dsp.exec_cmd(hyprlock)''; })
          (bind { mod = "SHIFT + Escape";       dispatcher = ''hl.dsp.exec_cmd(hyprlock)''; })
          (bind { mod = "J";                    dispatcher = ''hl.dsp.layout("togglesplit")''; })
          (bind { mod = "SHIFT + F";            dispatcher = ''hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" })''; })
          (bind { mod = "F";                    dispatcher = ''hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })''; })

          # Groups (i3-style tabbed containers)
          (bind { mod = "G";                    dispatcher = ''hl.dsp.group.toggle()''; })
          (bind { mod = "SHIFT + G";            dispatcher = ''hl.dsp.group.lock()''; })
          (bind { mod = "Tab";                  dispatcher = ''hl.dsp.group.next()''; })
          (bind { mod = "SHIFT + Tab";          dispatcher = ''hl.dsp.group.prev()''; })
          (bind { mod = "SPACE";                dispatcher = ''hl.dsp.exec_cmd("noctalia msg panel-toggle launcher")''; })
          (bind { mod = "B";                    dispatcher = ''hl.dsp.exec_cmd("pkill waybar || waybar")''; })
          (bind { mod = "K";                    dispatcher = ''hl.dsp.exec_cmd("kate")''; })
          (bind { mod = "R";                    dispatcher = ''hl.dsp.exec_cmd("hyprctl seterror disable")''; })

          # Dropdown terminal
          (bind { mod = "Y";                    dispatcher = ''hl.dsp.exec_cmd("bash -c 'pgrep footclient && pkill footclient || footclient'")''; })

          # Power off monitors (with automatic wake on input)
          (bind { mod = "SHIFT + P";            dispatcher = ''hl.dsp.exec_cmd("${monitorOffScript}")''; })

          # Voice dictation - Momentary
          (bind { mod = "X";                    dispatcher = ''hl.dsp.exec_cmd("dictate-fw-ptt-auto 5")''; })
          (bind { mod = "SHIFT + X";            dispatcher = ''hl.dsp.exec_cmd("dictate-wc-ptt-auto 5")''; })

          # Voice dictation - Toggle
          (bind { mod = "backslash";            dispatcher = ''hl.dsp.exec_cmd("dictate-fw-ptt-toggle")''; })
          (bind { mod = "SHIFT + backslash";    dispatcher = ''hl.dsp.exec_cmd("dictate-wc-ptt-toggle")''; })

          # Volume
          (bind { key = "XF86AudioMute";        dispatcher = ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")''; })

          # Playerctl
          (bind { key = "XF86AudioPlay";        dispatcher = ''hl.dsp.exec_cmd("playerctl play-pause")''; })
          (bind { key = "XF86AudioNext";        dispatcher = ''hl.dsp.exec_cmd("playerctl next")''; })
          (bind { key = "XF86AudioPrev";        dispatcher = ''hl.dsp.exec_cmd("playerctl previous")''; })

          # Switches (reload + restart waybar + notify, three actions on the same key)
          (bind { key = "SUPER + Escape";       dispatcher = ''hl.dsp.exec_cmd("hyprctl reload")''; })
          (bind { key = "SUPER + Escape";       dispatcher = ''hl.dsp.exec_cmd("pkill waybar && sleep 1 && waybar &")''; })
          (bind { key = "SUPER + Escape";       dispatcher = ''hl.dsp.exec_cmd("notify-send 'Config Reloaded'")''; })

          # Group-aware focus: if focused window is in a group, arrow/HJKL
          # keys cycle through tabs in the group instead of moving focus.
          # Helper smart_focus() is defined in extraConfig below.
          (bind { mod = "left";  dispatcher = ''function() smart_focus("l") end''; })
          (bind { mod = "right"; dispatcher = ''function() smart_focus("r") end''; })
          (bind { mod = "up";    dispatcher = ''function() smart_focus("u") end''; })
          (bind { mod = "down";  dispatcher = ''function() smart_focus("d") end''; })
          (bind { mod = "h";     dispatcher = ''function() smart_focus("l") end''; })
          (bind { mod = "l";     dispatcher = ''function() smart_focus("r") end''; })
          (bind { mod = "j";     dispatcher = ''function() smart_focus("d") end''; })
          (bind { mod = "k";     dispatcher = ''function() smart_focus("u") end''; })

          # Hyprscrolling - window movement
          (bind { mod = "SHIFT + left";  dispatcher = ''hl.dsp.layout("swapcol l")''; })
          (bind { mod = "SHIFT + right"; dispatcher = ''hl.dsp.layout("swapcol r")''; })
          (bind { mod = "SHIFT + up";    dispatcher = ''hl.dsp.window.move({ direction = "u", group_aware = false })''; })
          (bind { mod = "SHIFT + down";  dispatcher = ''hl.dsp.window.move({ direction = "d", group_aware = false })''; })
          (bind { mod = "SHIFT + CTRL + left";  dispatcher = ''hl.dsp.window.move({ direction = "l", group_aware = false })''; })
          (bind { mod = "SHIFT + CTRL + right"; dispatcher = ''hl.dsp.window.move({ direction = "r", group_aware = false })''; })
          # (bind { mod = "SHIFT + CTRL + up";    dispatcher = ''hl.dsp.window.move({ direction = "u", group_aware = true })''; })
          # (bind { mod = "SHIFT + CTRL + down";  dispatcher = ''hl.dsp.window.move({ direction = "d", group_aware = true })''; })
          
          # Movement of groups & columns
          (bind { mod = "bracketleft"; dispatcher = ''hl.dsp.window.move({ direction = "l", group_aware = true })''; })
          (bind { mod = "bracketright";  dispatcher = ''hl.dsp.window.move({ direction = "r", group_aware = true })''; })
          (bind { mod = "SHIFT + bracketleft";  dispatcher = ''hl.dsp.window.move({ into_or_create_group = "l" })''; })
          (bind { mod = "SHIFT + bracketright";  dispatcher = ''hl.dsp.window.move({ into_or_create_group = "r" })''; })
          (bind { mod = "SHIFT + CTRL + bracketleft";   dispatcher = ''hl.dsp.window.move({ direction = "l", group_aware = false })''; })
          (bind { mod = "SHIFT + CTRL + bracketright";  dispatcher = ''hl.dsp.window.move({ direction = "r", group_aware = false })''; })


          # Switch workspaces with mainMod + [0-9] (per-monitor numbering)
          # Each monitor gets its own block of 10 workspace IDs; helpers are
          # defined in extraConfig below.
          (bind { mod = "1"; dispatcher = ''function() focus_local_workspace(1) end''; })
          (bind { mod = "2"; dispatcher = ''function() focus_local_workspace(2) end''; })
          (bind { mod = "3"; dispatcher = ''function() focus_local_workspace(3) end''; })
          (bind { mod = "4"; dispatcher = ''function() focus_local_workspace(4) end''; })
          (bind { mod = "5"; dispatcher = ''function() focus_local_workspace(5) end''; })
          (bind { mod = "6"; dispatcher = ''function() focus_local_workspace(6) end''; })
          (bind { mod = "7"; dispatcher = ''function() focus_local_workspace(7) end''; })
          (bind { mod = "8"; dispatcher = ''function() focus_local_workspace(8) end''; })
          (bind { mod = "9"; dispatcher = ''function() focus_local_workspace(9) end''; })
          (bind { mod = "0"; dispatcher = ''function() focus_local_workspace(10) end''; })

          # Move active window to a workspace with mainMod + SHIFT + [0-9]
          (bind { mod = "SHIFT + 1"; dispatcher = ''function() move_to_local_workspace(1) end''; })
          (bind { mod = "SHIFT + 2"; dispatcher = ''function() move_to_local_workspace(2) end''; })
          (bind { mod = "SHIFT + 3"; dispatcher = ''function() move_to_local_workspace(3) end''; })
          (bind { mod = "SHIFT + 4"; dispatcher = ''function() move_to_local_workspace(4) end''; })
          (bind { mod = "SHIFT + 5"; dispatcher = ''function() move_to_local_workspace(5) end''; })
          (bind { mod = "SHIFT + 6"; dispatcher = ''function() move_to_local_workspace(6) end''; })
          (bind { mod = "SHIFT + 7"; dispatcher = ''function() move_to_local_workspace(7) end''; })
          (bind { mod = "SHIFT + 8"; dispatcher = ''function() move_to_local_workspace(8) end''; })
          (bind { mod = "SHIFT + 9"; dispatcher = ''function() move_to_local_workspace(9) end''; })
          (bind { mod = "SHIFT + 0"; dispatcher = ''function() move_to_local_workspace(10) end''; })

          # Vertical workspace switching (1 column x 10 rows, wrapping)
          # Stays within the active monitor's workspace block.
          (bind { mod = "CTRL + up";   dispatcher = ''function() focus_workspace_up() end''; })
          (bind { mod = "CTRL + down"; dispatcher = ''function() focus_workspace_down() end''; })
          (bind { mod = "SHIFT + CTRL + up";   dispatcher = ''function() move_window_workspace_up() end''; })
          (bind { mod = "SHIFT + CTRL + down"; dispatcher = ''function() move_window_workspace_down() end''; })

          # Focus adjacent monitor (Niri parity: Alt+Ctrl+arrows/HJKL)
          (bind { key = "ALT + CTRL + left";  dispatcher = ''hl.dsp.focus({ monitor = "l" })''; })
          (bind { key = "ALT + CTRL + right"; dispatcher = ''hl.dsp.focus({ monitor = "r" })''; })
          (bind { key = "ALT + CTRL + up";    dispatcher = ''hl.dsp.focus({ monitor = "u" })''; })
          (bind { key = "ALT + CTRL + down";  dispatcher = ''hl.dsp.focus({ monitor = "d" })''; })
          (bind { key = "ALT + CTRL + h";     dispatcher = ''hl.dsp.focus({ monitor = "l" })''; })
          (bind { key = "ALT + CTRL + j";     dispatcher = ''hl.dsp.focus({ monitor = "d" })''; })
          (bind { key = "ALT + CTRL + k";     dispatcher = ''hl.dsp.focus({ monitor = "u" })''; })
          (bind { key = "ALT + CTRL + l";     dispatcher = ''hl.dsp.focus({ monitor = "r" })''; })

          # Move focused window to adjacent monitor (Niri parity: Alt+Shift+Ctrl+arrows/HJKL)
          (bind { key = "ALT + SHIFT + CTRL + left";  dispatcher = ''hl.dsp.window.move({ monitor = "l" })''; })
          (bind { key = "ALT + SHIFT + CTRL + right"; dispatcher = ''hl.dsp.window.move({ monitor = "r" })''; })
          (bind { key = "ALT + SHIFT + CTRL + up";    dispatcher = ''hl.dsp.window.move({ monitor = "u" })''; })
          (bind { key = "ALT + SHIFT + CTRL + down";  dispatcher = ''hl.dsp.window.move({ monitor = "d" })''; })
          (bind { key = "ALT + SHIFT + CTRL + h";     dispatcher = ''hl.dsp.window.move({ monitor = "l" })''; })
          (bind { key = "ALT + SHIFT + CTRL + j";     dispatcher = ''hl.dsp.window.move({ monitor = "d" })''; })
          (bind { key = "ALT + SHIFT + CTRL + k";     dispatcher = ''hl.dsp.window.move({ monitor = "u" })''; })
          (bind { key = "ALT + SHIFT + CTRL + l";     dispatcher = ''hl.dsp.window.move({ monitor = "r" })''; })

          # Mouse-wheel workspace cycling (global - crosses monitors)
          (bind { key = "mouse_right"; dispatcher = ''hl.dsp.focus({ workspace = "e+1" })''; })
          (bind { key = "mouse_left";  dispatcher = ''hl.dsp.focus({ workspace = "e-1" })''; })

          # Mouse-button workspace cycling, per-monitor (wraps within the
          # active monitor's 10-workspace block).
          (bind { mod = "CTRL + mouse:273"; dispatcher = ''function() focus_workspace_down() end''; })
          (bind { mod = "CTRL + mouse:272"; dispatcher = ''function() focus_workspace_up() end''; })

          # Screenshots with Satty (moved out of extraConfig)
          (bind { key = "PRINT";              dispatcher = ''hl.dsp.exec_cmd("screenshot-region")''; })
          (bind { mod = "PRINT";              dispatcher = ''hl.dsp.exec_cmd("screenshot-output")''; })
          (bind { mod = "SHIFT + PRINT";      dispatcher = ''hl.dsp.exec_cmd("screenshot-window")''; })

          # Hyprscrolling - column resizing (cycle through preconfigured widths)
          (bind { mod = "equal"; dispatcher = ''hl.dsp.layout("colresize +conf")''; })
          (bind { mod = "minus"; dispatcher = ''hl.dsp.layout("colresize -conf")''; })
          (bind { mod = "SHIFT + equal"; dispatcher = ''hl.dsp.layout("colresize +0.1")''; })
          (bind { mod = "SHIFT + minus"; dispatcher = ''hl.dsp.layout("colresize -0.1")''; })

          # Hyprscrolling - fit operations
          # (bind { mod = "f";         dispatcher = ''hl.dsp.layout("fit active")''; })
          # (bind { mod = "SHIFT + f"; dispatcher = ''hl.dsp.layout("fit visible")''; })
          (bind { mod = "CTRL + f"; dispatcher = ''hl.dsp.layout("fit all")''; })

          # Hyprscrolling - window promotion (move to new column)
          (bind { mod = "o"; dispatcher = ''hl.dsp.layout("promote")''; })

          # Zoom (using Hyprland's built-in cursor zoom)
          (bind { mod = "z";         dispatcher = ''hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor 2.0")''; })
          (bind { mod = "SHIFT + z"; dispatcher = ''hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor 1.0")''; })

          # binde (repeating)
          (bind { key = "XF86AudioLowerVolume"; dispatcher = ''hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-")''; flags = { repeating = true; }; })
          (bind { key = "XF86AudioRaiseVolume"; dispatcher = ''hl.dsp.exec_cmd("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+")''; flags = { repeating = true; }; })
          # Screen brightness
          (bind { key = "XF86MonBrightnessDown"; dispatcher = ''hl.dsp.exec_cmd("brightnessctl set 2%-")''; flags = { repeating = true; }; })
          (bind { key = "XF86MonBrightnessUp";   dispatcher = ''hl.dsp.exec_cmd("brightnessctl set 2%+")''; flags = { repeating = true; }; })

          # bindl (locked - works while input inhibitor is active)
          (bind { key = "switch:Lid Switch"; dispatcher = ''hl.dsp.exec_cmd(hyprlock)''; flags = { locked = true; }; })

          # bindm (mouse drag/resize)
          (bind { mod = "mouse:272";         dispatcher = ''hl.dsp.window.drag()''; flags = { mouse = true; }; })
          (bind { mod = "SHIFT + mouse:272"; dispatcher = ''hl.dsp.window.resize()''; flags = { mouse = true; }; })
        ];

        # === Trackpad gestures ===
        gesture = [
          { fingers = 3; direction = "right"; action = mkLuaInline ''function() hl.dispatch(hl.dsp.layout("move -col")) end''; }
          { fingers = 3; direction = "left";  action = mkLuaInline ''function() hl.dispatch(hl.dsp.layout("move +col")) end''; }
          { fingers = 4; direction = "up";  action = mkLuaInline ''function() hl.dispatch(hl.dsp.focus({ workspace = "r+1" })) end''; }
          { fingers = 4; direction = "down"; action = mkLuaInline ''function() hl.dispatch(hl.dsp.focus({ workspace = "m-1" })) end''; }
        ];

        # === Window rules - float dialogs and utility apps ===
        window_rule = [
          { match = { class = "^(lxqt-policykit)"; };          float = true; }
          { match = { title = "^(Authentication Required)$"; }; float = true; }
          { match = { class = "^(bitwarden)$"; };               float = true; }
        ];
      };
      extraConfig = ''
        -- ============================================================
        -- Per-monitor workspace numbering + vertical workspace switching
        -- ============================================================
        --
        -- Each monitor gets its own block of 10 workspace IDs based on
        -- the runtime monitor.id assigned by Hyprland:
        --
        --   monitor.id 0 -> workspaces 1..10
        --   monitor.id 1 -> workspaces 11..20
        --   monitor.id N -> workspaces N*10+1 .. N*10+10
        --
        -- "Local" workspace 1..10 means "this monitor's first..tenth
        -- workspace". mod+1..mod+0 binds use this mapping so the same
        -- key means the same logical workspace regardless of which
        -- monitor is focused.
        --
        -- Note: monitor.id is the runtime ID Hyprland assigns based on
        -- enumeration order. It can shift if monitors are added/removed
        -- mid-session. Workspaces stay associated with their last
        -- monitor when one is disconnected and reappear when reconnected.

        function ws_for_monitor(n)
          local m = hl.get_active_monitor()
          return tostring(m.id * 10 + n)
        end

        function focus_local_workspace(n)
          hl.dispatch(hl.dsp.focus({ workspace = ws_for_monitor(n) }))
        end

        function move_to_local_workspace(n)
          hl.dispatch(hl.dsp.window.move({ workspace = ws_for_monitor(n) }))
        end

        -- Returns the active workspace's local index (1..10) within the
        -- active monitor's block. Clamps to 1 if the current workspace
        -- is outside the expected range (e.g. a special workspace).
        local function local_workspace_index()
          local m = hl.get_active_monitor()
          local ws = hl.get_active_workspace()
          local n = ws.id - m.id * 10
          if n < 1 or n > 10 then return 1 end
          return n
        end

        function focus_workspace_up()
          local n = local_workspace_index()
          local target = n - 1
          if target < 1 then target = 10 end
          focus_local_workspace(target)
        end

        function focus_workspace_down()
          focus_local_workspace((local_workspace_index() % 10) + 1)
        end

        function move_window_workspace_up()
          local n = local_workspace_index()
          local target = n - 1
          if target < 1 then target = 10 end
          move_to_local_workspace(target)
        end

        function move_window_workspace_down()
          move_to_local_workspace((local_workspace_index() % 10) + 1)
        end

        -- ============================================================
        -- Group-aware focus movement
        -- ============================================================
        --
        -- When the focused window is in a group, arrow/HJKL keys cycle
        -- through tabs (group.prev/next). When not in a group, they fall
        -- back to the original behavior: left/right move between
        -- hyprscrolling columns, up/down move directional window focus.
        --
        -- Hyprland Lua API: `w.group` is `HL.Group` userdata when the
        -- window is in a group (nil otherwise). The Group exposes:
        --   g.size           number   total tabs
        --   g.current        Window   focused tab's window
        --   g.current_index  number   1-based index of current tab
        --   g.members        table    list of member windows
        -- Note: differs from hyprctl JSON, which uses `grouped` as a list
        -- of addresses.

        function smart_focus(direction)
          local w = hl.get_active_window()
          if w == nil then return end

          local g = w.group
          if g ~= nil then
            local is_forward = (direction == "r" or direction == "d")
            if is_forward and g.current_index < g.size then
              hl.dispatch(hl.dsp.group.next())
              return
            elseif (not is_forward) and g.current_index > 1 then
              hl.dispatch(hl.dsp.group.prev())
              return
            end
            -- Fall through: at edge of group, escape to neighbor.
          end

          if direction == "l" then
            hl.dispatch(hl.dsp.layout("focus l"))
          elseif direction == "r" then
            hl.dispatch(hl.dsp.layout("focus r"))
          else
            hl.dispatch(hl.dsp.focus({ direction = direction }))
          end
        end
      '';
    };
  };
}
