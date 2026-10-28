# msg-relay (servidor-principal): turns new Google Chat and Gmail messages into
# normalized signals in SQLite, in near real time, via Pub/Sub StreamingPull
# (outbound only, no public port). Code lives in ~/Projects/msg-relay (local
# git), state in ~/.local/share/msg-relay, secrets in ~/.config/msg-relay
# (dir 700, files 600, never in the Nix store).
#
# The unit only starts once Wagner has authorized the dedicated OAuth token
# (`node auth.mjs`): ConditionPathExists keeps it inactive until then, so a
# switch before that is a no-op. DRY_RUN=1: it only records signals, no
# dispatch to bots/webhooks. After authorizing: `systemctl --user start msg-relay`.
{ config, pkgs, ... }:
let
  home = config.home.homeDirectory;
in
{
  systemd.user.services.msg-relay = {
    Unit = {
      Description = "msg-relay: GChat + Gmail signals (dry run)";
      After = [ "network-online.target" ];
      ConditionPathExists = [
        "${home}/.config/msg-relay/oauth-token.json"
        "${home}/.config/msg-relay/pubsub-sa.json"
        "${home}/Projects/msg-relay/src/relay.mjs"
      ];
      StartLimitIntervalSec = 600;
      StartLimitBurst = 10;
    };
    Service = {
      ExecStart = "${pkgs.nodejs_22}/bin/node ${home}/Projects/msg-relay/src/relay.mjs";
      WorkingDirectory = "${home}/Projects/msg-relay";
      Environment = [
        "NODE_ENV=production"
        "NODE_NO_WARNINGS=1"
        "DRY_RUN=1"
        "CHANNELS=gchat,gmail"
      ];
      # Optional non-secret overrides (600, outside git/Nix store).
      EnvironmentFile = "-${home}/.config/msg-relay/env";
      UMask = "0077";
      Restart = "always";
      RestartSec = 15;
      # 78 = no token / bad config: don't crash-loop on it.
      RestartPreventExitStatus = 78;
      NoNewPrivileges = true;
      PrivateTmp = true;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
