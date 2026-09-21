{ config, lib, pkgs, primaryUser, hostName, minimalAgentSetup, hermes, ... }:
let
  drivaProxyUrl = "http://vpn-driva.netbird.driva.io:8317";
  drivaProxyKeyFile = "${config.home.homeDirectory}/.config/driva/proxy-key";
in {
  imports = lib.optionals (!minimalAgentSetup) [
    ./agent-instructions.nix
  ] ++ [
    ./celluloid.nix
    ./clipboard.nix
    ./dank-material-shell.nix
    ./development.nix
    ./kanshi.nix
    ./mpv.nix
    ./niri.nix
    ./query-on.nix
    ./screen-recording.nix
    ./terminal.nix
    ./udiskie.nix
    ./wallpaper.nix
    ./xcompose.nix
    ./zed.nix
  ] ++ lib.optionals (hostName == "ryzen") [
    hermes.homeManagerModules.default
    {
      programs.hermes-agent = {
        enable = true;
        package = hermes.packages.${pkgs.stdenv.hostPlatform.system}.minimal;
      };
      # Enable only Hermes' state/configuration activation. The gateway and
      # backend remain disabled, so no background service is started.
      services.hermes-agent = {
        enable = true;
        settings = {
          model = {
            provider = "custom";
            default = "gpt-5.6-sol";
            base_url = "${drivaProxyUrl}/v1";
            key_env = "DRIVA_PROXY_API_KEY";
          };
          agent.reasoning_effort = "xhigh";
          display.skin = "nord";
          # Keep the CLI focused on the conversation: hide model reasoning,
          # tool progress, interim narration, and post-turn diagnostics.
          display.show_reasoning = false;
          display.focus_view = true;
          display.interim_assistant_messages = false;
          display.show_commentary = false;
          display.turn_summary = false;
        };
      };
    }
  ];

  # Keep the Hermes CLI aligned with the Nord palette used elsewhere on the
  # desktop. The Hermes package loads custom skins from ~/.hermes/skins.
  home.file.".hermes/skins/nord.yaml" = lib.mkIf (hostName == "ryzen") {
    text = ''
      name: nord
      description: Nord palette — arctic blue tones with calm contrast

      colors:
        background: "#2E3440"
        ui_accent: "#88C0D0"
        banner_accent: "#81A1C1"
        banner_title: "#8FBCBB"
        banner_text: "#E5E9F0"
        ui_text: "#D8DEE9"
        banner_dim: "#81A1C1"
        banner_border: "#4C566A"
        ui_border: "#4C566A"
        ui_ok: "#A3BE8C"
        ui_warn: "#EBCB8B"
        ui_error: "#BF616A"
        prompt: "#88C0D0"
        input_rule: "#88C0D0"
        response_border: "#81A1C1"
        status_bar_bg: "#3B4252"
        status_bar_text: "#D8DEE9"
        status_bar_strong: "#88C0D0"
        status_bar_dim: "#81A1C1"
        status_bar_good: "#A3BE8C"
        status_bar_warn: "#EBCB8B"
        status_bar_critical: "#BF616A"
        session_label: "#8FBCBB"
        session_border: "#4C566A"

      branding:
        agent_name: J.A.R.V.I.S.
        prompt_symbol: "❯"
        help_header: "J.A.R.V.I.S. — Commands"

      tool_prefix: "┊"
    '';
  };

  # Hermes reads credentials from its own .env file. Populate just the proxy
  # variable from the machine-local key after the official state setup, so the
  # secret never enters the Nix store or the repository.
  home.activation.hermesDrivaProxy = lib.mkIf (hostName == "ryzen")
    (lib.hm.dag.entryAfter [ "hermesAgentSetup" ] ''
      set -eu
      env_file="${config.home.homeDirectory}/.hermes/.env"
      key_file="${drivaProxyKeyFile}"
      temporary="$(${pkgs.coreutils}/bin/mktemp "${config.home.homeDirectory}/.hermes/.env.XXXXXX")"
      trap 'rm -f "$temporary"' EXIT

      if [ -f "$env_file" ]; then
        ${pkgs.gnused}/bin/sed '/^[[:space:]]*DRIVA_PROXY_API_KEY[[:space:]]*=/d' \
          "$env_file" > "$temporary"
      fi
      if [ -r "$key_file" ]; then
        proxy_key="$(${pkgs.coreutils}/bin/tr -d '\r\n' < "$key_file")"
        if [ -n "$proxy_key" ]; then
          printf 'DRIVA_PROXY_API_KEY=%s\n' "$proxy_key" >> "$temporary"
        fi
      fi

      ${pkgs.coreutils}/bin/chmod 600 "$temporary"
      ${pkgs.coreutils}/bin/mv -f "$temporary" "$env_file"
      trap - EXIT
    '');

  home = {
    username = primaryUser;
    homeDirectory = "/home/${primaryUser}";
    stateVersion = "26.05";

    # Keep login shells independent from installer-generated environment
    # files. Some tools place an optional env script under ~/.local/bin; if
    # that file later disappears, sourcing it from ~/.profile aborts greetd's
    # Niri session before the compositor can start.
    sessionPath = [ "$HOME/.local/bin" ];

    file.".profile" = {
      force = true;
      text = ''
        # Managed by Home Manager. User executables under ~/.local/bin are
        # added to PATH through home.sessionPath.
      '';
    };

    packages = with pkgs; [
      celluloid
      eog
      gnupg
      gws
      (google-chrome.override {
        # Chrome's Wayland text-input-v3 path ignores the custom XCompose
        # sequence that maps dead acute + c to c-cedilla.
        commandLineArgs = "--disable-features=WaylandTextInputV3";
      })
      localsend
      papers
      spotify
      unzip
      zed-editor
    ];

    sessionVariables = {
      EDITOR = "hx";
      BROWSER = "google-chrome-stable";
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "niri";
    };

    pointerCursor = {
      enable = true;
      gtk.enable = true;
      size = 24;
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
  };

  programs.home-manager.enable = true;

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
    '';
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Noto Sans";
      size = 11;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
      icon-theme = "Papirus-Dark";
    };
    "org/gtk/settings/file-chooser".sort-directories-first = true;
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      show-hidden-files = true;
    };
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # The ChatGPT desktop entry claims x-scheme-handler/http and
  # x-scheme-handler/https, so without an explicit default the desktop portal
  # picks it over Chrome and web links stop opening in the browser. Name the
  # browser handlers here so the choice does not depend on lookup order.
  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "google-chrome.desktop" ];
    "application/xhtml+xml" = [ "google-chrome.desktop" ];
    "x-scheme-handler/http" = [ "google-chrome.desktop" ];
    "x-scheme-handler/https" = [ "google-chrome.desktop" ];
    "x-scheme-handler/about" = [ "google-chrome.desktop" ];
    "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
  };

}
