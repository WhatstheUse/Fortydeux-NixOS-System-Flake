{ config, pkgs, lib, ... }:

let
  cfg = config.sessionProfiles.mangowc;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      mangowc
    ];

    sessionProfiles.portal = {
      configFragments = [
        {
          mangowc = {
            default = [ "wlr" "gtk" ];
            "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
            "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
          };
        }
      ];
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
      ];
    };

    sessionProfiles.sessionPackages = [
      pkgs.mangowc
    ];
  };
}
