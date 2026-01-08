{ config, pkgs, inputs, lib, ... }:

let
  cfg = config.sessionProfiles.niri;
in
{
  config = lib.mkIf cfg.enable {
    programs.niri = {
      enable = true;
      # package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };

    environment.systemPackages = with pkgs; [
      niri
      niriswitcher
      xwayland-satellite
    ];

    sessionProfiles.portal = {
      configFragments = [
        {
          niri = {
            default = [ "gnome" "gtk" ];
            "org.freedesktop.impl.portal.FileChooser" = [ "gnome" ];
            "org.freedesktop.impl.portal.OpenURI" = [ "gnome" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
          };
        }
      ];
      extraPortals = [
        pkgs.xdg-desktop-portal-gnome
      ];
    };

    sessionProfiles.sessionPackages = [
      pkgs.niri
    ];
  };
}
