{ pkgs, lib, inputs, ... }:

let
  # Kirigami QML path for Noctalia (workaround for libplasma override issue)
  # This is needed because libplasma's partial kirigami overrides the full kirigami package
  kirigamiQmlPath = "${lib.getLib pkgs.kdePackages.kirigami}/lib/qt-6/qml";
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Noctalia desktop shell - shared across compositors
  programs.noctalia-shell = {
    enable = true;
    settings = {
      location = {
        name = "Allentown";
      };
      general = {
        radiusRatio = 0.4;   # container radius 40%
        iRadiusRatio = 0.6;  # input radius 60%
      };
      bar.widgets = {
        left = [
          { id = "Launcher"; }
          { id = "Clock"; }
          { id = "SystemMonitor"; }
          { id = "ActiveWindow"; }
        ];
        right = [
          { id = "MediaMini"; }
          { id = "Tray"; }
          { id = "NotificationHistory"; }
          { id = "Battery"; }
          { id = "Volume"; }
          { id = "Brightness"; }
          { id = "ControlCenter"; }
        ];
      };
    };
  };
}
