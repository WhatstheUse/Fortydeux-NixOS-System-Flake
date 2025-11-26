{ config, lib, pkgs, inputs, base16Theme, polarity, ... }:

{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  stylix = {
    enable = true;
    autoEnable = true;
    # image = ../dotfiles/wallpapers/balloon-wp.jpg;
    # image = pkgs.fetchurl {
    #   url = "https://www.pixelstalk.net/wp-content/uploads/2016/05/Epic-Anime-Awesome-Wallpapers.jpg";
    #   sha256 = "enQo3wqhgf0FEPHj2coOCvo7DuZv+x5rL/WIo4qPI50=";
    # };
    polarity = polarity;

    # Smart theme resolution:
    # - If base16Theme is a path (Nix path type or contains "/"): use as-is (local file)
    # - If base16Theme is a string: fetch from base16-schemes (named theme)
    # - If base16Theme is null: use fallback
    # (Home-manager can override this with wallpaper-derived colors)
    base16Scheme =
      if base16Theme != null
      then
        if builtins.isPath base16Theme || lib.hasInfix "/" (toString base16Theme)
        then base16Theme  # Local file path
        else "${pkgs.base16-schemes}/share/themes/${base16Theme}"  # Named theme
      else "${pkgs.base16-schemes}/share/themes/valua.yaml";  # Fallback
    cursor = {
      package = pkgs.phinger-cursors;
      name = "phinger-cursors-light";
      size = 32;
    };
    # targets = {
    # };
  };

  # Fix for Stylix kde6 platformTheme issue
  # Override the invalid "kde6" value with "kde" which is compatible with both Plasma5 and Plasma6
  # qt.platformTheme = lib.mkForce "kde";

  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    gnome-characters
    gnome-icon-theme
    hicolor-icon-theme
    hicolor-icon-theme
    kdePackages.breeze-gtk
    kdePackages.breeze-icons
  ];

  # environment.sessionVariables = lib.mkForce {
  #   QT_QPA_PLATFORMTHEME = "kde";
  # };
}
