# Persistent headless Herdr server for servidor-principal. Wagner attaches from
# his PC with `herdr --remote wagner@servidor-principal`; remote attach reuses
# this server (default session, socket ~/.config/herdr/herdr.sock) instead of
# spawning another. Agents drive it over SSH with `herdr agent|pane|api`.
{ config, lib, pkgs, herdrPackage, herdrOpencodeAssets, ... }:
let
  # Recreate the `main` workspace with an OpenCode agent when the server starts
  # without one (first boot, or after the saved layout lost its agent).
  bootstrap = pkgs.writeShellScript "herdr-bootstrap" ''
    set -eu
    export PATH=${lib.makeBinPath [ herdrPackage pkgs.jq pkgs.coreutils ]}:/etc/profiles/per-user/${config.home.username}/bin:$PATH
    for _ in $(seq 1 30); do
      herdr workspace list >/dev/null 2>&1 && break
      sleep 1
    done
    if herdr agent list | jq -e '.result.agents[] | select(.name == "opencode")' >/dev/null; then
      exit 0
    fi
    mkdir -p "$HOME/Projects"
    pane=$(herdr workspace create --cwd "$HOME/Projects" --label main --no-focus \
      | jq -r '.result.root_pane.pane_id')
    sleep 2
    herdr agent start opencode --kind opencode --pane "$pane" --timeout 120000 >/dev/null
  '';
in
{
  systemd.user.services.herdr = {
    Unit = {
      Description = "Herdr headless server (default session)";
      After = [ "network-online.target" ];
      # Restarting would kill every pane; pick up new versions manually with
      # `systemctl --user restart herdr` (or `herdr update --handoff`).
      X-RestartIfChanged = false;
    };
    Service = {
      ExecStart = "${herdrPackage}/bin/herdr server";
      ExecStartPost = "-${bootstrap}";
      WorkingDirectory = config.home.homeDirectory;
      Environment = [
        "PATH=/etc/profiles/per-user/${config.home.username}/bin:/run/wrappers/bin:/run/current-system/sw/bin"
        "SHELL=/run/current-system/sw/bin/fish"
        "TERM=xterm-256color"
      ];
      Restart = "on-failure";
      RestartSec = 5;
      KillMode = "mixed";
      TimeoutStartSec = 180;
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Declarative equivalent of `herdr integration install opencode` (v12): the
  # server plugin, the V1 TUI plugin and the V2 TUI plugin directory. The V2
  # registration lives in cli.json (see development.nix); tui.jsonc covers V1.
  xdg.configFile = {
    "opencode/plugins/herdr-agent-state.js".source = "${herdrOpencodeAssets}/herdr-agent-state.js";
    "opencode/herdr-tui-session.js".source = "${herdrOpencodeAssets}/herdr-tui-session.js";
    "opencode/herdr-opencode/tui.js".source = "${herdrOpencodeAssets}/tui.js";
    "opencode/tui.jsonc".text = builtins.toJSON { plugin = [ "./herdr-tui-session.js" ]; };
  };
}
