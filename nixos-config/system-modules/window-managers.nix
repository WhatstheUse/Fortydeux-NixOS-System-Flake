{ config, pkgs, inputs, lib, ... }: 

{ # window-managers.nix - Common Wayland infrastructure and packages

  # UWSM - Universal Wayland Session Manager
  # Only enable for compositors that work well with UWSM
  programs.uwsm = {
    enable = true;
    waylandCompositors = {
      hyprland = {
        prettyName = "Hyprland";
        comment = "Hyprland compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/Hyprland";
      };
      # Note: Sway and Niri seem to have issues with UWSM, keeping them as direct launches
    };
  };

  # XDG Desktop Portal - Common configuration
  xdg.portal = {
    enable = true;
    
    # Common portal configuration
    config = {
      common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      
      plasma = {
        default = [ "kde" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "kde" ];
        "org.freedesktop.impl.portal.Secret" = [ "kde" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "kde" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "kde" ];
      };
    };
    
    # Portal packages - common to all compositors
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      kdePackages.xdg-desktop-portal-kde
    ];
    xdgOpenUsePortal = true;
  };

  # Environment Variables - Optimized for all compositors
  environment = {
    sessionVariables = {
      # Wayland compatibility
      NIXOS_OZONE_WL = "1";
      
      # Cursor configuration
      XCURSOR_SIZE = "32";
      XCURSOR_THEME = "phinger-cursors-light";
      
      # Qt/KDE configuration
      KDE_SESSION_VERSION = "6";
      KDE_FULL_SESSION = "true";
    };
    
    variables = {
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORMTHEME = "kde";
    };
  };

  # Enable dconf for proper settings management
  programs.dconf.enable = true;

  # System packages - Common Wayland infrastructure and utilities
  environment.systemPackages = with pkgs; [
    # Core Wayland utilities
    wl-clipboard
    wlr-randr
    wlroots
    xdg-utils
    
    # Portal and integration packages
    xdg-desktop-portal
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    kdePackages.xdg-desktop-portal-kde
    gnome-keyring
    
    # Icon and theme support - System-wide installation for all apps
    kdePackages.breeze-icons
    adwaita-icon-theme
    hicolor-icon-theme
    papirus-icon-theme
    gnome-icon-theme
    gdk-pixbuf
    librsvg
    gtk3
    gtk4
    
    # Icon theme tools
    gtk3.dev  # Provides gtk-update-icon-cache
    shared-mime-info  # MIME type support
    
    # Application launchers (common options)
    wofi
    rofi
    bemenu
    
    # Notifications (common options)
    mako
    dunst
    libnotify
    
    # Media and utilities (common across compositors)
    grim
    slurp
    brightnessctl
    playerctl
    
    # Screen locking and idle management (used by multiple compositors)
    swayidle
    swaylock-effects
    
    # Audio/Video
    pavucontrol
    
    # Terminal and file management
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    xfce.xfce4-terminal
    
    # Network management
    networkmanagerapplet
    
    # System monitoring
    lm_sensors
    
    # Additional utilities
    kanshi
    wdisplays
    wlogout
    wlsunset
    yambar
    fastfetch
    
    # Cursor theme
    phinger-cursors
  ];
}
