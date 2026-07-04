{ config, pkgs, lib, ... }:

let
  sessionEnabled = config.sessionProfiles.labwc.enable or false;

  # Kirigami QML path for Noctalia (workaround for libplasma override issue),
  # same as the Sway/Noctalia setup.
  kirigamiQmlPath = "${lib.getLib pkgs.kdePackages.kirigami}/lib/qt-6/qml";
in
# Gated on sessionProfiles.labwc.enable. Labwc is a wlroots-based stacking
# compositor with a first-class home-manager module (wayland.windowManager.labwc),
# so unlike MiracleWM we configure it natively rather than via raw dotfiles.
lib.mkIf sessionEnabled {
  home.packages = with pkgs; [
    swaybg
    anyrun
    fuzzel
    grim
    slurp
    satty
    wl-clipboard
    brightnessctl
    playerctl
  ];

  wayland.windowManager.labwc = {
    enable = true;

    # UWSM owns the session: it imports the environment and activates
    # graphical-session.target. Labwc's own systemd integration would do the
    # same thing and double-initialise the session, so disable it (mirrors the
    # systemd.enable = false approach used for Hyprland under UWSM).
    systemd.enable = false;

    rc = {
      focus.followMouse = "yes";

      keyboard = {
        default = true;
        keybind = [
          # Terminal
          {
            "@key" = "W-s";
            action = { "@name" = "Execute"; "@command" = "kitty"; };
          }
          # Application launchers
          {
            "@key" = "A-space";
            action = { "@name" = "Execute"; "@command" = "anyrun"; };
          }
          {
            "@key" = "W-space";
            action = { "@name" = "Execute"; "@command" = "noctalia msg panel-toggle launcher"; };
          }
          # Close focused window
          {
            "@key" = "W-q";
            action = { "@name" = "Close"; };
          }
          # Maximize
          {
            "@key" = "W-f";
            action = { "@name" = "ToggleMaximize"; };
          }
          # Fullscreen
          {
            "@key" = "W-S-f";
            action = { "@name" = "ToggleFullscreen"; };
          }
          # Exit the session cleanly via UWSM (parity with the other compositors)
          {
            "@key" = "W-S-e";
            action = { "@name" = "Execute"; "@command" = "uwsm stop"; };
          }
          # Screenshot (full screen) -> Satty editor
          {
            "@key" = "Print";
            action = {
              "@name" = "Execute";
              "@command" = "sh -c 'grim -t ppm - | satty -f - --output-filename $HOME/Pictures/Screenshots/satty-$(date +%Y%m%d-%H%M%S).png'";
            };
          }
          # Workspace switching
          {
            "@key" = "W-1";
            action = { "@name" = "GoToDesktop"; "@to" = "1"; };
          }
          {
            "@key" = "W-2";
            action = { "@name" = "GoToDesktop"; "@to" = "2"; };
          }
          {
            "@key" = "W-3";
            action = { "@name" = "GoToDesktop"; "@to" = "3"; };
          }
          {
            "@key" = "W-4";
            action = { "@name" = "GoToDesktop"; "@to" = "4"; };
          }
          {
            "@key" = "A-C-Left";
            action = { "@name" = "GoToDesktop"; "@to" = "left"; };
          }
          {
            "@key" = "A-C-Right";
            action = { "@name" = "GoToDesktop"; "@to" = "right"; };
          }
          # Move focused window to a workspace
          {
            "@key" = "W-S-1";
            action = { "@name" = "SendToDesktop"; "@to" = "1"; };
          }
          {
            "@key" = "W-S-2";
            action = { "@name" = "SendToDesktop"; "@to" = "2"; };
          }
          {
            "@key" = "W-S-3";
            action = { "@name" = "SendToDesktop"; "@to" = "3"; };
          }
          {
            "@key" = "W-S-4";
            action = { "@name" = "SendToDesktop"; "@to" = "4"; };
          }
          # Audio / brightness media keys
          {
            "@key" = "XF86AudioRaiseVolume";
            action = { "@name" = "Execute"; "@command" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"; };
          }
          {
            "@key" = "XF86AudioLowerVolume";
            action = { "@name" = "Execute"; "@command" = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"; };
          }
          {
            "@key" = "XF86AudioMute";
            action = { "@name" = "Execute"; "@command" = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; };
          }
          {
            "@key" = "XF86MonBrightnessUp";
            action = { "@name" = "Execute"; "@command" = "brightnessctl set 5%+"; };
          }
          {
            "@key" = "XF86MonBrightnessDown";
            action = { "@name" = "Execute"; "@command" = "brightnessctl set 5%-"; };
          }
        ];
      };
    };

    extraConfig = ''
      <libinput>
        <device category="default">
          <naturalScroll>yes</naturalScroll>
          <tap>yes</tap>
        </device>
      </libinput>
      <desktops number="4" />
    '';

    menu = [
      {
        menuId = "root-menu";
        label = "";
        icon = "";
        items = [
          {
            label = "Terminal";
            action = { name = "Execute"; command = "kitty"; };
          }
          {
            label = "Launcher";
            action = { name = "Execute"; command = "fuzzel"; };
          }
          {
            label = "Reconfigure";
            action = { name = "Reconfigure"; };
          }
          {
            label = "Exit";
            action = { name = "Execute"; command = "uwsm stop"; };
          }
        ];
      }
    ];

    # Autostart runs as a plain shell script. Hand off to UWSM first, then set
    # the wallpaper (Stylix image, like Sway) and launch the Noctalia shell.
    autostart = [
      "uwsm finalize"
      "swaybg -m fill -i ${config.stylix.image} &"
      ''QML2_IMPORT_PATH="${kirigamiQmlPath}" noctalia &''
    ];
  };
}
