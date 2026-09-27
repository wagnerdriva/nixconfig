{ config, pkgs, ... }:
let
  screen-record = pkgs.writeShellApplication {
    name = "screen-record";
    runtimeInputs = with pkgs; [
      coreutils
      fuzzel
      gpu-screen-recorder
      jq
      libnotify
      slurp
      xdg-user-dirs
    ] ++ [ config.programs.niri.package ];
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

      saved_geometry=""
      if [[ -s "$geometry_file" ]]; then
        saved_geometry="$(<"$geometry_file")"
      fi

      region_options=('Tela inteira')
      last_region_option=""
      if [[ -n "$saved_geometry" ]]; then
        last_region_option="Última seleção (''${saved_geometry%%+*})"
        region_options+=("$last_region_option")
      fi
      region_options+=('Nova seleção')

      region_choice="$(printf '%s\n' "''${region_options[@]}" |
        fuzzel --dmenu --lines="''${#region_options[@]}" \
          --prompt='Região da gravação: ')" || exit 0

      capture_args=()
      if [[ "$region_choice" == 'Tela inteira' ]]; then
        # Record the monitor that has focus, which is also where the menu
        # opened. niri and gpu-screen-recorder share the DRM connector names.
        output_name="$(niri msg --json focused-output | jq -r '.name // empty')"
        if [[ -z "$output_name" ]]; then
          notify-send \
            --urgency=critical \
            --app-name="Gravação de tela" \
            "Não foi possível gravar a tela" \
            "Nenhum monitor em foco foi encontrado."
          exit 1
        fi
        capture_args=(-w "$output_name")
      elif [[ -n "$last_region_option" && "$region_choice" == "$last_region_option" ]]; then
        capture_args=(-w region -region "$saved_geometry")
      elif [[ "$region_choice" == 'Nova seleção' ]]; then
        geometry="$(slurp -d -f '%wx%h+%x+%y')" || exit 0
        if [[ -z "$geometry" ]]; then
          exit 0
        fi
        printf '%s\n' "$geometry" > "$geometry_file"
        capture_args=(-w region -region "$geometry")
      else
        exit 0
      fi

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

      # On Intel VAAPI the quality preset is a constant QP: "high" is QP 30,
      # which smears small UI text and leaves ghosts of old frames until the
      # next keyframe. "ultra" (QP 22) keeps text crisp; lower QPs barely help.
      gpu-screen-recorder \
        "''${capture_args[@]}" \
        -f 60 \
        -k h264 \
        -q ultra \
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
