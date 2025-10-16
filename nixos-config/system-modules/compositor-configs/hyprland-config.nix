{ config, pkgs, inputs, lib, ... }:

{
  # Hyprland compositor configuration
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = pkgs.hyprland;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  # Hyprland-specific system packages
  environment.systemPackages = with pkgs; [
    # Hyprland core packages
    hyprland
    hyprlock
    hypridle
    
    # Hyprland-specific utilities
    iio-hyprland  # Hyprland tablet layout listener/changer
    wvkbd  # On-screen virtual keyboard for wlroots
  ];

  # XDG Desktop Portal configuration for Hyprland
  xdg.portal = {
    enable = true;
    config = {
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "kde" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  # Hyprshell Cachix cache configuration
  nix.settings = {
    # Add Hyprshell Cachix cache for faster builds
    substituters = [ "https://hyprshell.cachix.org" ];
    trusted-public-keys = [ "hyprshell.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };
}
