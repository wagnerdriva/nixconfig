{ config, lib, pkgs, ... }:
let
  wallpapers = pkgs.runCommand "wallpapers" { } ''
    mkdir -p $out
    cp ${../../assets/wallpapers/black-hole.png} $out/black-hole.png
    cp ${../../assets/wallpapers/966314.jpg} $out/966314.jpg
    cp ${../../assets/wallpapers/1114362.png} $out/1114362.png
    cp ${../../assets/wallpapers/1123555.png} $out/1123555.png
    cp ${../../assets/wallpapers/1130462.png} $out/1130462.png
    cp ${../../assets/wallpapers/1330829.jpeg} $out/1330829.jpeg
  '';
  defaultWallpaper = "${wallpapers}/1330829.jpeg";
  dmsPackage = config.programs.dank-material-shell.package;
  wallpaper-select = pkgs.writeShellApplication {
    name = "wallpaper-select";
    runtimeInputs = [ dmsPackage ] ++ (with pkgs; [ coreutils fuzzel libnotify ]);
    text = ''
      state_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper"
      current="$state_dir/current"
      mkdir -p "$state_dir"

      set_dms_wallpaper() {
        local wallpaper="$1"
        local attempt=0
        while (( attempt < 40 )); do
          if dms ipc call wallpaper set "$wallpaper" >/dev/null 2>&1; then
            return 0
          fi
          attempt=$((attempt + 1))
          sleep 0.25
        done
        echo "DMS nao respondeu para definir o wallpaper" >&2
        return 1
      }

      if [[ "''${1:-}" == "--restore" ]]; then
        if [[ ! -e "$current" ]]; then
          ln -sfn "${defaultWallpaper}" "$current"
        fi
        set_dms_wallpaper "$(readlink -f "$current")"
        exit 0
      fi

      selection="$(printf '%s\n' \
        'Buraco Negro' \
        'Ilha Solitária' \
        'Ruínas Verdes' \
        'Pátio Noturno' \
        'Três Árvores' \
        'Bosque Carmesim' |
        fuzzel --dmenu --lines=6 --prompt='Wallpaper: ')" || exit 0

      case "$selection" in
        'Buraco Negro') wallpaper="${wallpapers}/black-hole.png" ;;
        'Ilha Solitária') wallpaper="${wallpapers}/966314.jpg" ;;
        'Ruínas Verdes') wallpaper="${wallpapers}/1114362.png" ;;
        'Pátio Noturno') wallpaper="${wallpapers}/1123555.png" ;;
        'Três Árvores') wallpaper="${wallpapers}/1130462.png" ;;
        'Bosque Carmesim') wallpaper="${wallpapers}/1330829.jpeg" ;;
        *) exit 0 ;;
      esac

      ln -sfn "$wallpaper" "$current"
      set_dms_wallpaper "$wallpaper"
      notify-send --app-name="Wallpaper" "Wallpaper atualizado" "$selection"
    '';
  };
in {
  home.packages = [ wallpaper-select ];

  home.activation.initializeWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    state_dir="${config.xdg.stateHome}/wallpaper"
    mkdir -p "$state_dir"
    if [ ! -e "$state_dir/current" ]; then
      ln -sfn "${defaultWallpaper}" "$state_dir/current"
    fi
  '';

  programs.niri.settings = {
    spawn-at-startup = [
      { command = [ "${wallpaper-select}/bin/wallpaper-select" "--restore" ]; }
    ];
    binds."Mod+W".action.spawn = [ "${wallpaper-select}/bin/wallpaper-select" ];
  };
}
