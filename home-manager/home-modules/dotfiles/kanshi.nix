{ config, pkgs, lib, ... }:

{
  # Kanshi - Dynamic output configuration for Wayland compositors
  # Automatically switches display configurations based on connected outputs
  services.kanshi = {
    enable = true;
    systemdTarget = "graphical-session.target";

    settings = [
      {
        profile.name = "archerfish-dual";
        profile.outputs = [
          {
            criteria = "LG Display 0x0554 0x0D0000A1";
            status = "enable";
            mode = "3240x2160@59.995";
            position = "0,0";
            scale = 2.0;
          }
          {
            criteria = "Sceptre Tech Inc Sceptre F27 0x00000001";
            status = "enable";
            mode = "1920x1080@75.002";
            position = "1620,0";
            scale = 1.0;
          }
        ];
      }
      {
        profile.name = "archerfish-solo";
        profile.outputs = [
          {
            criteria = "LG Display 0x0554 0x0D0000A1";
            status = "enable";
            mode = "3240x2160@59.995";
            position = "0,0";
            scale = 2.0;
          }
        ];
      }
      {
        profile.name = "killifish-dual";
        profile.outputs = [
          {
            criteria = "LG Display 0x0554 0x0D0000A1";
            status = "enable";
            mode = "3240x2160@59.995";
            position = "0,0";
            scale = 2.0;
          }
          {
            criteria = "Sceptre Tech Inc Sceptre F27 0x00000001";
            status = "enable";
            mode = "1920x1080@75.002";
            position = "1620,0";
            scale = 1.0;
          }
        ];
      }
      {
        profile.name = "killifish-solo";
        profile.outputs = [
          {
            criteria = "LG Display 0x0554 0x0D0000A1";
            status = "enable";
            mode = "3240x2160@59.995";
            position = "0,0";
            scale = 2.0;
          }
        ];
      }
      {
        profile.name = "blacktetra-dual";
        profile.outputs = [
          {
            criteria = "LG Electronics LG ULTRAWIDE 308NTTQD5209";
            status = "enable";
            mode = "3440x1440@159.962";
            position = "0,0";
            scale = 1.0;
          }
          {
            criteria = "Ancor Communications Inc ASUS VS228 E8LMQS044730";
            status = "enable";
            mode = "1920x1080@60.000";
            position = "3440,0";
            scale = 1.0;
          }
        ];
      }
      {
        profile.name = "blacktetra-solo";
        profile.outputs = [
          {
            criteria = "LG Electronics LG ULTRAWIDE 308NTTQD5209";
            status = "enable";
            mode = "3440x1440@159.962";
            position = "0,0";
            scale = 1.0;
          }
        ];
      }
      {
        profile.name = "generic-edp";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 2.0;
          }
        ];
      }
    ];
  };
}
