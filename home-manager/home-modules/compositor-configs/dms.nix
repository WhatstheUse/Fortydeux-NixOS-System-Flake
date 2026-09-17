{ config, pkgs, lib, inputs, ... }:

let
  inherit (lib) mkIf mkOption types;

  cfg = config.shellProfiles.dms;
in
# Dank Material Shell (DMS) - the Quickshell-based bar/shell MiracleWM uses in
# place of Waybar. Every other compositor in this flake uses Noctalia.
#
# THEMING: unlike Noctalia, DMS needs no hand-written Stylix bridge. Stylix ships
# a working dank-material-shell target (stylix/modules/dank-material-shell/hm.nix)
# that is gated on `options.programs ? dank-material-shell`, so it stays inert
# until the upstream DMS home module below is imported. Once imported, and with
# stylix.autoEnable = true (set in ../home-theme.nix), it maps base16 -> Material
# tokens into settings.customThemeFile and also handles fontFamily, popup/dock
# transparency, and the wallpaper paths. Contrast noctalia.nix, where the Stylix
# target guards on a stale option name and silently applies nothing, forcing the
# manual palette in that file. Do not set settings.customThemeFile here - it
# collides with the Stylix target's definition.
#
# To opt out and theme DMS from its own settings UI instead:
#   stylix.targets.dank-material-shell.enable = false;
{
  # Imported unconditionally: the upstream module's own config block is wrapped in
  # mkIf, so importing it with enable = false is inert. Importing it is also what
  # makes the Stylix target above light up.
  imports = [
    inputs.dank-material-shell.homeModules.dank-material-shell
  ];

  options.shellProfiles.dms = {
    enable = mkOption {
      type = types.bool;
      default = config.sessionProfiles.miraclewm.enable;
      defaultText = lib.literalExpression "config.sessionProfiles.miraclewm.enable";
      description = ''
        Dank Material Shell (DMS). Defaults to following MiracleWM. Set explicitly
        to try DMS under another compositor - note that nothing here launches it;
        the compositor config is responsible for that (MiracleWM does it from
        startup_apps in ../dotfiles/miracle-wm/config.yaml).
      '';
    };
  };

  config = mkIf cfg.enable {
    programs.dank-material-shell = {
      enable = true;

      # Deliberately NOT using the module's systemd service. It installs into
      # graphical-session.target, which every compositor on these hosts activates
      # via `uwsm finalize` - DMS would then start alongside Noctalia under
      # Hyprland, Niri, and friends. Launching it from MiracleWM's startup_apps
      # keeps it scoped to the one compositor that wants it.
      systemd.enable = false;
    };
  };
}
