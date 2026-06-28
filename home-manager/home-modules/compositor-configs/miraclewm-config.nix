{ config, pkgs, lib, ... }:

let
  sessionEnabled = config.sessionProfiles.miraclewm.enable or false;
in
# Gated purely on sessionProfiles.miraclewm.enable, mirroring the Niri "gold
# standard" module. MiracleWM is a Mir-based tiling compositor configured via
# YAML; there is no upstream home-manager module, so the raw dotfiles in
# ../dotfiles/miracle-wm (config.yaml, display.yaml, waybar/) are linked here.
# Keeping them as raw files preserves shareability with non-Nix machines.
lib.mkIf sessionEnabled {
  home.packages = with pkgs; [
    miracle-wm
    waybar
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
