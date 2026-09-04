{ pkgs, primaryUser, ... }: {
  imports = [
    ./celluloid.nix
    ./clipboard.nix
    ./development.nix
    ./fuzzel.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./kanshi.nix
    ./mpv.nix
    ./niri.nix
    ./query-on.nix
    ./screen-recording.nix
    ./swaync.nix
    ./terminal.nix
    ./udiskie.nix
    ./xcompose.nix
    ./waybar.nix
    ./zed.nix
  ];

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
      (google-chrome.override {
        # Chrome's Wayland text-input-v3 path ignores the custom XCompose
        # sequence that maps dead acute + c to c-cedilla.
        commandLineArgs = "--disable-features=WaylandTextInputV3";
      })
      localsend
      papers
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

}
