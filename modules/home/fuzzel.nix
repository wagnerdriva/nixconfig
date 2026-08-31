{ ... }:
let
  colors = import ./colors.nix;
in {
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "Inter:size=14:weight=medium";
        icon-theme = "Papirus-Dark";
        icons-enabled = true;
        lines = 8;
        width = 45;
        horizontal-pad = 20;
        vertical-pad = 12;
        inner-pad = 8;
        line-height = 28;
        layer = "overlay";
        prompt = "  ";
        placeholder = "Buscar...";
      };
      border = {
        width = 2;
        radius = 4;
      };
      colors = {
        background = colors.withAlpha colors.background "f2";
        text = colors.withAlpha colors.text "ff";
        prompt = colors.withAlpha colors.blue "ff";
        placeholder = colors.withAlpha colors.placeholder "ff";
        input = colors.withAlpha colors.text "ff";
        match = colors.withAlpha colors.blue "ff";
        selection = colors.withAlpha colors.surfaceActive "ff";
        selection-text = colors.withAlpha colors.textAlt "ff";
        selection-match = colors.withAlpha colors.orange "ff";
        border = colors.withAlpha colors.borderFocused "80";
      };
    };
  };
}

