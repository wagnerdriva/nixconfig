{ dms, ... }:
let
  nordTheme = {
    dark = {
      name = "Nord Dark";
      primary = "#88c0d0";
      primaryText = "#2e3440";
      primaryContainer = "#5e81ac";
      secondary = "#8fbcbb";
      surface = "#2e3440";
      surfaceText = "#d8dee9";
      surfaceVariant = "#434c5e";
      surfaceVariantText = "#e5e9f0";
      surfaceTint = "#88c0d0";
      background = "#2e3440";
      backgroundText = "#d8dee9";
      outline = "#4c566a";
      surfaceContainerLowest = "#242933";
      surfaceContainerLow = "#3b4252";
      surfaceContainer = "#434c5e";
      surfaceContainerHigh = "#4c566a";
      surfaceContainerHighest = "#616a7a";
      error = "#bf616a";
      warning = "#ebcb8b";
      info = "#81a1c1";
      success = "#a3be8c";
    };

    light = {
      name = "Nord Light";
      primary = "#5e81ac";
      primaryText = "#eceff4";
      primaryContainer = "#d8dee9";
      secondary = "#81a1c1";
      surface = "#eceff4";
      surfaceText = "#2e3440";
      surfaceVariant = "#d8dee9";
      surfaceVariantText = "#3b4252";
      surfaceTint = "#5e81ac";
      background = "#eceff4";
      backgroundText = "#2e3440";
      outline = "#4c566a";
      surfaceContainerLowest = "#ffffff";
      surfaceContainerLow = "#e5e9f0";
      surfaceContainer = "#d8dee9";
      surfaceContainerHigh = "#cbd2dd";
      surfaceContainerHighest = "#b8c1d1";
      error = "#bf616a";
      warning = "#d08770";
      info = "#5e81ac";
      success = "#a3be8c";
    };
  };
in
{
  imports = [
    dms.homeModules.dank-material-shell
    dms.homeModules.niri
  ];

  programs.dank-material-shell = {
    enable = true;
    systemd.enable = true;
    enableDynamicTheming = false;

    # Keep our existing Niri bindings. The systemd service starts DMS, so a
    # second compositor startup entry is intentionally disabled.
    niri = {
      enableKeybinds = false;
      enableSpawn = false;
    };

    settings = {
      currentThemeName = "custom";
      currentThemeCategory = "custom";
      customThemeFile = "~/.config/DankMaterialShell/nord.json";
    };
  };

  xdg.configFile."DankMaterialShell/nord.json".text = builtins.toJSON nordTheme;
}
