{ config, pkgs, lib, ... }:

let
  cfg = config.sessionProfiles.wayfire;
in
{
  config = lib.mkIf cfg.enable {
    programs.wayfire = {
      enable = true;
      plugins = with pkgs.wayfirePlugins; [
        wcm
        wf-shell
        wayfire-plugins-extra
      ];
    };

    environment.systemPackages = with pkgs; [
      wayfire
      wayfirePlugins.wcm
      wayfirePlugins.wf-shell
      wayfirePlugins.wayfire-plugins-extra
    ];

    sessionProfiles.portal = {
      configFragments = [
        {
          wayfire = {
            default = [ "gtk" "wlr" "gnome" ];
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
      pkgs.wayfire
    ];
  };
}
