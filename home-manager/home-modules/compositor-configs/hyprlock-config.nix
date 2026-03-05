{config, lib, username, ...}:

let
  sessionEnabled = config.sessionProfiles.hyprland.enable or false;
in
lib.mkIf sessionEnabled {
  programs.hyprlock = {
    enable = true;
    settings = lib.mkForce {
      background = {
        monitor = "";
        path = "/home/${username}/.config/wallpapers/sleeping-hammock.webp";
        color = "rgba(25, 20, 20, 1.0)";
        blur_passes = 1;
        blur_size = 7;
        noise = 0.0117;
        contrast = 0.8916;
        brightness = 0.8172;
        vibrancy = 0.1696;
        vibrancy_darkness = 0.0;
      };
      
      input-field = {
        monitor = "";
        size = "300, 60";
        outline_thickness = 3;
        dots_size = 0.33;
        dots_spacing = 0.15;
        dots_center = false;
        dots_rounding = -1;
        outer_color = "rgb(151515)";
        inner_color = "rgb(200, 200, 200)";
        font_color = "rgb(10, 10, 10)";
        fade_on_empty = true;
        fade_timeout = 1000;
        placeholder_text = "<i>Input Password...</i>";
        hide_input = false;
        rounding = -1;
        position = "0, -20";
        halign = "center";
        valign = "center";
      };
      
      label = {
        monitor = "";
        text = ''cmd[update:1000] echo "<span foreground='##ffffff'>$(date)</span>"'';
        color = "rgba(200, 200, 200, 1.0)";
        font_size = 38;
        font_family = "Noto Sans";
        position = "0, 80";
        halign = "center";
        valign = "center";
      };
    };
  };
}
