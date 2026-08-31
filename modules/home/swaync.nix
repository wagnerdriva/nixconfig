{ ... }:
let
  colors = import ./colors.nix;
in {
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "overlay";
      layer-shell = true;
      fit-to-screen = false;

      notification-window-width = 400;
      notification-icon-size = 56;
      timeout = 6;
      timeout-low = 4;
      timeout-critical = 0;

      control-center-width = 420;
      control-center-height = 800;
      control-center-margin-top = 12;
      control-center-margin-bottom = 12;
      control-center-margin-right = 12;

      widgets = [ "title" "dnd" "notifications" ];
      widget-config = {
        title = {
          text = "Notificações";
          clear-all-button = true;
          button-text = "Limpar";
        };
        dnd.text = "Não perturbe";
      };
    };

    style = ''
      notificationwindow,
      blankwindow,
      .blank-window,
      .floating-notifications {
        background: transparent;
      }

      * {
        font-family: "Noto Sans", "JetBrainsMono Nerd Font";
        font-size: 13px;
      }

      .notification-row {
        outline: none;
        margin: 6px 12px;
        background: transparent;
      }

      .notification {
        border-radius: 8px;
        border: 2px solid alpha(${colors.blue}, 0.5);
        background: ${colors.background};
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.4);
      }

      .notification-content {
        padding: 14px 16px;
        background: ${colors.background};
      }

      .notification.critical { border-color: ${colors.red}; }
      .summary { color: ${colors.text}; font-weight: 700; }
      .time { color: ${colors.muted}; }
      .body { color: ${colors.textAlt}; }

      .close-button,
      .notification-action,
      .widget-title button {
        color: ${colors.text};
        background: ${colors.surfaceVariant};
        border: 1px solid ${colors.border};
        border-radius: 6px;
      }

      .close-button:hover,
      .widget-title button:hover {
        color: ${colors.background};
        background: ${colors.red};
      }

      .control-center {
        color: ${colors.text};
        background: ${colors.background};
        border: 2px solid alpha(${colors.blue}, 0.5);
        border-radius: 8px;
        margin: 8px;
        padding: 12px 0;
      }

      .widget-title { font-size: 16px; font-weight: 700; padding: 8px 16px; }
      .widget-dnd { padding: 6px 16px; margin: 6px 12px; }
      .widget-dnd > switch { background: ${colors.surfaceActive}; }
      .widget-dnd > switch:checked { background: ${colors.blue}; }
    '';
  };
}

