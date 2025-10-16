# cosmic-desktop.nix
{ config, lib, ... }:

let
  cfg = config.sessionProfiles.cosmic;
in
{
  config = lib.mkIf cfg.enable {
    services.desktopManager.cosmic.enable = true;
  };
}
