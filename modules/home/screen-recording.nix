{ pkgs, ... }:
let
  screen-record = pkgs.writeShellApplication {
    name = "screen-record";
    runtimeInputs = with pkgs; [
      coreutils
      fuzzel
      gpu-screen-recorder
      libnotify
      slurp
      xdg-user-dirs
    ];
    text = ''
      state_dir="''${XDG_RUNTIME_DIR:-/tmp}/screen-record"
      pid_file="$state_dir/pid"
      mkdir -p "$state_dir"

      geometry_dir="''${XDG_STATE_HOME:-$HOME/.local/state}/screen-record"
      geometry_file="$geometry_dir/last-geometry"
      mkdir -p "$geometry_dir"

      if [[ -f "$pid_file" ]]; then
        recorder_pid="$(<"$pid_file")"
        recorder_exe=""
        if [[ "$recorder_pid" =~ ^[0-9]+$ ]] && [[ -e "/proc/$recorder_pid/exe" ]]; then
          recorder_exe="$(readlink -f "/proc/$recorder_pid/exe")"
        fi

        if [[ "$recorder_exe" == */gpu-screen-recorder ]]; then
          kill -INT "$recorder_pid"
          notify-send \
            --app-name="Gravação de tela" \
            "Finalizando a gravação" \
            "O vídeo está sendo salvo."
          exit 0
        fi

        rm -f "$pid_file"
      fi

      geometry=""
      saved_geometry=""
      if [[ -s "$geometry_file" ]]; then
        saved_geometry="$(<"$geometry_file")"
      fi

      if [[ -n "$saved_geometry" ]]; then
        saved_dims="''${saved_geometry%%+*}"
        region_choice="$(printf '%s\n' \
          "Última seleção ($saved_dims)" \
          'Nova seleção' |
          fuzzel --dmenu --lines=2 --prompt='Região da gravação: ')" || exit 0
        case "$region_choice" in
          "Última seleção ($saved_dims)")
            geometry="$saved_geometry"
            ;;
          'Nova seleção')
            geometry="$(slurp -d -f '%wx%h+%x+%y')" || exit 0
            ;;
          *)
            exit 0
            ;;
        esac
      else
        geometry="$(slurp -d -f '%wx%h+%x+%y')" || exit 0
      fi

      if [[ -z "$geometry" ]]; then
        exit 0
      fi
      printf '%s\n' "$geometry" > "$geometry_file"

      audio_choice="$(printf '%s\n' \
        'Microfone + som do computador' \
        'Som do computador' \
        'Microfone' \
        'Sem áudio' |
        fuzzel --dmenu --lines=4 --prompt='Áudio da gravação: ')" || exit 0

      audio_args=()
      case "$audio_choice" in
        'Microfone + som do computador')
          audio_args=(-a 'default_input|default_output')
          ;;
        'Som do computador')
          audio_args=(-a default_output)
          ;;
        'Microfone')
          audio_args=(-a default_input)
          ;;
        'Sem áudio')
          ;;
        *)
          exit 0
          ;;
      esac

      videos_dir="$(xdg-user-dir VIDEOS 2>/dev/null || true)"
      if [[ -z "$videos_dir" ]]; then
        videos_dir="$HOME/Videos"
      fi
      recordings_dir="$videos_dir/Gravações"
      mkdir -p "$recordings_dir"
      output="$recordings_dir/$(date '+%Y-%m-%d_%H-%M-%S').mp4"

      gpu-screen-recorder \
        -w region \
        -region "$geometry" \
        -f 60 \
        -k h264 \
        -q high \
        -ac aac \
        "''${audio_args[@]}" \
        -o "$output" &
      recorder_pid=$!
      printf '%s\n' "$recorder_pid" > "$pid_file"

      notify-send \
        --app-name="Gravação de tela" \
        "Gravação iniciada" \
        "Aperte Windows + Shift + 5 novamente para salvar."

      set +e
      wait "$recorder_pid"
      recorder_status=$?
      set -e
      rm -f "$pid_file"

      if [[ -s "$output" ]]; then
        notify-send \
          --app-name="Gravação de tela" \
          "Gravação salva" \
          "$output"
      else
        rm -f "$output"
        notify-send \
          --urgency=critical \
          --app-name="Gravação de tela" \
          "Não foi possível gravar a tela" \
          "Verifique as fontes de áudio e tente novamente."
      fi

      exit "$recorder_status"
    '';
  };
in {
  home.packages = [ screen-record ];

  programs.niri.settings.binds."Mod+Shift+5".action.spawn = [
    "${screen-record}/bin/screen-record"
  ];
}
