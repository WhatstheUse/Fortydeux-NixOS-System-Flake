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

    # Polkit authentication agent for standalone compositors and COSMIC
    # KDE Plasma provides its own polkit-kde-agent, so skip it there via ConditionEnvironment
    systemd.user.services.polkit-agent = {
      Unit = {
        Description = "PolicyKit Authentication Agent";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
        ConditionEnvironment = "!KDE_FULL_SESSION";
      };
      Service = {
        ExecStart = "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent";
        Restart = "on-failure";
        RestartSec = 1;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
