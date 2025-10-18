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
      # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
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
      ];
    };

    sessionProfiles.sessionPackages = [
      pkgs.hyprland
    ];

    nix.settings = {
      substituters = [ "https://hyprshell.cachix.org" ];
      trusted-public-keys = [ "hyprshell.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
  };
}
