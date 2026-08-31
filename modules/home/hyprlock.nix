{ inputs, ... }:
let
  wallpaper = "${inputs.ramos-config}/assets/wallpapers/current_wallpaper.jpg";
in {
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = false;
        grace = 2;
        disable_loading_bar = true;
      };

      background = [{
        monitor = "";
        path = wallpaper;
        blur_passes = 2;
        brightness = 0.5;
        vibrancy = 0.2;
      }];

      input-field = [{
        monitor = "";
        size = "250, 60";
        outline_thickness = 2;
        dots_size = 0.2;
        dots_spacing = 0.35;
        dots_center = true;
        outer_color = "rgba(0, 0, 0, 0)";
        inner_color = "rgba(17, 18, 21, 0.4)";
        font_color = "rgb(215, 215, 255)";
        check_color = "rgb(92, 193, 163)";
        fail_color = "rgb(234, 110, 146)";
        fade_on_empty = false;
        rounding = -1;
        placeholder_text = "Senha...";
        position = "0, -200";
        halign = "center";
        valign = "center";
      }];

      label = [
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +"%A, %d de %B")"'';
          color = "rgba(215, 215, 255, 0.75)";
          font_size = 22;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 300";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +"%H:%M")"'';
          color = "rgba(215, 215, 255, 0.75)";
          font_size = 120;
          font_family = "JetBrainsMono Nerd Font ExtraBold";
          position = "0, 180";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
