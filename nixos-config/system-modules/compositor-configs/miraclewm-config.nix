{ config, pkgs, lib, ... }:

let
  cfg = config.sessionProfiles.miraclewm;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      miracle-wm
    ];

    # MiracleWM is built on Mir, not wlroots, so the wlr screencast/screenshot
    # portal backend does not apply. Use the GTK portal for file chooser/URI and
    # the GNOME (PipeWire) portal for screencast/screenshot, which works generically.
    sessionProfiles.portal = {
      configFragments = [
        {
          "miracle-wm" = {
            default = [ "gtk" ];
            "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
            "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
          };
        }
      ];
      # gtk + gnome portals are already provided by the base portal package set.
    };

    sessionProfiles.sessionPackages = [
      pkgs.miracle-wm
    ];
  };
}
