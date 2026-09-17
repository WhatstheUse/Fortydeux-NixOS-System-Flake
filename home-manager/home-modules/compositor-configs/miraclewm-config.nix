{ config, pkgs, lib, ... }:

let
  sessionEnabled = config.sessionProfiles.miraclewm.enable or false;
in
# Gated purely on sessionProfiles.miraclewm.enable, mirroring the Niri "gold
# standard" module. MiracleWM is a Mir-based tiling compositor configured via
# YAML; there is no upstream home-manager module, so the raw dotfiles in
# ../dotfiles/miracle-wm (config.yaml, display.yaml, waybar/) are linked here.
# Keeping them as raw files preserves shareability with non-Nix machines.
#
# The bar/shell is Dank Material Shell (DMS), not Waybar - see
# ./dms.nix for the package and Stylix theming, and the startup_apps block in
# ../dotfiles/miracle-wm/config.yaml for the `dms run` launch. Waybar is still
# installed below, unstarted, as a Super+B fallback; its config lives in
# ../dotfiles/miracle-wm/waybar/.
lib.mkIf sessionEnabled {
  home.packages = with pkgs; [
    miracle-wm
    waybar # fallback only - not autostarted; toggled with Super+B
    mako
    fuzzel
    anyrun
    swaybg
    wlsunset
    grim
    slurp
    satty
    wl-clipboard
    brightnessctl
    playerctl
    networkmanagerapplet
  ];

  home.file.".config/miracle-wm" = {
    source = ../dotfiles/miracle-wm;
    recursive = true;
  };
}
