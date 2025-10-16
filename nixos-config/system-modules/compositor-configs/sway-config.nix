{ config, pkgs, inputs, lib, ... }:

{
  # Sway compositor configuration
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    extraSessionCommands = ''
      # Wayland-specific environment variables
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export MOZ_ENABLE_WAYLAND=1
      
      # Icon theme paths for proper icon display
      export XDG_DATA_DIRS="${pkgs.adwaita-icon-theme}/share:${pkgs.kdePackages.breeze-icons}/share:${pkgs.hicolor-icon-theme}/share:$XDG_DATA_DIRS"
    '';
    package = pkgs.sway;
  };

  # Sway-specific system packages
  environment.systemPackages = with pkgs; [
    # Sway core packages
    sway
    swaybg
    
    # Sway-specific utilities
    i3status-rust
  ];

  # XDG Desktop Portal configuration for Sway
  xdg.portal = {
    enable = true;
    config = {
      sway = lib.mkForce {
        default = [ "wlr" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "kde" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
      };
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };
}
