{ ... }:
let
  colors = import ./colors.nix;
in {
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = { x = 12; y = 10; };
        dynamic_padding = true;
        opacity = 0.96;
      };
      font = {
        size = 13.0;
        normal.family = "JetBrainsMono Nerd Font";
      };
      cursor.style = {
        shape = "Beam";
        blinking = "On";
      };
      colors = {
        primary = {
          background = colors.background;
          foreground = colors.textAlt;
        };
        cursor = {
          text = colors.background;
          cursor = colors.blue;
        };
        selection = {
          text = colors.text;
          background = colors.surfaceActive;
        };
        normal = {
          black = colors.background;
          red = colors.red;
          green = colors.green;
          yellow = colors.yellow;
          blue = colors.blue;
          magenta = colors.magenta;
          cyan = colors.cyan;
          white = colors.textAlt;
        };
      };
    };
  };
}

