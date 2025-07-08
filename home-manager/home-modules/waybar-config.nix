{ config, lib, pkgs, ... }:

{
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "hyprland-session.target";
    };
    
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 35;
        spacing = 4;
        margin-top = 4;
        margin-right = 4;
        margin-left = 4;
        margin-bottom = 0;

        # Choose the order of the modules
        modules-left = ["custom/launcher" "clock" "custom/weather" "hyprland/workspaces" "hyprland/window"];
        # modules-center = [ "custom/media" ];
        modules-right = ["idle_inhibitor" "pulseaudio" "backlight" "network" "cpu" "memory" "temperature" "battery" "battery#bat2" "tray" "custom/power"];

        # Modules configuration
        "hyprland/workspaces" = {
          disable-scroll = false;
          all-outputs = true;
          on-click = "activate";
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
          # format = "{icon}";
          persistent-workspaces = {
            "1" = [];
            "2" = [];
          };
        };

        "keyboard-state" = {
          numlock = true;
          capslock = true;
          format = " {name} {icon}";
          format-icons = {
            locked = "";
            unlocked = "";
          };
        };

        "wlr/mode" = {
          format = "<span style=\"italic\">{}</span>";
        };

        "idle_inhibitor" = {
          format = "{icon}";
          format-icons = {
            activated = " ";
            deactivated = " ";
          };
        };
        
        "tray" = {
          icon-size = 20;
          spacing = 10;
        };

        "clock" = {
          # timezone = "America/New_York";
          format = "{:%R   %m/%d  }";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          on-click = "exec gnome-calendar";
        };

        "cpu" = {
          format = "{usage}%  ";
          tooltip = false;
          on-click = "exec com.github.stsdc.monitor";
        };

        "memory" = {
          format = "{}%  ";
          on-click = "exec com.github.stsdc.monitor";
        };

        "temperature" = {
          # thermal-zone = 2;
          # hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-icons = ["🌡" "" "🌡"];
          on-click = "exec com.github.stsdc.monitor";
        };

        "backlight" = {
          # device = "acpi_video1";
          format = "{percent}% {icon}";
          format-icons = ["" "" "" "" "" "" "" "" ""];
        };

        "battery" = {
          states = {
            # good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% 🗲";
          format-plugged = "{capacity}% 🔌";
          format-alt = "{time} {icon}";
          # format-good = ""; # An empty format will hide the module
          format-full = "";
          format-icons = [" " " " " " " " " "];
        };

        "battery#bat2" = {
          bat = "BAT2";
          states = {
            # good = 95;
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% 🗲";
          format-plugged = "{capacity}% 🔌";
          format-alt = "{time} {icon}";
          # format-good = ""; # An empty format will hide the module
          format-full = "";
          format-icons = [" " " " " " " " " "];
        };

        "network" = {
          # interface = "wlp2*"; # (Optional) To force the use of this interface
          format-wifi = "{signalStrength}%  ";
          format-ethernet = "Connected  ";
          tooltip-format = "{essid} {ifname} via {gwaddr} ";
          format-linked = "{ifname} (No IP) ";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
          on-click-right = "exec nm-connection-editor";
        };

        "pulseaudio" = {
          # scroll-step = 1; # %, can be a float
          format = "{volume}% {icon}";
          format-bluetooth = "{volume}% {icon}";
          format-bluetooth-muted = "{icon} {format_source}";
          format-muted = "{format_source}";
          format-source = "";
          format-source-muted = "";
          format-icons = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [" " " " " "];
          };
          on-click = "pwvucontrol";
        };

        "pulseaudio#microphone" = {
          format = "{format_source}";
          format-source = " {volume}%";
          format-source-muted = " Muted";
          on-click = "pamixer --default-source -t";
          on-scroll-up = "pamixer --default-source -i 5";
          on-scroll-down = "pamixer --default-source -d 5";
          scroll-step = 5;
        };

        "custom/media" = {
          format = "{} {icon} ";
          format-icons = {
            "spotify" = "";
            "default" = "";
          };
          return-type = "json";
          on-click = "spotify && playerctl play-pause";
          on-scroll-up = "playerctl next";
          on-scroll-down = "playerctl previous";
        };

        "custom/launcher" = {
          format = "";
          on-click = "pgrep wofi > /dev/null && pkill wofi || wofi -S drun -GIm -w 3 -W 100% -H 96%";
          on-click-right = "pkill wofi";
        };

        "custom/power" = {
          format = "⏻";
          on-click = "exec wlogout";
          on-click-right = "pkill wlogout";
        };
      };
    };
    
    style = ''
      * {
        border: none;
        border-radius: 0px;
        font-family: Cartograph CF Nerd Font, monospace;
        font-weight: bold;
        font-size: 14px;
        min-height: 0px;
      }

      window#waybar {
        background: rgba(21, 18, 27, 0);
        color: @theme_text_color;
      }

      window#waybar.empty #window {
        background: none;
        border: none;
      }

      tooltip {
        border-radius: 10px;
        border-width: 1px;
        border-style: solid;
        border-color: @borders;
      }

      #workspaces button {
        padding: 5px;
        color: @theme_fg_color;
        margin-right: 5px;
      }

      #workspaces button.active {
        color: @theme_fg_color;
      }

      #workspaces button.focused {
        color: @theme_fg_color;
        background: @theme_selected_bg_color;
        border-radius: 10px;
      }

      #workspaces button.urgent {
        color: @theme_bg_color;
        background: @warning_color;
        border-radius: 10px;
      }

      #workspaces button:hover {
        color: @accent_color;
        background: @theme_bg_color;
        border-radius: 10px;
      }

      #custom-language,
      #custom-updates,
      #custom-caffeine,
      #custom-weather,
      #custom-media,
      #custom-spotify,
      #custom-trayer,
      #custom-power,
      #custom-launcher,
      #idle_inhibitor,
      #cpu,
      #memory,
      #temperature,
      #window,
      #clock,
      #battery,
      #pulseaudio,
      #network,
      #workspaces,
      #tray,
      #backlight {
        background: @theme_bg_color;
        padding: 1px 10px;
        margin: 2px;
        border: 1px solid @borders;
        border-radius: 10px;
      }

      #backlight {
        color: @theme_fg_color;
      }

      #battery {
        color: @success_color;
      }

      #clock {
        color: @theme_fg_color;
      }

      #custom-launcher {
        color: @accent_color;
        font-size: 22px;
        padding: 0px 16px 0px 8px;
      }

      #custom-power {
        color: @accent_color;
        font-size: 18px;
        padding-right: 14px;
      }

      #idle_inhibitor {
        color: @accent_color;
      }

      #network {
        color: @link_color;
      }

      #pulseaudio {
        color: @accent_color;
      }

      #pulseaudio.microphone {
        color: @theme_selected_bg_color;
      }

      #workspaces {
        color: @theme_fg_color;
      }
      
    '';
  };
}
