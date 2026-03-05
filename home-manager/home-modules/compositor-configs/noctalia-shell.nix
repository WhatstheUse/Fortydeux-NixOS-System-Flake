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
        useFahrenheit = true;
      };
      general = {
        radiusRatio = 0.4;   # container radius 40%
        iRadiusRatio = 0.6;  # input radius 60%
        lockOnSuspend = true;
        lockScreenBlur = 30;
        lockScreenTint = 0.4;
      };
      idle = {
        enabled = false;  # Idle/lock managed by swayidle + swaylock instead
        lockTimeout = 20;       # 20 min
        screenOffTimeout = 50;  # 25 min
        suspendTimeout = 70;    # 35 min
        fadeDuration = 5;       # 2 min fade before screen off
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
          { id = "Battery"; displayMode = "icon-always"; }
          { id = "Volume"; displayMode = "alwaysShow"; }
          { id = "Brightness"; }
          { id = "ControlCenter"; }
        ];
      };
    };
  };
}
