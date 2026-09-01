{ pkgs, ... }:
let
  clipboard-history = pkgs.writeShellApplication {
    name = "clipboard-history";
    runtimeInputs = with pkgs; [ cliphist fuzzel wl-clipboard ];
    text = ''
      selection="$(cliphist list | fuzzel --dmenu --prompt='Área de transferência: ')"
      [ -n "$selection" ] || exit 0
      printf '%s' "$selection" | cliphist decode | wl-copy
    '';
  };
in {
  home.packages = with pkgs; [ cliphist clipboard-history ];

  programs.niri.settings.binds."Mod+V".action.spawn = [
    "${clipboard-history}/bin/clipboard-history"
  ];

  systemd.user.services = {
    cliphist-text = {
      Unit = {
        Description = "Store text clipboard history";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    cliphist-image = {
      Unit = {
        Description = "Store image clipboard history";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
