let
  colors = rec {
    name = "Broken Pine";

    background = "#111215";
    surface = "#17181a";
    surfaceVariant = "#232132";
    surfaceActive = "#403e53";
    border = "#423f55";
    borderFocused = "#435255";

    text = "#D7D7FF";
    textAlt = "#e0def4";
    muted = "#8787AF";
    mutedAlt = "#74708d";
    disabled = "#6e6a86";
    placeholder = "#2f2b43";

    red = "#ea6e92";
    green = "#5cc1a3";
    yellow = "#f5c177";
    blue = "#9bced6";
    cyan = "#31738f";
    magenta = "#9d7591";
    purple = "#c4a7e6";
    orange = "#FFAF87";
  };
in
colors // {
  noHash = color: builtins.substring 1 6 color;
  withAlpha = color: alpha: "${builtins.substring 1 6 color}${alpha}";
}

