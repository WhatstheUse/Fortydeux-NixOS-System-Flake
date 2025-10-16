{ config, pkgs, ... }:

{ # Plasma.nix

  # Enable KDE Plasma
  services.desktopManager.plasma6.enable = true;
  xdg.portal.extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];

  # Enable Xorg session
  # services.xserver.enable = true;
 
  environment.systemPackages = with pkgs; [
    kdePackages.filelight
  #   xorg.xinit
  ];
}
