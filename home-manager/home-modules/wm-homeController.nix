{ config, pkgs, ... }:

{
  # Common window manager functionality
  # Individual compositor configs are imported in host-specific files

  home.packages = (with pkgs; [
    # kdePackages.yakuake #Drop-down terminal
  ]);
  
  wayland.windowManager = {
    labwc = {
      enable = true;
      menu = [
        {
          menuId = "root-menu";
          label = "";
          icon = "";
          items = [
            {
              label = "BeMenu";
              action = {
                name = "Execute";
                command = "bemenu-run";
              };
            }
            {
              label = "Reconfigure";
              action = {
                name = "Reconfigure";
              };
            }
            {
              label = "Exit";
              action = {
                name = "Exit";
              };
            }
            
          ];
        }
      ];      
    };
  };



  services.stalonetray = {
    enable = true;
    config = {
      icon_size = 100;
    };
  };

  programs.wleave = {
    enable = true;
  }; 

}
