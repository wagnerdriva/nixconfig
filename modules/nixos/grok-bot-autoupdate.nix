# Daily auto-update of the Grok Bot desktop app (packages/grok-bot.nix).
# The app's built-in updater can't work on NixOS (immutable store), so this
# timer bumps version/commit/hash in the package file and switches the system.
{ config, lib, pkgs, primaryUser, hostName, ... }:
let
  repo = "/home/${primaryUser}/nixos-config";
  pkgFile = "${repo}/packages/grok-bot.nix";
  apiUrl = "https://api2.cursor.sh/updates/api/download/stable/linux-x64/sand";

  # Runs as the primary user: checks the API, edits the package file, builds.
  # Prints the built system path on stdout (last line) when an update was built.
  prepare = pkgs.writeShellApplication {
    name = "grok-bot-update-prepare";
    runtimeInputs = with pkgs; [ coreutils curl jq gnused gnugrep config.nix.package git ];
    text = ''
      mode="''${1:-update}"   # update | check
      file=${lib.escapeShellArg pkgFile}

      current=$(sed -nE 's/^[[:space:]]*version = "([^"]+)";.*/\1/p' "$file" | head -n1)
      [ -n "$current" ] || { echo "could not read current version from $file" >&2; exit 1; }

      json=$(curl -fsS --retry 3 --max-time 60 ${lib.escapeShellArg apiUrl})
      latest=$(jq -er '.version' <<<"$json")
      commit=$(jq -er '.commitSha' <<<"$json")
      url=$(jq -er '.downloadUrl' <<<"$json")

      [[ "$latest" =~ ^[0-9]+(\.[0-9]+)+$ ]] || { echo "bad version from API: $latest" >&2; exit 1; }
      [[ "$commit" =~ ^[0-9a-f]{40}$ ]] || { echo "bad commit from API: $commit" >&2; exit 1; }
      expected="https://downloads.cursor.com/grokbot/stable/$commit/linux/x64/Grok_Bot_$latest.AppImage"
      [ "$url" = "$expected" ] || { echo "unexpected downloadUrl: $url" >&2; exit 1; }

      newest=$(printf '%s\n%s\n' "$current" "$latest" | sort -V | tail -n1)
      if [ "$latest" = "$current" ] || [ "$newest" = "$current" ]; then
        echo "Grok Bot is up to date (installed $current, latest stable $latest)"
        exit 0
      fi
      echo "Grok Bot update available: $current -> $latest (commit $commit)"
      if [ "$mode" = check ]; then exit 0; fi

      b32=$(nix-prefetch-url --type sha256 "$url")
      sri=$(nix hash convert --hash-algo sha256 --to sri "$b32")

      backup=$(mktemp)
      cp -p "$file" "$backup"
      restore() { cp "$backup" "$file"; rm -f "$backup"; echo "restored previous $file" >&2; }
      trap 'restore; exit 1' ERR

      sed -i -E \
        -e "s|^([[:space:]]*version = )\"[^\"]+\";|\1\"$latest\";|" \
        -e "s|(grokbot/stable/)[0-9a-f]{40}/|\1$commit/|" \
        -e "s|^([[:space:]]*hash = )\"sha256-[^\"]+\";|\1\"$sri\";|" \
        "$file"
      grep -qF "version = \"$latest\";" "$file"
      grep -qF "/stable/$commit/" "$file"
      grep -qF "hash = \"$sri\";" "$file"

      out=$(nix build --no-link --print-out-paths \
        ${lib.escapeShellArg "${repo}#nixosConfigurations.${hostName}.config.system.build.toplevel"})
      trap - ERR
      rm -f "$backup"
      echo "built $out"
      echo "$out"
    '';
  };

  updater = pkgs.writeShellApplication {
    name = "grok-bot-autoupdate";
    runtimeInputs = with pkgs; [ coreutils util-linux config.nix.package libnotify ];
    text = ''
      user=${lib.escapeShellArg primaryUser}
      file=${lib.escapeShellArg pkgFile}
      as_user() { runuser -u "$user" -- "$@"; }

      if [ "''${1:-}" = "--check" ]; then
        if [ "$(id -un)" = "$user" ]; then exec ${prepare}/bin/grok-bot-update-prepare check; fi
        exec runuser -u "$user" -- ${prepare}/bin/grok-bot-update-prepare check
      fi
      [ "$(id -u)" = 0 ] || { echo "must run as root (or use --check)" >&2; exit 1; }

      backup=$(as_user mktemp)
      as_user cp -p "$file" "$backup"

      output=$(as_user ${prepare}/bin/grok-bot-update-prepare update) || { as_user rm -f "$backup"; exit 1; }
      printf '%s\n' "$output"
      out=$(printf '%s\n' "$output" | tail -n1)
      if [[ "$out" != /nix/store/* ]]; then as_user rm -f "$backup"; exit 0; fi   # up to date

      echo "activating $out"
      if ! { nix-env -p /nix/var/nix/profiles/system --set "$out" && "$out/bin/switch-to-configuration" switch; }; then
        echo "activation failed; restoring previous package file" >&2
        as_user cp "$backup" "$file"; as_user rm -f "$backup"
        exit 1
      fi
      as_user rm -f "$backup"
      echo "Grok Bot updated; system switched to $out"

      uid=$(id -u "$user")
      if [ -S "/run/user/$uid/bus" ]; then
        runuser -u "$user" -- env DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
          notify-send -a "Grok Bot" "Grok Bot atualizado" "Feche e abra o Grok Bot para usar a nova versão." || true
      fi
    '';
  };
in
{
  environment.systemPackages = [ updater ];

  systemd.services.grok-bot-autoupdate = {
    description = "Update the Grok Bot desktop app package and switch the system";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    restartIfChanged = false;   # never restart itself mid-switch
    unitConfig.X-StopOnRemoval = false;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${updater}/bin/grok-bot-autoupdate";
      TimeoutStartSec = "2h";
    };
  };

  systemd.timers.grok-bot-autoupdate = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "1h";
    };
  };
}
