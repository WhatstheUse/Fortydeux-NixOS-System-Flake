{ config, pkgs, lib, inputs, ... }:

let
  inherit (lib) mkEnableOption;
in
{
  imports = [
    ./dotfiles/kanshi.nix
    ./compositor-configs/stasis-config.nix
    ./compositor-configs/noctalia-shell.nix
  ];

  options.sessionProfiles = {
    plasma.enable =
      mkEnableOption "KDE Plasma desktop environment" // { default = true; };
    cosmic.enable = mkEnableOption "COSMIC desktop environment";
    hyprland.enable = mkEnableOption "Hyprland compositor";
    niri.enable = mkEnableOption "Niri compositor";
    sway.enable = mkEnableOption "Sway compositor";
    river.enable = mkEnableOption "River compositor";
    wayfire.enable = mkEnableOption "Wayfire compositor";
    mangowc.enable = mkEnableOption "MangoWC compositor";
    scroll.enable = mkEnableOption "Scroll compositor";
  };

  config = {
    # Common window manager functionality
    # Individual compositor configs are imported in host-specific files

    home.packages = (with pkgs; [
      # kdePackages.yakuake #Drop-down terminal
      swaybg # Wallpaper setter used by multiple compositors (Sway, River, Niri)
      swaylock-effects # Screen locker used by multiple compositors
      swayidle # Idle management daemon used by multiple compositors
      wlopm # Wayland output power management (used by River for screen-off)
      lxqt.lxqt-policykit # Polkit authentication agent for standalone compositors
    ]) ++ [
      # Wooz screen magnifier for compositors without built-in zoom (Niri, Sway, River)
      inputs.wooz.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
    
    wayland.windowManager = {
      labwc = {
        enable = true;
        menu = [
          {
            menuId = "root-menu";
            label = "";
            icon = "";
            items = [
              {
                label = "BeMenu";
                action = {
                  name = "Execute";
                  command = "bemenu-run";
                };
              }
              {
                label = "Reconfigure";
                action = {
                  name = "Reconfigure";
                };
              }
              {
                label = "Exit";
                action = {
                  name = "Exit";
                };
              }
              
            ];
          }
        ];      
      };
    };

    services.stalonetray = {
      enable = true;
      config = {
        icon_size = 100;
      };
    };

    programs.wleave = {
      enable = true;
    };

    # Suppress the XDG autostart entry for lxqt-policykit-agent.
    # Without this, compositors that activate xdg-desktop-autostart.target (e.g. Niri)
    # start a second instance alongside the systemd service below, causing both to fail
    # to register on D-Bus.
    xdg.configFile."autostart/lxqt-policykit-agent.desktop".text = ''
      [Desktop Entry]
      Hidden=true
    '';

    # Polkit authentication agent for standalone compositors and COSMIC
    # KDE Plasma provides its own polkit-kde-agent, so skip it there via ConditionEnvironment.
    # We check XDG_CURRENT_DESKTOP=KDE rather than KDE_FULL_SESSION because Hyprland sets
    # KDE_FULL_SESSION=true intentionally (for kwallet), but only real Plasma sets XDG_CURRENT_DESKTOP=KDE.
    systemd.user.services.polkit-agent = {
      Unit = {
        Description = "PolicyKit Authentication Agent";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = "!XDG_CURRENT_DESKTOP=KDE";
      };
      Service = {
        # Kill any stale instance before starting (e.g. left over from a previous session
        # that didn't clean up cleanly). The '-' prefix tells systemd to ignore non-zero
        # exit (pkill returns 1 when no matching process is found, which is fine).
        ExecStartPre = "-${pkgs.procps}/bin/pkill -x lxqt-policykit-agent";
        ExecStart = "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent";
        Restart = "on-failure";
        RestartSec = 1;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
