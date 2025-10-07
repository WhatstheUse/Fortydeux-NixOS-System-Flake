{ config, pkgs, inputs, lib, ... }: 

{ # window-managers.nix - Optimized compositor configuration

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

  # Hyprland - Primary compositor
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    package = pkgs.hyprland;
    # package = inputs.hyprland.packages.${pkgs.system}.hyprland;
  };

  # Miracle-WM
  # programs.wayland.miracle-wm = {
  #   enable = true;
  # };

  # Sway compositor
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

  # River compositor
  programs.river-classic = {
    enable = true;
  };

  # Wayfire compositor with enhanced icon support
  programs.wayfire = {
    enable = true;
    plugins = with pkgs.wayfirePlugins; [
      wcm
      wf-shell
      wayfire-plugins-extra
    ];
  };
  


  # Niri compositor
  programs.niri = {
    enable = true;
    # package = inputs.niri.packages.${pkgs.system}.default;
  };

  # XDG Desktop Portal
  xdg.portal = {
    enable = true;
    
    # Compositor-specific portal configuration
    config = {
      common = {
        default = [ "gtk" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
        "org.freedesktop.impl.portal.ScreenCast" = [ "hyprland" ];
        "org.freedesktop.impl.portal.Screenshot" = [ "hyprland" ];
      };
      
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "kde" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      
      sway = lib.mkForce {
        default = [ "wlr" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "kde" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      
      river = {
        default = [ "wlr" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "kde" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      
      wayfire = {
        default = [ "wlr" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "kde" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      
      miracle-wm = {
        default = [ "wlr" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "kde" ];
        "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
      };
      
      niri = {
        default = [ "gnome" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
        "org.freedesktop.impl.portal.OpenURI" = [ "kde" ];
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
    
    # Portal packages
    wlr.enable = true;
    extraPortals = with pkgs; [
      # xdg-desktop-portal-hyprland
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
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



  # Hyprshell Cachix cache configuration
  nix.settings = {
    # Add Hyprshell Cachix cache for faster builds
    substituters = [ "https://hyprshell.cachix.org" ];
    trusted-public-keys = [ "hyprshell.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  # System packages optimized for compositor compatibility
  environment.systemPackages = with pkgs; [
    # Core Wayland utilities
    wl-clipboard
    wlr-randr
    wlroots
    xdg-utils
    
    # Portal and integration packages
    xdg-desktop-portal
    # xdg-desktop-portal-hyprland
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
    
    # Application launchers
    wofi
    rofi
    bemenu
    
    # Notifications
    mako
    dunst
    libnotify
    
    # Media and utilities
    grim
    slurp
    swaybg
    swaylock-effects
    swayidle
    brightnessctl
    playerctl
    
    # Audio/Video
    pavucontrol
    # pamixer
    
    # Hyprland specific
    hyprlock
    hypridle
    
    # Terminal and file management
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    xfce.xfce4-terminal
    
    # Network management
    networkmanagerapplet
    
    # System monitoring
    lm_sensors
    
    # Wayfire specific
    wayfire
    wayfirePlugins.wcm
    wayfirePlugins.wf-shell
    wayfirePlugins.wayfire-plugins-extra
    
    # Niri specific
    niriswitcher
    xwayland-satellite
    
    # River specific
    i3bar-river
    i3status-rust
    
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
