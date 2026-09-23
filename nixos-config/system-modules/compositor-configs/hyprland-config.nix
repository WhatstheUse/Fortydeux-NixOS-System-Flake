{ config, pkgs, inputs, lib, ... }:

let
  cfg = config.sessionProfiles.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      package = pkgs.hyprland;
    };

    environment.systemPackages = with pkgs; [
      hyprland
      hyprlock
      hypridle
      iio-hyprland
      wvkbd
    ];

    sessionProfiles.portal = {
      configFragments = [
        {
          hyprland = {
            default = [ "hyprland" "gnome" "gtk" ];
            "org.freedesktop.impl.portal.FileChooser" = [ "gnome" ];
            "org.freedesktop.impl.portal.OpenURI" = [ "gnome" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
          };
        }
      ];
      extraPortals = [
        pkgs.xdg-desktop-portal-hyprland
        # Commented out: when using the Hyprland flake input, its NixOS module
        # adds xdg-desktop-portal-hyprland automatically, causing a file collision.
      ];
    };

    sessionProfiles.sessionPackages = [
      pkgs.hyprland
    ];
  };
}
