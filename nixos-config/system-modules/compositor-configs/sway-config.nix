{ config, pkgs, lib, ... }:

let
  cfg = config.sessionProfiles.sway;
in
{
  config = lib.mkIf cfg.enable {
    programs.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        export _JAVA_AWT_WM_NONREPARENTING=1
        export MOZ_ENABLE_WAYLAND=1
        export XDG_DATA_DIRS="${pkgs.adwaita-icon-theme}/share:${pkgs.kdePackages.breeze-icons}/share:${pkgs.hicolor-icon-theme}/share:$XDG_DATA_DIRS"
        # KDE session variables - required for KWallet (used by Signal and other apps)
        export KDE_FULL_SESSION=true
        export KDE_SESSION_VERSION=6
        export QT_QPA_PLATFORMTHEME=kde
        # UWSM: the lines below ran before WAYLAND_DISPLAY was set, corrupting systemd's
        # and D-Bus's activation environment. UWSM handles all of this correctly after
        # the compositor starts. Do not re-enable these when using UWSM.
        # systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP || true
        # dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP || true
        # systemctl --user start --no-block xdg-desktop-portal-kde.service || true
      '';
      package = pkgs.sway;
    };

    environment.systemPackages = with pkgs; [
      sway
      swaybg
      i3status-rust
    ];

    sessionProfiles.portal = {
      configFragments = [
        {
          sway = {
            default = lib.mkForce [ "wlr" "gtk" ];
            "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
            "org.freedesktop.impl.portal.OpenURI" = [ "gtk" ];
            "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
            "org.freedesktop.impl.portal.ScreenCast" = lib.mkForce "wlr";
            "org.freedesktop.impl.portal.Screenshot" = lib.mkForce "wlr";
          };
        }
      ];
      extraPortals = [
        pkgs.xdg-desktop-portal-wlr
      ];
    };

    sessionProfiles.sessionPackages = [
      pkgs.sway
    ];
  };
}
