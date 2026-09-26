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

      # Keep the workspace switcher visible in the top-left bar with both the
      # numeric index and the applications currently open there.
      showWorkspaceSwitcher = true;
      showWorkspaceIndex = true;
      showWorkspaceApps = true;
      maxWorkspaceIcons = 4;
      workspaceActiveAppHighlightEnabled = true;

      # Let the wallpaper show through the bar while keeping its contents
      # fully opaque for readability.
      barConfigs = [{
        id = "default";
        name = "Main Bar";
        enabled = true;
        position = 0;
        screenPreferences = [ "all" ];
        showOnLastDisplay = true;
        leftWidgets = [ "launcherButton" "workspaceSwitcher" "focusedWindow" ];
        centerWidgets = [ "music" "clock" "weather" ];
        rightWidgets = [
          "systemTray"
          "clipboard"
          "cpuUsage"
          "memUsage"
          "notificationButton"
          "battery"
          "controlCenterButton"
        ];
        spacing = 4;
        innerPadding = 4;
        barInsetPadding = -1;
        # Niri insets a tiled window by the 18 px strut plus half of the 9 px
        # gap, putting its edge at 22 px. DMS adds the 4 px spacing below, so
        # 18 px here lands the bar on that same edge.
        barLengthPadding = 18;
        bottomGap = 0;
        attachToScreenEdge = false;
        transparency = 0.78;
        widgetTransparency = 1.0;
        squareCorners = false;
        noBackground = false;
        maximizeWidgetIcons = false;
        maximizeWidgetText = false;
        removeWidgetPadding = false;
        widgetPadding = 8;
        batteryColorMode = "theme";
        gothCornersEnabled = false;
        gothCornerRadiusOverride = false;
        gothCornerRadiusValue = 12;
        borderEnabled = false;
        borderColor = "surfaceText";
        borderOpacity = 1.0;
        borderThickness = 1;
        widgetOutlineEnabled = false;
        widgetOutlineColor = "primary";
        widgetOutlineOpacity = 1.0;
        widgetOutlineThickness = 1;
        fontScale = 1.0;
        iconScale = 1.0;
        autoHide = false;
        autoHideStrict = false;
        autoHideDelay = 250;
        showOnWindowsOpen = false;
        openOnOverview = false;
        visible = true;
        popupGapsAuto = true;
        popupGapsManual = 4;
        maximizeDetection = true;
        useOverlayLayer = false;
        scrollEnabled = true;
        scrollXBehavior = "column";
        scrollYBehavior = "workspace";
        shadowIntensity = 0;
        shadowOpacity = 60;
        shadowColorMode = "default";
        shadowCustomColor = "#000000";
        clickThrough = false;
        hoverPopouts = false;
        hoverPopoutDelay = 150;
      }];
    };
  };

  xdg.configFile."DankMaterialShell/nord.json".text = builtins.toJSON nordTheme;
}
