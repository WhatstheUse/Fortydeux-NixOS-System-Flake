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
        systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP || true
        dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP || true
        systemctl --user start --no-block xdg-desktop-portal-gnome.service || true
        systemctl --user start --no-block xdg-desktop-portal-gtk.service || true
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
            default = lib.mkForce [ "gtk" "wlr" "gnome" ];
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
