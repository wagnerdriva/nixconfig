{ ... }:
let
  colors = import ./colors.nix;
in {
  programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      margin-top = 6;
      modules-left = [ "clock" "niri/workspaces" ];
      modules-center = [ "niri/window" ];
      modules-right = [
        "custom/memory"
        "tray"
        "network"
        "backlight"
        "pulseaudio"
        "pulseaudio#source"
        "battery"
      ];

      "niri/window" = {
        format = "{}";
        max-length = 80;
      };

      "niri/workspaces" = {
        disable-scroll = true;
        all-outputs = false;
        on-click = "activate";
      };

      "custom/memory" = {
        format = "  {}";
        interval = 3;
        exec = "free -h | awk '/Mem:/{printf $3}'";
        tooltip = false;
      };

      tray = {
        icon-size = 16;
        spacing = 10;
      };

      network = {
        format-wifi = "󰤨  {essid}";
        format-ethernet = "󰈀  Ethernet";
        format-disconnected = "󰤭  Offline";
        tooltip-format-wifi = "Sinal: {signalStrength}%\n{ipaddr}";
      };

      backlight = {
        format = "{icon} {percent}%";
        format-icons = [ "󰃞" "󰃟" "󰃠" ];
        on-scroll-up = "brightnessctl set 1%+";
        on-scroll-down = "brightnessctl set 1%-";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "";
        scroll-step = 1;
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        format-icons.default = [ "" "" "" ];
      };

      "pulseaudio#source" = {
        format = "{format_source}";
        format-source = "󰍬 {volume}%";
        format-source-muted = "";
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰂄 {capacity}%";
        format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
      };

      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%A, %d de %B de %Y}";
        tooltip-format = "<big>{calendar}</big>";
      };
    };

    style = ''
      * {
        font-family: "JetBrainsMono Nerd Font", "Symbols Nerd Font Mono", monospace;
        font-weight: bold;
        font-size: 15px;
        border-radius: 0;
      }

      window#waybar {
        background: rgba(17, 18, 21, 0.78);
        border: 1px solid rgba(215, 215, 255, 0.10);
        border-radius: 10px;
        color: ${colors.text};
      }

      .modules-left { margin-left: 10px; }
      .modules-right { margin-right: 10px; }

      #clock,
      #workspaces,
      #window,
      #custom-memory,
      #tray,
      #network,
      #backlight,
      #pulseaudio,
      #battery {
        color: ${colors.text};
        background: transparent;
        padding: 2px 9px;
        margin: 0;
      }

      #workspaces button {
        all: unset;
        color: ${colors.mutedAlt};
        min-width: 28px;
        min-height: 28px;
      }

      #workspaces button.active { color: ${colors.text}; }
      #workspaces button:hover { color: ${colors.blue}; }
      #window { font-size: 14px; }
      #battery.warning { color: ${colors.yellow}; }
      #battery.critical { color: ${colors.red}; }
    '';
  };
}
