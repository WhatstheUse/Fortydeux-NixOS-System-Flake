# cosmic-desktop.nix
{ inputs, config, pkgs, ... }:

{
  # Enables COSMIC desktop
  services.desktopManager.cosmic.enable = true;
}
