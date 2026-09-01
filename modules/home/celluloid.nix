{ pkgs, ... }: {
  # Celluloid reuses an existing window by default. For Voice Memos this can
  # load the audio into a window hidden in another Niri column, making it look
  # like nothing happened. This hidden desktop entry always creates a window.
  xdg.dataFile."applications/celluloid-new-window.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Celluloid
    GenericName=Reprodutor multimídia
    Comment=Reproduzir áudio em uma nova janela
    Exec=${pkgs.celluloid}/bin/celluloid --new-window %U
    Icon=io.github.celluloid_player.Celluloid
    Terminal=false
    NoDisplay=true
    StartupNotify=true
    Categories=AudioVideo;Player;Audio;Video;
    MimeType=application/x-extension-m4a;audio/m4a;audio/mp4;audio/x-m4a;
  '';

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/x-extension-m4a" = [ "celluloid-new-window.desktop" ];
      "audio/m4a" = [ "celluloid-new-window.desktop" ];
      "audio/mp4" = [ "celluloid-new-window.desktop" ];
      "audio/x-m4a" = [ "celluloid-new-window.desktop" ];
    };
  };

  programs.niri.settings.window-rules = [{
    matches = [{ app-id = "^io\\.github\\.celluloid_player\\.Celluloid$"; }];
    open-floating = true;
    open-focused = true;
  }];
}
