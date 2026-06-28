{ config, pkgs, lib, ... }:

let
  cfg = config.sessionProfiles.labwc;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      labwc
    ];

    # Labwc is wlroots-based, so the wlr portal backend handles screencast and
    # screenshots; GTK provides the file chooser. Mirrors the Sway/MangoWC setup.
    sessionProfiles.portal = {
      configFragments = [
        {
          labwc = {
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
      pkgs.labwc
    ];
  };
}
