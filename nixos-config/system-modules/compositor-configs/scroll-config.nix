{ config, pkgs, inputs, lib, ... }:

let
  cfg = config.sessionProfiles.scroll;
in
{
  imports = [
    inputs.scroll-flake.nixosModules.default
  ];

  config = lib.mkIf cfg.enable {
    programs.scroll = {
      enable = true;
      package = inputs.scroll-flake.packages.${pkgs.stdenv.hostPlatform.system}.scroll-stable;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };
      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        export _JAVA_AWT_WM_NONREPARENTING=1
        export MOZ_ENABLE_WAYLAND=1
        export XDG_DATA_DIRS="${pkgs.adwaita-icon-theme}/share:${pkgs.kdePackages.breeze-icons}/share:${pkgs.hicolor-icon-theme}/share:$XDG_DATA_DIRS"
      '';
    };
  };
}
