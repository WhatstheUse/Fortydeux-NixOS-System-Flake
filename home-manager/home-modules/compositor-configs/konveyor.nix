{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.konveyor;
  plasmaEnabled = config.sessionProfiles.plasma.enable or false;
  enabled = cfg.enable && plasmaEnabled;
  konveyor = import ./konveyor-package.nix { inherit pkgs; };
  qtPluginPath = "${konveyor}/lib/qt-6/plugins";
  qmlImportPath = "${konveyor}/lib/qt-6/qml";
  stateMarker = "${config.home.homeDirectory}/.local/state/konveyor-home-manager/plugin-enabled";
  kwriteconfig = "${pkgs.kdePackages.kconfig}/bin/kwriteconfig6";
in
{
  options.programs.konveyor.enable = lib.mkEnableOption "Konveyor's KWin tiling effect";

  config = {
    assertions = [
      {
        assertion = !cfg.enable || plasmaEnabled;
        message = "programs.konveyor.enable requires sessionProfiles.plasma.enable";
      }
    ];

    home.packages = lib.optionals enabled [ konveyor ];

    # KWin and the Konveyor KCM need to discover plugins and QML modules in the
    # immutable Nix store package. environment.d feeds these paths to the user
    # manager and graphical session at login.
    xdg.configFile."environment.d/konveyor.conf" = lib.mkIf enabled {
      text = ''
        QT_PLUGIN_PATH=${qtPluginPath}''${QT_PLUGIN_PATH:+:$QT_PLUGIN_PATH}
        QML_IMPORT_PATH=${qmlImportPath}''${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}
        QML2_IMPORT_PATH=${qmlImportPath}''${QML2_IMPORT_PATH:+:$QML2_IMPORT_PATH}
      '';
    };

    # Leave enablement to KWin's Desktop Effects settings. The marker lets HM
    # remove a stale Konveyor setting when this module is switched off without
    # changing the user's choice during normal switches.
    home.activation.konveyorKWinEffect = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      state=${lib.escapeShellArg stateMarker}
      if ${if enabled then "true" else "false"}; then
        $DRY_RUN_CMD mkdir -p "$(dirname "$state")"
        $DRY_RUN_CMD touch "$state"
      elif [ -e "$state" ]; then
        $DRY_RUN_CMD ${kwriteconfig} --file kwinrc --group Plugins --key konveyor_effectEnabled --delete
        $DRY_RUN_CMD rm -f "$state"
      fi
    '';
  };
}
