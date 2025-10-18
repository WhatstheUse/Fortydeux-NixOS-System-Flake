{ config, pkgs, lib, ... }:

let
  cfg = config.sessionProfiles.river;
in
{
  config = lib.mkIf cfg.enable {
    programs.river-classic.enable = true;

    environment.systemPackages = with pkgs; [
      river-classic
      i3bar-river
      i3status-rust
    ];

    sessionProfiles.portal = {
      configFragments = [
        {
          river = {
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
      pkgs.river-classic
    ];
  };
}
