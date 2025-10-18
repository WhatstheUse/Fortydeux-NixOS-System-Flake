{ config, pkgs, inputs, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkOption
    mkMerge
    mkIf
    mkDefault
    types
    optional
    optionalAttrs
    unique;

  cfg = config.sessionProfiles;
  portalCfg = cfg.portal;

  portalBaseFragments =
    [
      {
        common = {
          default = [ "gtk" ];
          "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        };
      }
    ]
    ++ optional cfg.plasma.enable {
      plasma = {
        default = [ "kde" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "kde" ];
        "org.freedesktop.impl.portal.Secret" = [ "kde" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "kde" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "kde" ];
      };
    };

  basePortalPackages = with pkgs; [
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
  ] ++ optional cfg.plasma.enable pkgs.kdePackages.xdg-desktop-portal-kde;

  anyWlr =
    cfg.hyprland.enable
    || cfg.river.enable
    || cfg.sway.enable
    || cfg.wayfire.enable;
in
{
  options.sessionProfiles = {
    plasma.enable =
      mkEnableOption "KDE Plasma desktop environment" // { default = true; };
    cosmic.enable = mkEnableOption "COSMIC desktop environment";
    hyprland.enable = mkEnableOption "Hyprland compositor";
    niri.enable = mkEnableOption "Niri compositor";
    sway.enable = mkEnableOption "Sway compositor";
    river.enable = mkEnableOption "River compositor";
    wayfire.enable = mkEnableOption "Wayfire compositor";

    portal.configFragments = mkOption {
      type = types.listOf types.attrs;
      default = [ ];
      description = "Portal configuration fragments contributed by session modules.";
    };

    portal.extraPortals = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional xdg-desktop-portal implementations contributed by session modules.";
    };

    sessionPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Display manager session packages contributed by session modules.";
    };
  };

  config = {
    # UWSM - Universal Wayland Session Manager
    programs.uwsm = {
      enable = true;
      waylandCompositors = optionalAttrs cfg.hyprland.enable {
        hyprland = {
          prettyName = "Hyprland";
          comment = "Hyprland compositor managed by UWSM";
          binPath = "/run/current-system/sw/bin/Hyprland";
        };
      };
    };

    # XDG Desktop Portal - Common configuration with compositor contributions
    xdg.portal = {
      enable = true;
      config = mkMerge (portalBaseFragments ++ portalCfg.configFragments);
      extraPortals = unique (basePortalPackages ++ portalCfg.extraPortals);
      wlr.enable = mkDefault anyWlr;
      xdgOpenUsePortal = true;
    };

    # Register session packages with the display manager
    services.displayManager.sessionPackages = unique cfg.sessionPackages;

    # Environment Variables - Optimized for all compositors
    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        XCURSOR_SIZE = "32";
        XCURSOR_THEME = "phinger-cursors-light";
      };

      variables.NIXOS_OZONE_WL = "1";
    };

    # Enable dconf for proper settings management
    programs.dconf.enable = true;

    # System packages - Common Wayland infrastructure and utilities
    environment.systemPackages = with pkgs; [
      wl-clipboard
      wlr-randr
      wlroots
      xdg-utils
      xdg-desktop-portal
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      kdePackages.xdg-desktop-portal-kde
      gnome-keyring
      kdePackages.breeze-icons
      adwaita-icon-theme
      hicolor-icon-theme
      papirus-icon-theme
      gnome-icon-theme
      gdk-pixbuf
      librsvg
      gtk3
      gtk4
      gtk3.dev
      shared-mime-info
      wofi
      rofi
      bemenu
      mako
      dunst
      libnotify
      grim
      slurp
      brightnessctl
      playerctl
      swayidle
      swaylock-effects
      pavucontrol
      xfce.thunar
      xfce.thunar-archive-plugin
      xfce.thunar-volman
      xfce.xfce4-terminal
      networkmanagerapplet
      lm_sensors
      kanshi
      wdisplays
      wlogout
      wlsunset
      yambar
      fastfetch
      phinger-cursors
    ];
  };
}
