{ config, pkgs, ... }:
let
  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = [ pkgs.fuzzel config.programs.niri.package ];
    text = ''
      region_choice="$(printf '%s\n' \
        'Tela inteira' \
        'Seleção' |
        fuzzel --dmenu --lines=2 --prompt='Região do print: ')" || exit 0

      # niri saves the image to screenshot-path and copies it to the
      # clipboard. "Tela inteira" captures the focused monitor, which is also
      # where the menu opened.
      case "$region_choice" in
        'Tela inteira')
          niri msg action screenshot-screen
          ;;
        'Seleção')
          niri msg action screenshot
          ;;
      esac
    '';
  };
in {
  home.packages = [ screenshot ];

  programs.niri.settings.binds."Mod+Shift+4".action.spawn = [
    "${screenshot}/bin/screenshot"
  ];
}
