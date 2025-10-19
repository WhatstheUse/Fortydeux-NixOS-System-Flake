{ config, lib, pkgs, username, ... }:

let
  cfg = config.programs.wayfire;
  sessionEnabled = config.sessionProfiles.wayfire.enable or false;
  inherit (lib) mkEnableOption mkIf mkOption types;
in
{
  options.programs.wayfire = {
    enable = mkEnableOption "Wayfire window manager";
    
    enableStylix = mkEnableOption "Enable Stylix theming integration for Wayfire";
    
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra configuration to append to wayfire.ini";
    };
  };

  config = mkIf (cfg.enable && sessionEnabled) {
    # Note: Wayfire and its plugins are provided by the system-level
    # configuration (nixos-config/system-modules/compositor-configs/wayfire-config.nix)
    # which creates a wrapped version with proper plugin paths.
    # We only manage the configuration files here at the home-manager level.

    # Configure Wayfire with Stylix integration using home.file
    # This approach is used because the wayland.windowManager.wayfire module
    # has many default values that conflict with our custom configuration
    home.file.".config/wayfire.ini" = {
      text = ''
        [alpha]
        min_value = 0.100000
        modifier = <alt> <super> 

        [animate]
        close_animation = fire
        duration = 200
        enabled_for = (type equals "toplevel" | (type equals "x-or" & focusable equals true))
        fade_duration = 400
        fade_enabled_for = type equals "overlay"
        fire_color = \#000000FF
        fire_duration = 300
        fire_enabled_for = none
        fire_particle_size = 16.000000
        fire_particles = 2000
        open_animation = zoom
        random_fire_color = false
        startup_duration = 600
        zoom_duration = 500
        zoom_enabled_for = none

        [annotate]
        clear_workspace = <alt> <super> KEY_C
        draw = <alt> <super> BTN_LEFT
        from_center = true
        line_width = 3.000000
        method = draw
        stroke_color = \#FF0000FF

        [autorotate-iio]
        lock_rotation = false
        rotate_down = <ctrl> <super> KEY_DOWN
        rotate_left = <ctrl> <super> KEY_LEFT
        rotate_right = <ctrl> <super> KEY_RIGHT
        rotate_up = <ctrl> <super> KEY_UP

        [autostart]
        autostart0 = pcloud
        autostart_wf_shell = true
        background = wf-background
        gamma = wlsunset
        idle = swayidle -w timeout 3600 'swaylock -f -c 000000' before-sleep 'swaylock -f -c 000000'
        notifications = mako
        outputs = kanshi
        portal = /usr/libexec/xdg-desktop-portal-wlr
        import-portals = bash -lc 'systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && systemctl --user start --no-block xdg-desktop-portal-kde.service'

        [background]
        cycle_timeout = 150
        ${if cfg.enableStylix then "image = ${config.stylix.image}" else "# image = /home/${username}/.config/wayfire/wallpapers/balloon-wp.jpg"}
        preserve_aspect = false
        randomize = false
        fill_mode = fill_and_crop

        [background-view]
        app_id = mpv
        command = mpv --loop=inf
        file = 
        inhibit_input = true

        [bench]
        average_frames = 25
        position = top_center

        [blur]
        blur_by_default = type is "toplevel"
        bokeh_degrade = 1
        bokeh_iterations = 15
        bokeh_offset = 5.000000
        box_degrade = 1
        box_iterations = 2
        box_offset = 1.000000
        gaussian_degrade = 1
        gaussian_iterations = 2
        gaussian_offset = 1.000000
        kawase_degrade = 8
        kawase_iterations = 2
        kawase_offset = 2.000000
        method = kawase
        saturation = 1.000000
        toggle = none

        [command]
        binding_launcher = <ctrl> KEY_SPACE
        command_launcher = fuzzel
        binding_anyrun = <alt> KEY_SPACE
        command_anyrun = anyrun
        binding_lock = <super> KEY_L
        command_lock = swaylock
        binding_logout = <super> <shift> KEY_L
        command_logout = wleave
        binding_exit = <super> <shift> KEY_E
        command_exit = pkill -KILL wayfire
        binding_mute = KEY_MUTE
        binding_screenshot_region = KEY_SYSRQ
        command_screenshot_region = screenshot-region
        binding_screenshot_output = <super> KEY_SYSRQ
        command_screenshot_output = screenshot-output
        binding_screenshot_output_region = <super> <shift> KEY_SYSRQ
        command_screenshot_output_region = screenshot-window
        binding_terminal = <super> KEY_S
        command_terminal = kitty
        repeatable_binding_light_down = KEY_BRIGHTNESSDOWN
        command_light_down = brightnessctl set 5%-
        repeatable_binding_light_up = KEY_BRIGHTNESSUP
        command_light_up = brightnessctl set 5%+
        command_mute = amixer set Master toggle
        repeatable_binding_volume_down = KEY_VOLUMEDOWN
        command_volume_down = amixer set Master 5%-
        repeatable_binding_volume_up = KEY_VOLUMEUP
        command_volume_up = amixer set Master 5%+
        binding_dictate_fw_auto = <super> KEY_X
        command_dictate_fw_auto = dictate-fw-ptt-auto 5
        binding_dictate_wc_auto = <super> <shift> KEY_X
        command_dictate_wc_auto = dictate-wc-ptt-auto 5
        binding_dictate_fw_toggle = <super> KEY_BACKSLASH
        command_dictate_fw_toggle = dictate-fw-ptt-toggle
        binding_dictate_wc_toggle = <super> <shift> KEY_BACKSLASH
        command_dictate_wc_toggle = dictate-wc-ptt-toggle

        [core]
        background_color = ${if cfg.enableStylix then config.lib.stylix.colors.base00 else "\\#1A1A1AFF"}
        close_top_view = <super> KEY_Q | <alt> KEY_F4
        focus_button_with_modifiers = false
        focus_buttons = BTN_LEFT | BTN_MIDDLE | BTN_RIGHT
        focus_buttons_passthrough = true
        max_render_time = -1
        plugins = alpha   animate   autostart   command   cube   decoration   expo   fast-switcher   fisheye   foreign-toplevel   gtk-shell   idle   invert   move   oswitch   place   resize   switcher   vswitch   window-rules   wm-actions   wobbly   wrot   zoom   extra-gestures   vswipe   blur   water   annotate   force-fullscreen   grid   follow-focus workspace-names
        preferred_decoration_mode = client
        transaction_timeout = 100
        vheight = 3
        vwidth = 4
        xwayland = true

        [crosshair]
        line_color = \#FF0000FF
        line_width = 2

        [cube]
        activate = <alt> <ctrl> BTN_LEFT
        background = ${if cfg.enableStylix then config.lib.stylix.colors.base00 else "\\#1A1A1AFF"}
        background_mode = simple
        cubemap_image = 
        deform = 0
        initial_animation = 350
        light = true
        rotate_left = <alt> <ctrl> KEY_H
        rotate_right = <alt> <ctrl> KEY_L
        skydome_mirror = true
        skydome_texture = 
        speed_spin_horiz = 0.020000
        speed_spin_vert = 0.020000
        speed_zoom = 0.070000
        zoom = 0.100000

        [decoration]
        active_color = ${if cfg.enableStylix then config.lib.stylix.colors.base0D else "\\#415E9A"}
        border_size = 2
        button_order = minimize maximize close
        font = sans-serif
        ignore_views = none
        inactive_color = ${if cfg.enableStylix then config.lib.stylix.colors.base01 else "\\#333333DD"}
        title_height = 20

        [dock]
        autohide_duration = 300
        css_path = 
        position = bottom

        [expo]
        background = ${if cfg.enableStylix then config.lib.stylix.colors.base00 else "\\#1A1A1AFF"}
        duration = 300
        inactive_brightness = 0.700000
        keyboard_interaction = true
        offset = 10
        select_workspace_1 = KEY_1
        select_workspace_2 = KEY_2
        select_workspace_3 = KEY_3
        select_workspace_4 = KEY_4
        select_workspace_5 = KEY_5
        select_workspace_6 = KEY_6
        select_workspace_7 = KEY_7
        select_workspace_8 = KEY_8
        select_workspace_9 = KEY_9
        toggle = <super>
        transition_length = 200

        [extra-gestures]
        close_fingers = 20
        move_delay = 500
        move_fingers = 3

        [fast-switcher]
        activate = <super> KEY_TAB
        activate_backward = <super> <shift> KEY_TAB
        inactive_alpha = 0.700000

        [fisheye]
        radius = 450.000000
        toggle = <ctrl> <super> KEY_F
        zoom = 7.000000

        [focus-change]
        cross-output = false
        cross-workspace = false
        down = <shift> <super> KEY_DOWN
        grace-down = 1
        grace-left = 1
        grace-right = 1
        grace-up = 1
        left = <shift> <super> KEY_LEFT
        raise-on-change = true
        right = <shift> <super> KEY_RIGHT
        scan-height = 0
        scan-width = 0
        up = <shift> <super> KEY_UP

        [focus-steal-prevent]
        cancel_keys = KEY_ENTER
        deny_focus_views = none
        timeout = 1000

        [follow-focus]
        change_output = true
        change_view = true
        focus_delay = 0
        raise_on_top = true
        threshold = 0

        [force-fullscreen]
        constrain_pointer = false
        constraint_area = view
        key_toggle_fullscreen = <alt> <super> KEY_F
        preserve_aspect = true
        transparent_behind_views = true
        x_skew = 0.000000
        y_skew = 0.000000

        [foreign-toplevel]

        [grid]
        duration = 300
        restore = <super> KEY_DOWN | <super> KEY_KP0
        slot_b = <super> KEY_KP2
        slot_bl = <super> KEY_KP1
        slot_br = <super> KEY_KP3
        slot_c = <super> KEY_UP | <super> KEY_KP5
        slot_l = <super> KEY_LEFT | <super> KEY_KP4
        slot_r = <super> KEY_RIGHT | <super> KEY_KP6
        slot_t = <super> KEY_KP8
        slot_tl = <super> KEY_KP7
        slot_tr = <super> KEY_KP9
        type = crossfade

        [gtk-shell]

        [hide-cursor]
        hide_delay = 2000
        toggle = <ctrl> <super> KEY_H

        [hinge]
        filename = /sys/bus/iio/devices/iio:device1/in_angl0_raw
        flip_degree = 180
        poll_freq = 200

        [idle]
        cube_max_zoom = 1.500000
        cube_rotate_speed = 1.000000
        cube_zoom_speed = 1000
        disable_initially = false
        disable_on_fullscreen = true
        dpms_timeout = 2400
        screensaver_timeout = 1200
        toggle = <super> <shift> KEY_I

        [input]
        click_method = clickfinger
        cursor_size = ${if cfg.enableStylix then toString config.stylix.cursor.size else "32"}
        cursor_theme = ${if cfg.enableStylix then config.stylix.cursor.name else "phinger-cursors-light"}
        disable_touchpad_while_mouse = false
        disable_touchpad_while_typing = true
        drag_lock = false
        gesture_sensitivity = 1.000000
        kb_capslock_default_state = false
        kb_numlock_default_state = true
        kb_repeat_delay = 400
        kb_repeat_rate = 40
        left_handed_mode = false
        middle_emulation = false
        modifier_binding_timeout = 400
        mouse_accel_profile = default
        mouse_cursor_speed = 0.000000
        mouse_scroll_speed = 1.0
        mouse_natural_scroll = true
        natural_scroll = true
        scroll_method = two-finger
        tablet_motion_mode = default
        tap_to_click = true
        touchpad_accel_profile = default
        touchpad_cursor_speed = 0.000000
        touchpad_scroll_speed = 1.000000
        xkb_layout = us
        xkb_model = 
        xkb_options = 
        xkb_rules = evdev
        xkb_variant = 

        [input-device]
        output = 

        [input-method-v1]

        [invert]
        preserve_hue = false
        toggle = <super> KEY_I

        [ipc]

        [ipc-rules]

        [join-views]

        [keycolor]
        color = \#E30CFFFF
        opacity = 0.250000
        threshold = 0.500000

        [mag]
        default_height = 500
        toggle = <alt> <super> KEY_M
        zoom_level = 75

        [move]
        activate = <super> BTN_LEFT
        enable_snap = true
        enable_snap_off = true
        join_views = false
        preview_base_border = \#404080CC
        preview_base_color = \#8080FF80
        preview_border_width = 3
        quarter_snap_threshold = 50
        snap_off_threshold = 10
        snap_threshold = 10
        workspace_switch_after = -1

        [obs]

        [oswitch]
        next_output = <super> KEY_O
        next_output_with_win = <shift> <super> KEY_O
        prev_output = 
        prev_output_with_win = 

        [output]
        depth = 8
        mode = auto
        position = auto
        scale = 1.000000
        transform = normal
        vrr = false

        # eDP-1 configuration for high-DPI laptop displays (Surface Books, etc.)
        # Scale 2.0 is appropriate for 3240x2160 displays
        [output:eDP-1]
        depth = 8
        mode = auto
        position = 0, 0
        scale = 2.000000
        transform = normal
        vrr = false

        [output:HDMI-A-1]
        depth = 8
        mode = 1920x1080@60.000000
        position = 5060, 0
        scale = 1.00000
        transform = normal
        vrr = false

        [panel]
        autohide = false
        autohide_duration = 300
        background_color = gtk_headerbar
        battery_font = default
        battery_icon_invert = true
        battery_icon_size = 24
        battery_status = 1
        clock_font = default
        clock_format = %e %A %H:%M
        css_path = 
        icon_theme = Adwaita
        launchers_size = 42
        launchers_spacing = 4
        layer = top
        menu_fuzzy_search = true
        menu_icon = 
        menu_logout_command = wayland-logout
        minimal_height = 24
        network_icon_invert_color = false
        network_icon_size = 32
        network_status = 1
        network_status_font = default
        network_status_use_color = false
        position = top
        volume_display_timeout = 2.500000
        widgets_center = clock
        widgets_left = spacing4 menu spacing18 launchers
        widgets_right = network battery

        [place]
        mode = center

        [preserve-output]
        last_output_focus_timeout = 10000

        [resize]
        activate = <super> <shift> BTN_LEFT
        activate_preserve_aspect = none

        [scale]
        allow_zoom = false
        bg_color = ${if cfg.enableStylix then config.lib.stylix.colors.base00 else "\\#1A1A1AE6"}
        duration = 750
        inactive_alpha = 0.750000
        include_minimized = false
        interact = false
        middle_click_close = false
        minimized_alpha = 0.450000
        outer_margin = 0
        spacing = 50
        text_color = ${if cfg.enableStylix then config.lib.stylix.colors.base05 else "\\#CCCCCCFF"}
        title_font_size = 16
        title_overlay = all
        title_position = center
        toggle = <super> KEY_P
        toggle_all = 

        [scale-title-filter]
        bg_color = \#00000080
        case_sensitive = false
        font_size = 30
        overlay = true
        share_filter = false
        text_color = \#CCCCCCCC

        [shortcuts-inhibit]
        break_grab = none
        ignore_views = none
        inhibit_by_default = none

        [showrepaint]
        reduce_flicker = true
        toggle = <alt> <super> KEY_S

        [simple-tile]
        animation_duration = 0
        button_move = <super> BTN_LEFT
        button_resize = <super> BTN_RIGHT
        inner_gap_size = 5
        keep_fullscreen_on_adjacent = true
        key_focus_above = <super> KEY_K
        key_focus_below = <super> KEY_J
        key_focus_left = <super> KEY_H
        key_focus_right = <super> KEY_L
        key_toggle = <super> KEY_T
        outer_horiz_gap_size = 0
        outer_vert_gap_size = 0
        preview_base_border = \#404080CC
        preview_base_color = \#8080FF80
        preview_border_width = 3
        tile_by_default = all

        [switcher]
        next_view = <alt> KEY_TAB
        prev_view = <alt> <shift> KEY_TAB
        speed = 500
        view_thumbnail_rotation = 30
        view_thumbnail_scale = 1.000000

        [view-shot]
        capture = <alt> <super> BTN_MIDDLE
        command = notify-send "The view under cursor was captured to %f"
        filename = /tmp/snapshot-%F-%T.png

        [vswipe]
        background = ${if cfg.enableStylix then config.lib.stylix.colors.base00 else "\\#1A1A1AFF"}
        delta_threshold = 24.000000
        duration = 180
        enable_free_movement = false
        enable_horizontal = true
        enable_smooth_transition = false
        enable_vertical = true
        fingers = 3
        gap = 32.000000
        speed_cap = 0.050000
        speed_factor = 256.000000
        threshold = 0.350000

        [vswitch]
        background = ${if cfg.enableStylix then config.lib.stylix.colors.base00 else "\\#1A1A1AFF"}
        binding_down = <ctrl> <super> KEY_DOWN
        binding_last = 
        binding_left = <ctrl> <super> KEY_LEFT
        binding_right = <ctrl> <super> KEY_RIGHT
        binding_up = <ctrl> <super> KEY_UP
        binding_win_down = <alt> <shift> <super> KEY_DOWN
        binding_win_left = <alt> <shift> <super> KEY_LEFT
        binding_win_right = <alt> <shift> <super> KEY_RIGHT
        binding_win_up = <alt> <shift> <super> KEY_UP
        duration = 300
        gap = 20
        send_win_down = 
        send_win_last = 
        send_win_left = 
        send_win_right = 
        send_win_up = 
        with_win_down = <ctrl> <shift> <super> KEY_DOWN
        with_win_last = 
        with_win_left = <ctrl> <shift> <super> KEY_LEFT
        with_win_right = <ctrl> <shift> <super> KEY_RIGHT
        with_win_up = <ctrl> <shift> <super> KEY_UP
        wraparound = false

        [water]
        activate = <ctrl> <super> BTN_LEFT

        [wayfire-shell]
        toggle_menu = <super>

        [window-rules]

        [winzoom]
        dec_x_binding = <ctrl> <super> KEY_LEFT
        dec_y_binding = <ctrl> <super> KEY_UP
        inc_x_binding = <ctrl> <super> KEY_RIGHT
        inc_y_binding = <ctrl> <super> KEY_DOWN
        modifier = <ctrl> <super> 
        nearest_filtering = false
        preserve_aspect = true
        zoom_step = 0.100000

        [wm-actions]
        minimize = none
        send_to_back = none
        toggle_always_on_top = none
        toggle_fullscreen = <super> <shift> KEY_F
        toggle_maximize = <super> KEY_F
        toggle_showdesktop = none
        toggle_sticky = none

        [wobbly]
        friction = 3.000000
        grid_resolution = 6
        spring_k = 8.000000

        [workarounds]
        all_dialogs_modal = true
        app_id_mode = stock
        discard_command_output = true
        dynamic_repaint_delay = false
        enable_input_method_v2 = false
        enable_so_unloading = false
        force_preferred_decoration_mode = false
        remove_output_limits = false
        use_external_output_configuration = false

        [workspace-names]
        background_color = ${if cfg.enableStylix then config.lib.stylix.colors.base01 else "\\#333333B3"}
        background_radius = 30.000000
        display_duration = 500
        font = sans-serif
        margin = 0
        position = center
        show_option_names = false
        text_color = ${if cfg.enableStylix then config.lib.stylix.colors.base05 else "\\#FFFFFFFF"}

        [wrot]
        activate = <ctrl> <super> BTN_RIGHT
        activate-3d = <shift> <super> BTN_RIGHT
        invert = false
        reset = <ctrl> <super> KEY_R
        reset-one = <super> KEY_R
        reset_radius = 25.000000
        sensitivity = 24

        [wsets]
        label_duration = 2000

        [xdg-activation]

        [zoom]
        interpolation_method = 0
        modifier = <super> 
        smoothing_duration = 300
        speed = 0.010000

        # Host-specific output configurations
        # Blacktetra: LG ULTRAWIDE main display (DP-1 connector)
        [output:LG Electronics LG ULTRAWIDE 308NTTQD5209]
        depth = 8
        mode = 3440x1440@159.962006
        position = 0, 0
        scale = 1.00000
        transform = normal
        vrr = false

        # Archerfish: Sceptre F27 secondary display (DP-1 connector)
        [output:Sceptre Tech Inc Sceptre F27 0x00000001]
        depth = 8
        mode = 1920x1080@75.001999
        position = 1620, 0
        scale = 1.00000
        transform = normal
        vrr = false

        ${cfg.extraConfig}
      '';
    };

    # Configure wf-shell with Stylix integration
    home.file.".config/wf-shell.ini" = mkIf cfg.enableStylix {
      text = ''
        [background]
        cycle_timeout = 150
        fade_duration = 1000
        image = ${config.stylix.image}
        fill_mode = fill_and_crop
        preserve_aspect = false
        randomize = false

        [dock]
        autohide = true
        autohide_duration = 300
        css_path = 
        dock_height = 50
        edge_offset = 20
        icon_height = 42
        position = bottom

        [panel]
        autohide = false
        autohide_duration = 300
        background_color = ${config.lib.stylix.colors.base00}CC
        battery_font = default
        battery_icon_invert = 1
        battery_icon_size = 24
        battery_status = 0
        clock_font = default
        clock_format = %e %A %H:%M
        commands_output_max_chars = 10
        css_path = 
        edge_offset = 20
        hibernate_command = systemctl hibernate
        icon_theme = Adwaita
        launcher_brave = brave-browser.desktop
        launcher_firefox = firefox.desktop
        launchers_animation_duration = 200
        launchers_size = 42
        launchers_spacing = 4
        layer = top
        logout_command = wayland-logout
        menu_fuzzy_search = true
        menu_icon = /home/${username}/.config/logos/nix-snowflake-colours.svg
        menu_logout_command = wleave
        menu_min_content_height = 500
        menu_min_content_width = 500
        middle_click_close = false
        minimal_height = 24
        network_icon_invert_color = 1
        network_icon_size = 24
        network_onclick_command = default
        network_status = 0
        network_status_font = default
        network_status_use_color = false
        notifications_autohide_timeout = 2.500000
        notifications_critical_in_dnd = true
        notifications_icon_size = 32
        position = top
        reboot_command = systemctl reboot
        shutdown_command = systemctl poweroff
        suspend_command = systemctl suspend
        switchuser_command = dm-tool switch-to-greeter
        tray_icon_size = 32
        tray_menu_on_middle_click = false
        tray_smooth_scrolling_threshold = 5
        volume_display_timeout = 2.500000
        volume_icon_size = 32
        volume_scroll_sensitivity = 0.050000
        widgets_center = clock
        widgets_left = menu launchers window-list
        widgets_right = command-output tray volume network battery

        # Configuration for the command output widget
        [command-output]
        command0 = date +%H:%M
        interval0 = 60
        command1 = date +%Y-%m-%d
        interval1 = 3600
      '';
    };
  };
}
