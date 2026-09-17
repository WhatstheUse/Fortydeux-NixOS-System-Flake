{ config, pkgs, lib, inputs, ... }:

let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.shellProfiles.dms;

  # Stylix base16 -> DankMaterialShell Material Design 3 theme.
  #
  # DMS reads a custom theme from a JSON file (settings.currentThemeName = "custom"
  # + settings.customThemeFile). Its schema allows either "dark"/"light" sub-objects
  # or a single flat top-level palette; Stylix hands us exactly one scheme, so we
  # emit the flat form rather than duplicating one palette into both slots the way
  # noctalia.nix has to.
  #
  # base16 has no tonal variants, so the M3 "container" ramp is mapped onto
  # base01..base03 (ascending elevation) and primaryContainer borrows base02.
  # See docs/CUSTOM_THEMES.md in the DankMaterialShell repo for the key list.
  c = config.lib.stylix.colors.withHashtag;

  stylixTheme = {
    name = "Stylix";

    # Primary / accent
    primary = c.base0D;
    primaryText = c.base00;
    primaryContainer = c.base02;
    secondary = c.base0E;
    surfaceTint = c.base0D;

    # Backgrounds and surfaces
    background = c.base00;
    backgroundText = c.base05;
    surface = c.base01;
    surfaceText = c.base05;
    surfaceVariant = c.base02;
    surfaceVariantText = c.base04;
    surfaceContainer = c.base01;
    surfaceContainerHigh = c.base02;
    surfaceContainerHighest = c.base03;

    outline = c.base03;

    # Semantic
    error = c.base08;
    warning = c.base0A;
    info = c.base0D;

    # Algorithm used when DMS drives matugen for GTK/Qt app theming.
    matugen_type = "scheme-tonal-spot";
  };

  themePath = "${config.xdg.configHome}/DankMaterialShell/stylix-theme.json";
in
{
  # The upstream home module must be imported unconditionally - its own config
  # block is already wrapped in mkIf, so importing it with enable = false is inert.
  imports = [
    inputs.dank-material-shell.homeModules.dank-material-shell
  ];

  options.shellProfiles.dms = {
    enable = mkOption {
      type = types.bool;
      default = config.sessionProfiles.miraclewm.enable;
      defaultText = lib.literalExpression "config.sessionProfiles.miraclewm.enable";
      description = ''
        Dank Material Shell (DMS). Defaults to following MiracleWM, which uses DMS
        instead of the Noctalia shell the other compositors run. Set explicitly to
        try DMS under another compositor - note that nothing here launches it; the
        compositor config is responsible for that (MiracleWM does it from
        startup_apps in dotfiles/miracle-wm/config.yaml).
      '';
    };

    themeFromStylix = mkEnableOption "the Stylix-derived DMS theme" // { default = true; };
  };

  config = mkIf cfg.enable {
    programs.dank-material-shell = {
      enable = true;

      # Deliberately NOT using the module's systemd service. It installs into
      # graphical-session.target, which every compositor on this host activates via
      # `uwsm finalize` - DMS would then start alongside Noctalia in Hyprland, Niri,
      # etc. Launching it from MiracleWM's startup_apps keeps it scoped to MiracleWM.
      systemd.enable = false;

      settings = mkIf cfg.themeFromStylix {
        currentThemeName = "custom";
        customThemeFile = themePath;
      };
    };

    # Written to a real path under ~/.config rather than referenced straight out of
    # the store so the active theme stays greppable/inspectable next to DMS's own
    # settings.json.
    xdg.configFile."DankMaterialShell/stylix-theme.json" = mkIf cfg.themeFromStylix {
      source = (pkgs.formats.json { }).generate "dms-stylix-theme.json" stylixTheme;
    };
  };
}
