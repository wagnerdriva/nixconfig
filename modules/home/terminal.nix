{ ... }: {
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
