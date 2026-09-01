{ pkgs, ... }:
let
  colors = import ./colors.nix;
  wallpaper = "${../../assets/wallpapers/black-hole.png}";
in {
  programs.niri.settings = {
    outputs = {
      "DP-3" = {
        scale = 1;
        position = { x = 0; y = 0; };
      };
      "DP-1" = {
        scale = 1;
        position = { x = 1920; y = 0; };
      };
      "eDP-1" = {
        scale = 2.25;
        position = { x = 1067; y = 1080; };
      };
    };

    input = {
      power-key-handling.enable = false;
      focus-follows-mouse.enable = false;
      mouse.accel-speed = 0.15;
      touchpad = {
        tap = true;
        dwt = true;
        natural-scroll = false;
      };
      keyboard.xkb = {
        layout = "us";
        variant = "intl";
      };
    };

    layout = {
      gaps = 9;
      center-focused-column = "never";
      background-color = "transparent";
      preset-column-widths = [
        { proportion = 0.5; }
        { proportion = 0.66667; }
        { proportion = 0.8; }
      ];
      default-column-width = { proportion = 0.6; };
      focus-ring = {
        width = 2;
        active.color = "#${colors.withAlpha colors.blue "80"}";
        inactive.color = "#${colors.withAlpha colors.surfaceActive "40"}";
      };
      border.enable = false;
      struts = { left = 18; right = 18; };
    };

    spawn-at-startup = [
      { command = [ "sh" "-c" "awww-daemon & sleep 1 && awww img ${wallpaper} --transition-type fade" ]; }
      { command = [ "sh" "-c" "sleep 1 && waybar" ]; }
      { command = [ "swaync" "--skip-system-css" ]; }
      { command = [ "nm-applet" "--indicator" ]; }
    ];

    layer-rules = [{
      matches = [{ namespace = "^awww-daemon$"; }];
      place-within-backdrop = true;
    }];

    prefer-no-csd = true;
    screenshot-path = "~/Pictures/screenshots/%Y-%m-%d %H-%M-%S.png";

    window-rules = [
      {
        open-focused = true;
        draw-border-with-background = false;
        geometry-corner-radius = {
          top-left = 12.0;
          top-right = 12.0;
          bottom-right = 12.0;
          bottom-left = 12.0;
        };
        clip-to-geometry = true;
      }
      {
        matches = [
          { app-id = "^google-chrome.*$"; }
          { app-id = "^chromium.*$"; }
        ];
        default-column-width = { proportion = 0.7; };
      }
      {
        matches = [{ app-id = "^zed.*$"; }];
        default-column-width = { proportion = 0.75; };
      }
      {
        matches = [
          { app-id = "^Alacritty$"; }
          { app-id = "^org.gnome.Nautilus$"; }
        ];
        default-column-width = { proportion = 0.55; };
      }
      {
        matches = [
          { app-id = "^org.gnome.Calculator$"; }
          { app-id = "^pavucontrol$"; }
          { app-id = "^blueman-manager$"; }
        ];
        open-floating = true;
      }
      {
        matches = [
          { title = "^Picture-in-Picture$"; }
          { title = "^Picture in picture$"; }
        ];
        open-floating = true;
      }
    ];

    animations = {
      workspace-switch.kind.spring = {
        damping-ratio = 1.0;
        stiffness = 1000;
        epsilon = 0.0001;
      };
      horizontal-view-movement.kind.spring = {
        damping-ratio = 0.95;
        stiffness = 1000;
        epsilon = 0.0001;
      };
      window-movement.kind.spring = {
        damping-ratio = 0.95;
        stiffness = 1000;
        epsilon = 0.0001;
      };
      window-resize.kind.spring = {
        damping-ratio = 0.95;
        stiffness = 1000;
        epsilon = 0.0001;
      };
    };

    cursor = {
      size = 24;
      hide-when-typing = true;
      hide-after-inactive-ms = 10000;
    };

    hotkey-overlay.skip-at-startup = true;
    overview.zoom = 0.65;

    binds = {
      "Mod+Shift+Slash".action.show-hotkey-overlay = [];

      "Mod+Return".action.spawn = [ "alacritty" ];
      "Mod+E".action.spawn = [ "nautilus" ];
      "Mod+R".action.spawn = [ "fuzzel" ];
      "Alt+L".action.spawn = [ "hyprlock" ];
      "Mod+N".action.spawn = [ "swaync-client" "-t" "-sw" ];

      "XF86AudioRaiseVolume" = {
        action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" ];
        allow-when-locked = true;
      };
      "XF86AudioLowerVolume" = {
        action.spawn = [ "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-" ];
        allow-when-locked = true;
      };
      "XF86AudioMute" = {
        action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle" ];
        allow-when-locked = true;
      };
      "XF86AudioMicMute" = {
        action.spawn = [ "wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle" ];
        allow-when-locked = true;
      };
      "XF86MonBrightnessUp" = {
        action.spawn = [ "brightnessctl" "set" "10%+" ];
        allow-when-locked = true;
      };
      "XF86MonBrightnessDown" = {
        action.spawn = [ "brightnessctl" "set" "10%-" ];
        allow-when-locked = true;
      };

      "Mod+Q".action.close-window = [];
      "Mod+Left".action.focus-column-left = [];
      "Mod+Down".action.focus-window-down = [];
      "Mod+Up".action.focus-window-up = [];
      "Mod+Right".action.focus-column-right = [];
      "Mod+H".action.focus-column-left = [];
      "Mod+J".action.focus-window-down = [];
      "Mod+K".action.focus-window-up = [];
      "Mod+L".action.focus-column-right = [];

      "Mod+Ctrl+Left".action.move-column-left = [];
      "Mod+Ctrl+Down".action.move-window-down = [];
      "Mod+Ctrl+Up".action.move-window-up = [];
      "Mod+Ctrl+Right".action.move-column-right = [];
      "Mod+Ctrl+H".action.move-column-left = [];
      "Mod+Ctrl+J".action.move-window-down = [];
      "Mod+Ctrl+K".action.move-window-up = [];
      "Mod+Ctrl+L".action.move-column-right = [];

      "Mod+Shift+Left".action.focus-monitor-left = [];
      "Mod+Shift+Down".action.focus-monitor-down = [];
      "Mod+Shift+Up".action.focus-monitor-up = [];
      "Mod+Shift+Right".action.focus-monitor-right = [];
      "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [];
      "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [];
      "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [];
      "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [];

      "Mod+Page_Down".action.focus-workspace-down = [];
      "Mod+Page_Up".action.focus-workspace-up = [];
      "Mod+Shift+Page_Down".action.move-column-to-workspace-down = [];
      "Mod+Shift+Page_Up".action.move-column-to-workspace-up = [];

      "Mod+1".action.focus-workspace = 1;
      "Mod+2".action.focus-workspace = 2;
      "Mod+3".action.focus-workspace = 3;
      "Mod+4".action.focus-workspace = 4;
      "Mod+5".action.focus-workspace = 5;
      "Mod+6".action.focus-workspace = 6;
      "Mod+7".action.focus-workspace = 7;
      "Mod+8".action.focus-workspace = 8;
      "Mod+9".action.focus-workspace = 9;

      "Mod+Shift+1".action.move-column-to-workspace = 1;
      "Mod+Shift+2".action.move-column-to-workspace = 2;
      "Mod+Shift+3".action.move-column-to-workspace = 3;
      "Mod+Shift+4".action.move-column-to-workspace = 4;
      "Mod+Shift+5".action.move-column-to-workspace = 5;
      "Mod+Shift+6".action.move-column-to-workspace = 6;
      "Mod+Shift+7".action.move-column-to-workspace = 7;
      "Mod+Shift+8".action.move-column-to-workspace = 8;
      "Mod+Shift+9".action.move-column-to-workspace = 9;

      "Mod+Comma".action.consume-window-into-column = [];
      "Mod+Period".action.expel-window-from-column = [];
      "Mod+D".action.switch-preset-column-width = [];
      "Mod+Shift+D".action.reset-window-height = [];
      "Mod+F".action.maximize-column = [];
      "Mod+Shift+F".action.fullscreen-window = [];
      "Mod+C".action.center-column = [];
      "Mod+Minus".action.set-column-width = "-10%";
      "Mod+Equal".action.set-column-width = "+10%";
      "Mod+Shift+Minus".action.set-window-height = "-10%";
      "Mod+Shift+Equal".action.set-window-height = "+10%";

      "Print".action.screenshot = [];
      "Ctrl+Print".action.screenshot-screen = [];
      "Alt+Print".action.screenshot-window = [];

      "Mod+Shift+E".action.quit = [];
      "Mod+Shift+P".action.power-off-monitors = [];
    };
  };

  home.packages = [ pkgs.awww ];
}
