{ hostName, lib, ... }:
let
  useKitty = builtins.elem hostName [ "ryzen" "zenbook" ];
in {
  programs.kitty = {
    enable = useKitty;
    font = {
      name = "Hack Nerd Font";
      size = 13.0;
    };
    settings = {
      window_padding_width = "10 12";
      background_opacity = 0.96;
      cursor_shape = "beam";
      cursor_blink_interval = 0.5;
      background = "#2e3440";
      foreground = "#d8dee9";
      cursor = "#d8dee9";
      cursor_text_color = "#2e3440";
      selection_background = "#4c566a";
      selection_foreground = "#d8dee9";
      color0 = "#3b4252";
      color1 = "#bf616a";
      color2 = "#a3be8c";
      color3 = "#ebcb8b";
      color4 = "#81a1c1";
      color5 = "#b48ead";
      color6 = "#88c0d0";
      color7 = "#e5e9f0";
      color8 = "#4c566a";
      color9 = "#bf616a";
      color10 = "#a3be8c";
      color11 = "#ebcb8b";
      color12 = "#81a1c1";
      color13 = "#b48ead";
      color14 = "#8fbcbb";
      color15 = "#eceff4";
    };
  };

  home.sessionVariables = lib.mkIf useKitty { TERMINAL = "kitty"; };
  xdg.terminal-exec = lib.mkIf useKitty {
    enable = true;
    settings.default = [ "kitty.desktop" ];
  };

  programs.alacritty = {
    enable = !useKitty;
    settings = {
      window = {
        padding = { x = 12; y = 10; };
        dynamic_padding = true;
        opacity = 0.96;
      };
      font = {
        size = 13.0;
        normal.family = "Hack Nerd Font";
      };
      cursor.style = {
        shape = "Beam";
        blinking = "On";
      };
      colors = {
        primary = {
          background = "#2e3440";
          foreground = "#d8dee9";
        };
        cursor = {
          text = "#2e3440";
          cursor = "#d8dee9";
        };
        selection = {
          text = "#2e3440";
          background = "#4c566a";
        };
        normal = {
          black = "#3b4252";
          red = "#bf616a";
          green = "#a3be8c";
          yellow = "#ebcb8b";
          blue = "#81a1c1";
          magenta = "#b48ead";
          cyan = "#88c0d0";
          white = "#e5e9f0";
        };
        bright = {
          black = "#4c566a";
          red = "#bf616a";
          green = "#a3be8c";
          yellow = "#ebcb8b";
          blue = "#81a1c1";
          magenta = "#b48ead";
          cyan = "#8fbcbb";
          white = "#eceff4";
        };
      };
    };
  };
}
