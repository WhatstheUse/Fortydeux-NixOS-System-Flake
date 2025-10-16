{ config, pkgs, lib, ... }:

let
  cfg = config.sessionProfiles.plasma;
in
{
  config = lib.mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;
    
    # Enable Xorg session
    # services.xserver.enable = true;

    environment.systemPackages = with pkgs; [
      kdePackages.filelight
    ];
  };
}
