{ pkgs, primaryUser, ... }: {
  imports = [
    ./development.nix
    ./fuzzel.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./niri.nix
    ./swaync.nix
    ./terminal.nix
    ./waybar.nix
    ./zed.nix
  ];

  home = {
    username = primaryUser;
    homeDirectory = "/home/${primaryUser}";
    stateVersion = "26.05";

    packages = with pkgs; [
      celluloid
      eog
      gnupg
      google-chrome
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
