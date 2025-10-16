{ config, pkgs, inputs, lib, ... }:

{
  # River compositor configuration
  programs.river-classic = {
    enable = true;
  };

  # River-specific system packages
  environment.systemPackages = with pkgs; [
    # River core packages
    river-classic
    
    # River-specific utilities
    i3bar-river
    i3status-rust
  ];

  # XDG Desktop Portal configuration for River
  xdg.portal = {
    enable = true;
    config = {
      river = {
        default = [ "wlr" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "kde" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };
}
