{ config, pkgs, lib, inputs, ... }:

let
  inherit (lib) mkEnableOption;

  # Kirigami QML path for Noctalia (workaround for libplasma override issue)
  # This is needed because libplasma's partial kirigami overrides the full kirigami package
  kirigamiQmlPath = "${lib.getLib pkgs.kdePackages.kirigami}/lib/qt-6/qml";
in
{
  imports = [
    ./dotfiles/kanshi.nix
    ./compositor-configs/stasis-config.nix
    inputs.noctalia.homeModules.default
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
  };

  config = {
    # Common window manager functionality
    # Individual compositor configs are imported in host-specific files

    # Noctalia desktop shell - shared across compositors
    programs.noctalia-shell = {
      enable = true;
      settings = {
        # Configuration will be done through the wizard initially
      };
    };

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
  };
}
