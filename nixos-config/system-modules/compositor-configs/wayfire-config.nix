{ config, pkgs, inputs, lib, ... }:

{
  # Wayfire compositor configuration
  programs.wayfire = {
    enable = true;
    plugins = with pkgs.wayfirePlugins; [
      wcm
      wf-shell
      wayfire-plugins-extra
    ];
  };

  # Wayfire-specific system packages
  environment.systemPackages = with pkgs; [
    # Wayfire core packages
    wayfire
    wayfirePlugins.wcm
    wayfirePlugins.wf-shell
    wayfirePlugins.wayfire-plugins-extra
  ];

  # XDG Desktop Portal configuration for Wayfire
  xdg.portal = {
    enable = true;
    config = {
      wayfire = {
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
