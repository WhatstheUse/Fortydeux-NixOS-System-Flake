{ config, pkgs, inputs, lib, ... }:

{
  # Niri compositor configuration
  programs.niri = {
    enable = true;
    # package = inputs.niri.packages.${pkgs.system}.default;
  };

  # Niri-specific system packages
  environment.systemPackages = with pkgs; [
    # Niri core packages
    niri
    
    # Niri-specific utilities
    niriswitcher
    xwayland-satellite
  ];

  # XDG Desktop Portal configuration for Niri
  xdg.portal = {
    enable = true;
    config = {
      niri = {
        default = [ "gnome" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "kde" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      xdg-desktop-portal-gtk
    ];
  };
}
