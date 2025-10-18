{
  config,
  pkgs,
  inputs,
  lib,
  ...
}:

let
  sessionEnabled = config.sessionProfiles.niri.enable or false;
in
lib.mkIf sessionEnabled {
  programs = {
    niriswitcher = {
      enable = true;
      settings = {
        keys = {
          modifier = "Alt";
          switch = {
            next = "Tab";
            prev = "Shift+Tab";
          };
        };
        center_on_focus = true;
        appearance = {
          system_theme = "dark";
          icon_size = 64;
        };
      };
    };
  };

  home.file.".config/niri/config.kdl".text = ''
    // This config is in the KDL format: https://kdl.dev
    // "/-" comments out the following node.
    // Check the wiki for a full description of the configuration:
    // https://github.com/YaLTeR/niri/wiki/Configuration:-Overview

    // Input device configuration.
    // Find the full list of options on the wiki:
    // https://github.com/YaLTeR/niri/wiki/Configuration:-Input
    input {
        keyboard {
            xkb {
                // You can set rules, model, layout, variant and options.
                // For more information, see xkeyboard-config(7).

                // For example:
                // layout "us,ru"
                // options "grp:win_space_toggle,compose:ralt,ctrl:nocaps"
            }
            
            repeat-delay 600
            repeat-rate 50
        }

        // Next sections include libinput settings.
        // Omitting settings disables them, or leaves them at their default values.
        touchpad {
            // off
            tap
            // dwt
            // dwtp
            natural-scroll
            accel-speed 0.2
            // accel-profile "flat"
            click-method "clickfinger"
            // scroll-method "two-finger"
            // disabled-on-external-mouse
        }

        mouse {
            // off
            natural-scroll
            accel-speed 0.4
            // accel-profile "flat"
            // scroll-method "no-scroll"
        }
        
        tablet {
            // off
            map-to-output "eDP-1"
            // left-handed
            // calibration-matrix 1.0 0.0 0.0 0.0 1.0 0.0
        }

        touch {
            // off
            map-to-output "eDP-1"
        }
        
        // Uncomment this to make the mouse warp to the center of newly focused windows.
        // warp-mouse-to-focus

        // Focus windows and outputs automatically when moving the mouse into them.
        // Setting max-scroll-amount="0%" makes it work only on windows already fully on screen.
        focus-follows-mouse max-scroll-amount="70%"
    }

    // You can configure outputs by their name, which you can find
    // by running `niri msg outputs` while inside a niri instance.
    // The built-in laptop monitor is usually called "eDP-1".
    // Find more information on the wiki:
    // https://github.com/YaLTeR/niri/wiki/Configuration:-Outputs
    // Remember to uncomment the node by removing "/-"!
    output "eDP-1" {
        // Uncomment this line to disable this output.
        // off

        // Resolution and, optionally, refresh rate of the output.
        // The format is "<width>x<height>" or "<width>x<height>@<refresh rate>".
        // If the refresh rate is omitted, niri will pick the highest refresh rate
        // for the resolution.
        // If the mode is omitted altogether or is invalid, niri will pick one automatically.
        // Run `niri msg outputs` while inside a niri instance to list all outputs and their modes.
        mode "1920x1080"

        // You can use integer or fractional scale, for example use 1.5 for 150% scale.
        scale 2

        // Transform allows to rotate the output counter-clockwise, valid values are:
        // normal, 90, 180, 270, flipped, flipped-90, flipped-180 and flipped-270.
        transform "normal"

        // Position of the output in the global coordinate space.
        // This affects directional monitor actions like "focus-monitor-left", and cursor movement.
        // The cursor can only move between directly adjacent outputs.
        // Output scale and rotation has to be taken into account for positioning:
        // outputs are sized in logical, or scaled, pixels.
        // For example, a 3840×2160 output with scale 2.0 will have a logical size of 1920×1080,
        // so to put another output directly adjacent to it on the right, set its x to 1920.
        // If the position is unset or results in an overlap, the output is instead placed
        // automatically.
        position x=0 y=0
    }
    output "DP-1" {
        // Uncomment this line to disable this output.
        // off

        // Resolution and, optionally, refresh rate of the output.
        // The format is "<width>x<height>" or "<width>x<height>@<refresh rate>".
        // If the refresh rate is omitted, niri will pick the highest refresh rate
        // for the resolution.
        // If the mode is omitted altogether or is invalid, niri will pick one automatically.
        // Run `niri msg outputs` while inside a niri instance to list all outputs and their modes.
        mode "3440x1440"

        // You can use integer or fractional scale, for example use 1.5 for 150% scale.
        scale 1

        // Transform allows to rotate the output counter-clockwise, valid values are:
        // normal, 90, 180, 270, flipped, flipped-90, flipped-180 and flipped-270.
        transform "normal"

        // Position of the output in the global coordinate space.
        // This affects directional monitor actions like "focus-monitor-left", and cursor movement.
        // The cursor can only move between directly adjacent outputs.
        // Output scale and rotation has to be taken into account for positioning:
        // outputs are sized in logical, or scaled, pixels.
        // For example, a 3840×2160 output with scale 2.0 will have a logical size of 1920×1080,
        // so to put another output directly adjacent to it on the right, set its x to 1920.
        // If the position is unset or results in an overlap, the output is instead placed
        // automatically.
        position x=0 y=0
    }
    output "HDMI-A-1" {
        // Uncomment this line to disable this output.
        // off

        // Resolution and, optionally, refresh rate of the output.
        // The format is "<width>x<height>" or "<width>x<height>@<refresh rate>".
        // If the refresh rate is omitted, niri will pick the highest refresh rate
        // for the resolution.
        // If the mode is omitted altogether or is invalid, niri will pick one automatically.
        // Run `niri msg outputs` while inside a niri instance to list all outputs and their modes.
        mode "1920x1080"

        // You can use integer or fractional scale, for example use 1.5 for 150% scale.
        scale 1

        // Transform allows to rotate the output counter-clockwise, valid values are:
        // normal, 90, 180, 270, flipped, flipped-90, flipped-180 and flipped-270.
        transform "normal"

        // Position of the output in the global coordinate space.
        // This affects directional monitor actions like "focus-monitor-left", and cursor movement.
        // The cursor can only move between directly adjacent outputs.
        // Output scale and rotation has to be taken into account for positioning:
        // outputs are sized in logical, or scaled, pixels.
        // For example, a 3840×2160 output with scale 2.0 will have a logical size of 1920×1080,
        // so to put another output directly adjacent to it on the right, set its x to 1920.
        // If the position is unset or results in an overlap, the output is instead placed
        // automatically.
        position x=3440 y=200
    }

    // Settings that influence how windows are positioned and sized.
    // Find more information on the wiki:
    // https://github.com/YaLTeR/niri/wiki/Configuration:-Layout

    layout {
        gaps 16
        center-focused-column "never"
        always-center-single-column
        empty-workspace-above-first
        default-column-display "tabbed"
        background-color "#${config.lib.stylix.colors.base00}ff"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }

        preset-window-heights {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        focus-ring {
            // off
            width 2
            active-color "#${config.lib.stylix.colors.base0D}"
            inactive-color "#${config.lib.stylix.colors.base03}"
            urgent-color "#${config.lib.stylix.colors.base08}"
            // active-gradient from="#80c8ff" to="#bbddff" angle=45
            // inactive-gradient from="#505050" to="#808080" angle=45 relative-to="workspace-view"
            // urgent-gradient from="#800" to="#a33" angle=45
        }

        border {
            off
            width 4
            active-color "#${config.lib.stylix.colors.base09}"
            inactive-color "#${config.lib.stylix.colors.base03}"
            urgent-color "#${config.lib.stylix.colors.base08}"
            // active-gradient from="#ffbb66" to="#ffc880" angle=45 relative-to="workspace-view"
            // inactive-gradient from="#505050" to="#808080" angle=45 relative-to="workspace-view" in="srgb-linear"
            // urgent-gradient from="#800" to="#a33" angle=45
        }

        shadow {
            // on
            softness 30
            spread 5
            offset x=0 y=5
            draw-behind-window true
            color "#${config.lib.stylix.colors.base00}70"
            // inactive-color "#00000054"
        }

        tab-indicator {
            // off
            hide-when-single-tab
            place-within-column
            gap 5
            width 12
            length total-proportion=1.0
            position "left"
            gaps-between-tabs 2
            corner-radius 8
            active-color "#${config.lib.stylix.colors.base08}"
            inactive-color "#${config.lib.stylix.colors.base03}"
            urgent-color "#${config.lib.stylix.colors.base0D}"
            // active-gradient from="#80c8ff" to="#bbddff" angle=45
            // inactive-gradient from="#505050" to="#808080" angle=45 relative-to="workspace-view"
            // urgent-gradient from="#800" to="#a33" angle=45
        }

        insert-hint {
            // off
            color "#${config.lib.stylix.colors.base09}80"
            // gradient from="#ffbb6680" to="#ffc88080" angle=45 relative-to="workspace-view"
        }

        struts {
            // left 64
            // right 64
            // top 64
            // bottom 64
        }
    }

    // Add lines like this to spawn processes at startup.
    // Note that running niri as a session supports xdg-desktop-autostart,
    // which may be more convenient to use.
    // See the binds section below for more spawn examples.
    // spawn-at-startup "alacritty" "-e" "fish"
    spawn-at-startup "bash" "-c" "foot --server"
    spawn-at-startup "bash" "-c" "waybar -c $HOME/.config/niri/waybar/config -s $HOME/.config/niri/waybar/style.css"
    spawn-at-startup "mako"
    spawn-at-startup "niriswitcher"
    spawn-at-startup "bash" "-c" "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && systemctl --user start --no-block xdg-desktop-portal-gnome.service && systemctl --user start --no-block xdg-desktop-portal-gtk.service"
    // spawn-at-startup "xwayland-satellite"
    spawn-at-startup "bash" "-c" "sleep 3 && pcloud"
    spawn-at-startup "bash" "-c" "swayidle -w timeout 300 'swaylock -f -c 000000' timeout 600 'swaymsg \"output * power off\"' resume 'swaymsg \"output * power on\"' before-sleep 'swaylock -f -c 000000' "

    // environment {
    //     DISPLAY ":0"
    // }

    // Uncomment this line to ask the clients to omit their client-side decorations if possible.
    // If the client will specifically ask for CSD, the request will be honored.
    // Additionally, clients will be informed that they are tiled, removing some rounded corners.
    prefer-no-csd

    // You can change the path where screenshots are saved.
    // A ~ at the front will be expanded to the home directory.
    // The path is formatted with strftime(3) to give you the screenshot date and time.
    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    // You can also set this to null to disable saving screenshots to disk.
    // screenshot-path null

    // Animation settings.
    // The wiki explains how to configure individual animations:
    // https://github.com/YaLTeR/niri/wiki/Configuration:-Animations
    animations {
        // Uncomment to turn off all animations.
        // off

        // off
        // slowdown 10.0
        // slowdown 4.0
        // slowdown 2.0
        // slowdown 1.5

        workspace-switch {
            // off
            duration-ms 500
            curve "ease-out-cubic"
            // spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
        }

        window-open {
            // off
            duration-ms 500
            curve "ease-out-expo"
            // spring damping-ratio=0.8 stiffness=1000 epsilon=0.0001
        }

        window-close {
            // off
            duration-ms 500
            curve "ease-out-cubic"
            // spring damping-ratio=0.8 stiffness=1000 epsilon=0.0001
        }

        horizontal-view-movement {
            // off
            duration-ms 500
            curve "ease-out-cubic"
            // spring damping-ratio=1.0 stiffness=20 epsilon=0.00001
            // spring damping-ratio=10.0 stiffness=800 epsilon=0.0001
        }

        window-movement {
            // off
            duration-ms 750
            curve "ease-out-cubic"
            // spring damping-ratio=1.0 stiffness=20 epsilon=0.00001
            // spring damping-ratio=0.2 stiffness=800 epsilon=0.0001
        }

        window-resize {
            // off
            duration-ms 500
            // duration-ms 2500
            curve "ease-out-cubic"
            // spring damping-ratio=0.2 stiffness=800 epsilon=0.0001

            custom-shader r"
                vec4 resize_color(vec3 coords_curr_geo, vec3 size_curr_geo) {
                    vec3 coords_next_geo = niri_curr_geo_to_next_geo * coords_curr_geo;
                    vec3 coords_prev_geo = niri_curr_geo_to_prev_geo * coords_curr_geo;

                    vec3 coords_crop = niri_geo_to_tex_next * coords_next_geo;
                    vec3 coords_stretch = niri_geo_to_tex_next * coords_curr_geo;
                    vec3 coords_stretch_prev = niri_geo_to_tex_prev * coords_curr_geo;

                    // We can crop if the current window size is smaller than the next window
                    // size. One way to tell is by comparing to 1.0 the X and Y scaling
                    // coefficients in the current-to-next transformation matrix.
                    bool can_crop_by_x = niri_curr_geo_to_next_geo[0][0] <= 1.0;
                    bool can_crop_by_y = niri_curr_geo_to_next_geo[1][1] <= 1.0;
                    bool crop = can_crop_by_x && can_crop_by_y;

                    vec4 color;

                    if (crop) {
                        // However, when we crop, we also want to crop out anything outside the
                        // current geometry. This is because the area of the shader is unspecified
                        // and usually bigger than the current geometry, so if we don't fill pixels
                        // outside with transparency, the texture will leak out.
                        //
                        // When stretching, this is not an issue because the area outside will
                        // correspond to client-side decoration shadows, which are already supposed
                        // to be outside.
                        if (coords_curr_geo.x < 0.0 || 1.0 < coords_curr_geo.x ||
                                coords_curr_geo.y < 0.0 || 1.0 < coords_curr_geo.y) {
                            color = vec4(0.0);
                        } else {
                            color = texture2D(niri_tex_next, coords_crop.st);
                        }
                    } else {
                        // If we can't crop, then crossfade.
                        color = texture2D(niri_tex_next, coords_stretch.st);
                        vec4 color_prev = texture2D(niri_tex_prev, coords_stretch_prev.st);
                        color = mix(color_prev, color, niri_clamped_progress);
                    }

                    return color;
                }
            "
        }

        config-notification-open-close {
            // off
            // duration-ms 250
            // curve "ease-out-cubic"
            // spring damping-ratio=0.1 stiffness=1000 epsilon=0.001
        } 
        // Slow down all animations by this factor. Values below 1 speed them up instead.
        // slowdown 3.0
    }

    // Window rules let you adjust behavior for individual windows.
    // Find more information on the wiki:
    // https://github.com/YaLTeR/niri/wiki/Configuration:-Window-Rules

    // Work around WezTerm's initial configure bug
    // by setting an empty default-column-width.
    // window-rule {
    //     // This regular expression is intentionally made as specific as possible,
    //     // since this is the default config, and we want no false positives.
    //     // You can get away with just app-id="wezterm" if you want.
    //     match app-id=r#"^org\.wezfurlong\.wezterm$"#
    //     default-column-width {}
    // }

    // // Example: block out two password managers from screen capture.
    // // (This example rule is commented out with a "/-" in front.)
    // /-window-rule {
    //     match app-id=r#"^org\.keepassxc\.KeePassXC$"#
    //     match app-id=r#"^org\.gnome\.World\.Secrets$"#

    //     block-out-from "screen-capture"

    //     // Use this instead if you want them visible on third-party screenshot tools.
    //     // block-out-from "screencast"
    // }

    // Set default column width to 90% of screen and open new windows as tabs.
    window-rule {
        // open-maximized true
        default-column-width { proportion 0.9; }
        default-column-display "tabbed"
    }

    window-rule {
        // match app-id="Alacritty"
        // match app-id="Adwaita"
        // opacity 0.9
        // opacity 0.5
        // opacity 0.98

        // open-on-output "eDP-1"
        // default-column-width { proportion 0.5; }
        // default-column-width { fixed 400; }
        // default-column-width {}
        // open-maximized true
        // open-fullscreen true
        // block-out-from "screencast"

        // min-width 400
        // max-width 400
        // min-height 400
        // max-height 400

        focus-ring {
            // on
            // active-gradient from="red" to="green"
            // active-color "lightgreen"
            // width 1
        }

        border {
            // off
            // on
            // width 12
            // width 0
            // active-color "#ff808080"
            // active-color "red"
        }

        // draw-border-with-background true
        // draw-border-with-background false

        // geometry-corner-radius 12 24 32 64
        // geometry-corner-radius 999
        // geometry-corner-radius 1
        geometry-corner-radius 6
        clip-to-geometry true
    }

    /-window-rule {
        match app-id="Adwaita"
        // opacity 0.5
        block-out-from "screencast"
        geometry-corner-radius 12
        clip-to-geometry false
        border {
            // off
            width 12
        }
    }

    /-window-rule {
        match app-id="terminal"
        clip-to-geometry false
        geometry-corner-radius 8 8 0 0
        border {
            // width 4
        }
    }

    /-window-rule {
        match app-id="code"
        // opacity 0.98
        border {
            // off
        }
    }

    /-window-rule {
        match app-id="weston."
        // block-out-from "screencast"
        geometry-corner-radius 12 24 32 64
        // geometry-corner-radius 999
        clip-to-geometry true
    }

    // window-rule {
    //     match app-id="Alacritty"
    //     geometry-corner-radius 12 12 0 0
    //     border {
    //         width 2
    //     }
    // }

    window-rule {
        match app-id="foot"
        match app-id="footclient"
        open-floating true
    }

    window-rule {
        match title="simple-egl"
        // min-width 128
        // max-width 128
        // min-height 128
        // max-height 128
        // match is-focused=true
        // match is-active=false
        // opacity 0.9
        // block-out-from "screencast"
        // block-out-from "screen-capture"
        // min-width 1000
        draw-border-with-background false
        // match app-id="mpv"
        // open-on-output "HDMI-A-1"
        // open-maximized true
        // default-column-width { proportion 0.5; }
        // open-fullscreen false
    }

    // Hide Xwayland Video Bridge window
    window-rule {
        match title="^Wayland to X Recording bridge - Xwayland Video Bridge$"
        open-floating true
        min-width 1
        max-width 1
        min-height 1
        max-height 1
    }

    window-rule {
        match is-active=false
        // opacity 0.95
    }

    window-rule {
        match app-id=r#"^org\.telegram\.desktop$"# title="^Media viewer$"
        open-fullscreen false
        default-column-width { proportion 0.5; }
    }

    window-rule {
        match app-id=r#"^org\.wezfurlong\.wezterm$"#
        match app-id="^mpv$"
        default-column-width {}
    }

    // Qt used by OBS doesn't signal min size yet, so do it manually.
    window-rule {
        match app-id=r#"^com\.obsproject\.Studio$"#
        min-width 876
    }

    window-rule {
        match app-id="^blender$"
        match app-id="^gimp"
        default-column-width { fixed 1200; }
    }

    window-rule {
        match app-id="^obsidian$"
        default-column-width { fixed 1000; }
    }

    window-rule {
        match app-id=r#"^org\.mozilla\.firefox$"#
        match app-id=r#"^org\.telegram\.desktop$"#
        exclude app-id=r#"^org\.telegram\.desktop$"# title="^Media viewer$"

        open-on-output "DP-2"
    }

    window-rule {
        match app-id=r#"^org\.mozilla\.firefox$"#

        default-column-width { proportion 0.66667; }
    }

    window-rule {
        match app-id=r#"^org\.keepassxc\.KeePassXC$"#
        match app-id=r#"^org\.gnome\.World\.Secrets$"#
        match app-id=r#"^org\.telegram\.desktop$"#

        // Doesn't quite work: Firefox changes the title one frame early.
        match app-id=r#"^org\.mozilla\.firefox$"# title="- Gmail "
        match app-id=r#"^org\.mozilla\.firefox$"# title="^Google Calendar "
        match app-id=r#"^org\.mozilla\.firefox$"# title="Todoist "
        match app-id=r#"^org\.mozilla\.firefox$"# title=r#"^GNOME( \*)? \| "#
        match app-id=r#"^org\.mozilla\.firefox$"# title=r#"^Element "#
        match app-id=r#"^org\.mozilla\.firefox$"# title=r#"Discord \| "#

        block-out-from "screencast"
        // block-out-from "screen-capture"

        border {
            // active-color "red"
        }
    }

    binds {
        // Keys consist of modifiers separated by + signs, followed by an XKB key name
        // in the end. To find an XKB name for a particular key, you may use a program
        // like wev.
        //
        // "Mod" is a special modifier equal to Super when running on a TTY, and to Alt
        // when running as a winit window.
        //
        // Most actions that you can bind here can also be invoked programmatically with
        // `niri msg action do-something`.

        // Mod-Shift-/, which is usually the same as Mod-?,
        // shows a list of important hotkeys.
        Mod+Shift+Slash { show-hotkey-overlay; }

        // Suggested binds for running programs: terminal, app launcher, screen locker.
        Mod+S { spawn "kitty"; }
        Mod+D { spawn "walker"; }
        Super+Alt+L { spawn "swaylock"; }
        Ctrl+Space { spawn "fuzzel"; }
        Alt+Space { spawn "anyrun"; }
        Mod+Y { spawn "bash" "-c" "pgrep footclient && pkill footclient || footclient" ; }
        // Mod+Return { spawn "walker"; }
        // Mod+T { spawn "foot"; }
        // Mod+R { spawn "wofi"; }
        Mod+Escape { spawn "bash" "-c" "swaylock -f -c 000000"; }

        // Voice Dictation - Momentary
        Mod+X repeat=false { spawn "bash" "-c" "dictate-fw-ptt-auto"; }
        Mod+Shift+X repeat=false { spawn "bash" "-c" "dictate-wc-ptt-auto"; }
        
        // Voice Dictation - Locking/Toggle
        Mod+backslash repeat=false { spawn "bash" "-c" "dictate-fw-ptt-toggle"; }
        Mod+Shift+backslash repeat=false { spawn "bash" "-c" "dictate-wc-ptt-toggle"; }

        // You can also use a shell. Do this if you need pipes, multiple commands, etc.
        // Note: the entire command goes as a single argument in the end.
        // Mod+T { spawn "bash" "-c" "notify-send hello && exec alacritty"; }
        Mod+Shift+B { spawn "bash" "-c" "pgrep waybar && pkill waybar || waybar -c $HOME/.config/niri/waybar/config_vert -s $HOME/.config/niri/waybar/style_vert.css"; }
        Mod+B { spawn "bash" "-c" "pgrep waybar && pkill waybar || waybar -c $HOME/.config/niri/waybar/config -s $HOME/.config/niri/waybar/style.css"; }
      
        Alt+Tab repeat=false { spawn "niriswitcherctl" "show" "--window"; }
        Alt+Shift+Tab repeat=false { spawn "niriswitcherctl" "show" "--window"; }
        Alt+Grave repeat=false { spawn "niriswitcherctl" "show" "--workspace"; }
        Alt+Shift+Grave repeat=false { spawn "niriswitcherctl" "show" "--workspace"; }
        
        // Example volume keys mappings for PipeWire & WirePlumber.
        // The allow-when-locked=true property makes them work even when the session is locked.
        XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"; }
        XF86AudioMute        allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute     allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }

        // Screen brightness controls using brightnessctl.
        // The allow-when-locked=true property makes them work even when the session is locked.
        XF86MonBrightnessUp   allow-when-locked=true { spawn "brightnessctl" "set" "5%+"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "5%-"; }

        // Open/close the Overview: a zoomed-out view of workspaces and windows.
        // You can also move the mouse into the top-left hot corner,
        // or do a four-finger swipe up on a touchpad.
        Mod+O repeat=false { toggle-overview; }
        Mod+Grave repeat=false { toggle-overview; }

        Mod+Q repeat=false { close-window; }

        Mod+Left  { focus-column-left; }
        Mod+Down  { focus-window-down; }
        Mod+Up    { focus-window-up; }
        Mod+Right { focus-column-right; }
        Mod+H     { focus-column-left; }
        Mod+J     { focus-window-down; }
        Mod+K     { focus-window-up; }
        Mod+L     { focus-column-right; }

        Mod+Shift+Left  { move-column-left; }
        Mod+Shift+Down  { move-window-down; }
        Mod+Shift+Up    { move-window-up; }
        Mod+Shift+Right { move-column-right; }
        Mod+Shift+H     { move-column-left; }
        Mod+Shift+J     { move-window-down; }
        Mod+Shift+K     { move-window-up; }
        Mod+Shift+L     { move-column-right; }

        // Alternative commands that move across workspaces when reaching
        // the first or last window in a column.
        // Mod+J     { focus-window-or-workspace-down; }
        // Mod+K     { focus-window-or-workspace-up; }
        // Mod+Ctrl+J     { move-window-down-or-to-workspace-down; }
        // Mod+Ctrl+K     { move-window-up-or-to-workspace-up; }

        Mod+Home { focus-column-first; }
        Mod+End  { focus-column-last; }
        Mod+Ctrl+Home { move-column-to-first; }
        Mod+Ctrl+End  { move-column-to-last; }

        Alt+Ctrl+Left  { focus-monitor-left; }
        Alt+Ctrl+Down  { focus-monitor-down; }
        Alt+Ctrl+Up    { focus-monitor-up; }
        Alt+Ctrl+Right { focus-monitor-right; }
        Alt+Ctrl+H     { focus-monitor-left; }
        Alt+Ctrl+J     { focus-monitor-down; }
        Alt+Ctrl+K     { focus-monitor-up; }
        Alt+Ctrl+L     { focus-monitor-right; }

        Alt+Shift+Ctrl+Left  { move-column-to-monitor-left; }
        Alt+Shift+Ctrl+Down  { move-column-to-monitor-down; }
        Alt+Shift+Ctrl+Up    { move-column-to-monitor-up; }
        Alt+Shift+Ctrl+Right { move-column-to-monitor-right; }
        Alt+Shift+Ctrl+H     { move-column-to-monitor-left; }
        Alt+Shift+Ctrl+J     { move-column-to-monitor-down; }
        Alt+Shift+Ctrl+K     { move-column-to-monitor-up; }
        Alt+Shift+Ctrl+L     { move-column-to-monitor-right; }

        // Alternatively, there are commands to move just a single window:
        // Mod+Shift+Ctrl+Left  { move-window-to-monitor-left; }
        // ...

        // And you can also move a whole workspace to another monitor:
        // Mod+Shift+Ctrl+Left  { move-workspace-to-monitor-left; }
        // ...

        Mod+Ctrl+Down      { focus-workspace-down; }
        Mod+Ctrl+Up        { focus-workspace-up; }
        Mod+U              { focus-workspace-down; }
        Mod+I              { focus-workspace-up; }
        Mod+Shift+Ctrl+Down { move-column-to-workspace-down; }
        Mod+Shift+Ctrl+Up   { move-column-to-workspace-up; }
        Mod+Shift+U         { move-column-to-workspace-down; }
        Mod+Shift+I         { move-column-to-workspace-up; }

        // Alternatively, there are commands to move just a single window:
        // Mod+Ctrl+Page_Down { move-window-to-workspace-down; }
        // ...

        Mod+Ctrl+Page_Down { move-workspace-down; }
        Mod+Ctrl+Page_Up   { move-workspace-up; }
        Mod+Ctrl+U         { move-workspace-down; }
        Mod+Ctrl+I         { move-workspace-up; }

        // You can bind mouse wheel scroll ticks using the following syntax.
        // These binds will change direction based on the natural-scroll setting.
        //
        // To avoid scrolling through workspaces really fast, you can use
        // the cooldown-ms property. The bind will be rate-limited to this value.
        // You can set a cooldown on any bind, but it's most useful for the wheel.
        Mod+WheelScrollDown      cooldown-ms=150 { focus-workspace-down; }
        Mod+WheelScrollUp        cooldown-ms=150 { focus-workspace-up; }
        Mod+Ctrl+WheelScrollDown cooldown-ms=150 { move-column-to-workspace-down; }
        Mod+Ctrl+WheelScrollUp   cooldown-ms=150 { move-column-to-workspace-up; }

        Mod+WheelScrollRight      { focus-column-right; }
        Mod+WheelScrollLeft       { focus-column-left; }
        Mod+Ctrl+WheelScrollRight { move-column-right; }
        Mod+Ctrl+WheelScrollLeft  { move-column-left; }

        // Usually scrolling up and down with Shift in applications results in
        // horizontal scrolling; these binds replicate that.
        Mod+Shift+WheelScrollDown      { focus-column-right; }
        Mod+Shift+WheelScrollUp        { focus-column-left; }
        Mod+Ctrl+Shift+WheelScrollDown { move-column-right; }
        Mod+Ctrl+Shift+WheelScrollUp   { move-column-left; }

        // Similarly, you can bind touchpad scroll "ticks".
        // Touchpad scrolling is continuous, so for these binds it is split into
        // discrete intervals.
        // These binds are also affected by touchpad's natural-scroll, so these
        // example binds are "inverted", since we have natural-scroll enabled for
        // touchpads by default.
        // Mod+TouchpadScrollDown { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.02+"; }
        // Mod+TouchpadScrollUp   { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.02-"; }

        // You can refer to workspaces by index. However, keep in mind that
        // niri is a dynamic workspace system, so these commands are kind of
        // "best effort". Trying to refer to a workspace index bigger than
        // the current workspace count will instead refer to the bottommost
        // (empty) workspace.
        //
        // For example, with 2 workspaces + 1 empty, indices 3, 4, 5 and so on
        // will all refer to the 3rd workspace.
        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }
        Mod+Ctrl+1 { move-column-to-workspace 1; }
        Mod+Ctrl+2 { move-column-to-workspace 2; }
        Mod+Ctrl+3 { move-column-to-workspace 3; }
        Mod+Ctrl+4 { move-column-to-workspace 4; }
        Mod+Ctrl+5 { move-column-to-workspace 5; }
        Mod+Ctrl+6 { move-column-to-workspace 6; }
        Mod+Ctrl+7 { move-column-to-workspace 7; }
        Mod+Ctrl+8 { move-column-to-workspace 8; }
        Mod+Ctrl+9 { move-column-to-workspace 9; }

        // Alternatively, there are commands to move just a single window:
        // Mod+Ctrl+1 { move-window-to-workspace 1; }

        // Switches focus between the current and the previous workspace.
        // Mod+Tab { focus-workspace-previous; }

        // The following binds move the focused window in and out of a column.
        // If the window is alone, they will consume it into the nearby column to the side.
        // If the window is already in a column, they will expel it out.
        Mod+BracketLeft  { consume-or-expel-window-left; }
        Mod+BracketRight { consume-or-expel-window-right; }

        // Consume one window from the right to the bottom of the focused column.
        Mod+Comma  { consume-window-into-column; }
        // Expel the bottom window from the focused column to the right.
        Mod+Period { expel-window-from-column; }

        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+Ctrl+R { reset-window-height; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }

        // Expand the focused column to space not taken up by other fully visible columns.
        // Makes the column "fill the rest of the space".
        Mod+Ctrl+F { expand-column-to-available-width; }

        Mod+C { center-column; }

        // Center all fully visible columns on screen.
        Mod+Ctrl+C { center-visible-columns; }

        // Finer width adjustments.
        // This command can also:
        // * set width in pixels: "1000"
        // * adjust width in pixels: "-5" or "+5"
        // * set width as a percentage of screen width: "25%"
        // * adjust width as a percentage of screen width: "-10%" or "+10%"
        // Pixel sizes use logical, or scaled, pixels. I.e. on an output with scale 2.0,
        // set-column-width "100" will make the column occupy 200 physical screen pixels.
        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }

        // Finer height adjustments when in column with other windows.
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        // Move the focused window between the floating and the tiling layout.
        Mod+Return       { toggle-window-floating; }
        Mod+Shift+Return { switch-focus-between-floating-and-tiling; }

        // Toggle tabbed column display mode.
        // Windows in this column will appear as vertical tabs,
        // rather than stacked on top of each other.
        Mod+W { toggle-column-tabbed-display; }

        // Actions to switch layouts.
        // Note: if you uncomment these, make sure you do NOT have
        // a matching layout switch hotkey configured in xkb options above.
        // Having both at once on the same hotkey will break the switching,
        // since it will switch twice upon pressing the hotkey (once by xkb, once by niri).
        // Mod+Space       { switch-layout "next"; }
        // Mod+Shift+Space { switch-layout "prev"; }

        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }
        
        // Satty screenshot bindings for annotation
        Shift+Print { spawn "screenshot-region"; }
        Super+Print { spawn "screenshot-output"; }
        Super+Shift+Print { spawn "screenshot-window"; }
        

        // Applications such as remote-desktop clients and software KVM switches may
        // request that niri stops processing the keyboard shortcuts defined here
        // so they may, for example, forward the key presses as-is to a remote machine.
        // It's a good idea to bind an escape hatch to toggle the inhibitor,
        // so a buggy application can't hold your session hostage.
        //
        // The allow-inhibiting=false property can be applied to other binds as well,
        // which ensures niri always processes them, even when an inhibitor is active.
        Mod+Shift+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

        // The quit action will show a confirmation dialog to avoid accidental exits.
        Mod+Shift+E { quit; }
        Ctrl+Alt+Delete { quit; }

        // Powers off the monitors. To turn them back on, do any input like
        // moving the mouse or pressing any other key.
        Mod+Shift+P { power-off-monitors; }
    }
  '';
}
