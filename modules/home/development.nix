{ config, lib, pkgs, aiMemoryPackage ? null, herdrPackage, herdrPiExtension, minimalAgentSetup, hostName, ... }:
let
  drivaProxyUrl = "http://vpn-driva.netbird.driva.io:8317";
  proxyKeyFile = "$HOME/.config/driva/proxy-key";

  codexVersion = "0.156.1";
  enablePi = hostName != "ryzen";

  # Fable's unqualified alias routes to an unavailable upstream. On Ryzen,
  # use the same explicit Claude namespace as Pi, also accepted by Responses.
  codexCatalog = if hostName != "ryzen" then ./codex-models.json else
    pkgs.writeText "codex-ryzen-models.json" (builtins.toJSON (
      let catalog = builtins.fromJSON (builtins.readFile ./codex-models.json);
      in catalog // {
        models = map (model:
          if model.slug == "claude-fable-5-1" then
            model // { slug = "claude/claude-fable-5-1"; }
          else model
        ) catalog.models;
      }
    ));

  codex-package = pkgs.stdenvNoCC.mkDerivation {
    pname = "codex";
    version = codexVersion;
    # `codex-code-mode-host` ships as a separate release asset; code mode fails
    # closed unless it sits next to the `codex` binary.
    srcs = [
      (pkgs.fetchurl {
        url = "https://github.com/openai/codex/releases/download/rust-v${codexVersion}/codex-x86_64-unknown-linux-musl.tar.gz";
        hash = "sha256-r/RlOag6/4bjxixZK84sUNlTkfnfKJr68DpQwB0UUz0=";
      })
      (pkgs.fetchurl {
        url = "https://github.com/openai/codex/releases/download/rust-v${codexVersion}/codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz";
        hash = "sha256-qSnaqfagvdwAwMnmQC3xF7ElrNlvnVVPbJnDLH5mxgg=";
      })
    ];
    sourceRoot = ".";
    nativeBuildInputs = [ pkgs.makeWrapper ];
    dontBuild = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 codex-x86_64-unknown-linux-musl $out/bin/codex
      install -Dm755 codex-code-mode-host-x86_64-unknown-linux-musl $out/bin/codex-code-mode-host
      runHook postInstall
    '';
    postFixup = ''
      wrapProgram $out/bin/codex --prefix PATH : ${lib.makeBinPath [ pkgs.ripgrep pkgs.bubblewrap ]}
    '';
    meta = pkgs.codex.meta // {
      changelog = "https://github.com/openai/codex/releases/tag/rust-v${codexVersion}";
    };
  };

  orca-app = pkgs.callPackage ../../packages/orca-ide.nix { };

  # Orca ships a Node-based CLI inside the desktop bundle. Run that entrypoint
  # through the Nix FHS wrapper so it works on NixOS. Bare `orca` remains the
  # GNOME screen reader; the development IDE is always `orca-ide` on Linux.
  orca-ide = pkgs.writeShellScriptBin "orca-ide" ''
    export ELECTRON_RUN_AS_NODE=1
    exec ${orca-app}/bin/orca-ide-app \
      ${orca-app.contents}/resources/app.asar.unpacked/out/cli/index.js \
      "$@"
  '';

  pi-package = pkgs.callPackage ../../packages/pi.nix { };

  # Levels the Driva catalog advertises for a model. Everything else is marked
  # unsupported so pi never offers an effort the proxy would reject.
  piThinkingLevels = supported:
    lib.genAttrs [ "off" "minimal" "low" "medium" "high" "xhigh" "max" ]
      (level: if builtins.elem level supported then level else null);

  mkDrivaModel =
    { id
    , name
    , contextWindow
    , maxTokens ? 128000
    , levels ? [ "low" "medium" "high" "xhigh" "max" ]
    }: {
      inherit id name contextWindow maxTokens;
      reasoning = true;
      input = [ "text" "image" ];
      thinkingLevelMap = piThinkingLevels levels;
    };

  # Context windows mirror codex-models.json: the proxy catalog is what the
  # endpoint actually accepts, and it stays below the larger advertised ceiling.
  drivaResponsesModels = map mkDrivaModel [
    { id = "gpt-6-astra"; name = "GPT 6.0 Astra"; contextWindow = 272000; }
    { id = "gpt-6-sol"; name = "GPT 6.0 Sol"; contextWindow = 272000; }
    { id = "gpt-6-luna"; name = "GPT 6.0 Luna"; contextWindow = 272000; }
    {
      id = "glm-5.3";
      name = "GLM 5.3";
      contextWindow = 272000;
      maxTokens = 131072;
      levels = [ "low" "medium" "high" ];
    }
    {
      id = "glm-5.3-flash";
      name = "GLM 5.3 Flash";
      contextWindow = 272000;
      maxTokens = 131072;
      levels = [ "low" "medium" "high" ];
    }
    {
      id = "kimi-k3";
      name = "Kimi K3";
      contextWindow = 1048576;
      maxTokens = 131072;
      levels = [ "low" "high" "max" ];
    }
  ];

  # The proxy only routes Claude through its `claude/` namespace, serving it as
  # native Anthropic Messages. Same prefix ANTHROPIC_DEFAULT_*_MODEL already uses.
  drivaMessagesModels = map mkDrivaModel [
    { id = "claude/claude-fable-5-1"; name = "Claude Fable 5.1"; contextWindow = 1000000; }
    { id = "claude/claude-opus-5-5"; name = "Claude Opus 5.5"; contextWindow = 1000000; }
    { id = "claude/claude-sonnet-5"; name = "Claude Sonnet 5"; contextWindow = 1000000; }
  ];

  driva-proxy-token = pkgs.writeShellScriptBin "driva-proxy-token" ''
    set -eu

    key_file="''${XDG_CONFIG_HOME:-$HOME/.config}/driva/proxy-key"
    if [ ! -r "$key_file" ]; then
      echo "Driva proxy key not found at $key_file" >&2
      exit 1
    fi

    exec ${pkgs.coreutils}/bin/cat "$key_file"
  '';

  codex-updater = pkgs.writeShellApplication {
    name = "codex-local-update";
    runtimeInputs = with pkgs; [ curl jq coreutils gnutar gzip util-linux ];
    text = builtins.readFile ../../scripts/update-codex;
  };

  codex-driva = pkgs.writeShellScriptBin "codex" ''
    set -eu
    if [ "''${1:-}" = update ]; then
      shift
      exec ${codex-updater}/bin/codex-local-update ${lib.escapeShellArg codexVersion} "$@"
    fi

    codex_binary="${config.home.homeDirectory}/.local/share/codex-cli/current/codex"
    if [ ! -x "$codex_binary" ]; then
      codex_binary="${codex-package}/bin/codex"
    fi
    export PATH="${lib.makeBinPath [ pkgs.ripgrep pkgs.bubblewrap ]}:$PATH"

    DRIVA_PROXY_API_KEY="$(${driva-proxy-token}/bin/driva-proxy-token)"
    export DRIVA_PROXY_API_KEY

    exec "$codex_binary" \
      -c 'model_provider="driva_proxy"' \
      -c 'tui.theme="nord"' \
      -c 'model_catalog_json="${codexCatalog}"' \
      -c 'service_tier="fast"' \
      -c 'check_for_update_on_startup=false' \
      -c 'model_providers.driva_proxy.name="Driva VPN model proxy"' \
      -c 'model_providers.driva_proxy.base_url="${drivaProxyUrl}/v1"' \
      -c 'model_providers.driva_proxy.wire_api="responses"' \
      -c 'model_providers.driva_proxy.env_key="DRIVA_PROXY_API_KEY"' \
      "$@"
  '';

  pi-driva = pkgs.writeShellScriptBin "pi" ''
    set -eu

    # The Nix launcher uses the system loader, so tell Herdr which screen
    # manifest applies before it starts the hidden Pi process.
    export HERDR_AGENT=pi

    # The session exports ANTHROPIC_API_KEY for Claude Code, and pi reads any
    # provider credential it finds, which would list every built-in Anthropic
    # model next to the proxy catalog. Only Driva should be reachable here.
    for name in $(env | sed -n 's/^\([A-Z0-9_]*\(API_KEY\|AUTH_TOKEN\)\)=.*/\1/p'); do
      unset "$name"
    done

    DRIVA_PROXY_API_KEY="$(${driva-proxy-token}/bin/driva-proxy-token)"
    export DRIVA_PROXY_API_KEY

    exec ${pi-package}/bin/pi "$@"
  '';

  codex-openai = pkgs.writeShellScriptBin "codex-openai" ''
    if [ "''${1:-}" = update ]; then
      shift
      exec ${codex-updater}/bin/codex-local-update ${lib.escapeShellArg codexVersion} "$@"
    fi

    codex_binary="${config.home.homeDirectory}/.local/share/codex-cli/current/codex"
    if [ ! -x "$codex_binary" ]; then
      codex_binary="${codex-package}/bin/codex"
    fi
    export PATH="${lib.makeBinPath [ pkgs.ripgrep pkgs.bubblewrap ]}:$PATH"

    exec "$codex_binary" \
      -c 'model_provider="openai"' \
      -c 'tui.theme="nord"' \
      "$@"
  '';

  codexProxySettings = pkgs.writeText "codex-proxy-settings.json" (builtins.toJSON {
    model_provider = "driva_proxy";
    tui.theme = "nord";
    check_for_update_on_startup = false;
    model_providers.driva_proxy = {
      name = "Driva VPN model proxy";
      base_url = "${drivaProxyUrl}/v1";
      wire_api = "responses";
      env_key = "DRIVA_PROXY_API_KEY";
    };
  });
in
{
  # Keep the user-local launcher in sync with Home Manager package updates.
  home.file.".local/bin/codex".source = "${codex-driva}/bin/codex";
  home.file.".local/bin/codex-openai".source = "${codex-openai}/bin/codex-openai";

  # Desktop conversations reload the user config, so CLI overrides alone do not
  # reliably select the provider. Preserve the app's other mutable settings.
  home.activation.codexProxy = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.python3.withPackages (ps: [ ps.tomlkit ])}/bin/python \
      - "${config.home.homeDirectory}/.codex/config.toml" ${codexProxySettings} <<'PY'
    import json, os, pathlib, shutil, sys, tempfile
    import tomlkit

    path = pathlib.Path(sys.argv[1])
    desired = json.loads(pathlib.Path(sys.argv[2]).read_text())
    original = path.read_text() if path.exists() else ""
    document = tomlkit.parse(original)
    for key in ("model_provider", "check_for_update_on_startup"):
        document[key] = desired[key]
    current_model = document.get("model")
    if current_model is None or str(current_model) in (
        "gpt-5.6-sol", "gpt-5.6-terra", "gpt-5.6-luna"
    ):
        document["model"] = "gpt-6-sol"
    providers = document.setdefault("model_providers", tomlkit.table())
    providers["driva_proxy"] = desired["model_providers"]["driva_proxy"]
    tui = document.setdefault("tui", tomlkit.table())
    tui["theme"] = desired["tui"]["theme"]
    updated = tomlkit.dumps(document)
    if updated != original:
        path.parent.mkdir(parents=True, exist_ok=True)
        backup = path.with_name("config.toml.before-managed-proxy")
        if path.exists() and not backup.exists():
            shutil.copy2(path, backup)
        fd, temporary = tempfile.mkstemp(dir=path.parent, prefix=".config-proxy-")
        try:
            with os.fdopen(fd, "w") as output:
                output.write(updated)
            os.replace(temporary, path)
        finally:
            if os.path.exists(temporary):
                os.unlink(temporary)
    PY
  '';

  # pi reads this file every time the model picker opens, so the proxy catalog
  # stays declarative. The key itself is resolved by the wrapper, not stored.
  home.file.".pi/agent/models.json" = lib.mkIf enablePi {
    text = builtins.toJSON {
      providers = {
        driva = {
          baseUrl = "${drivaProxyUrl}/v1";
          api = "openai-responses";
          apiKey = "$DRIVA_PROXY_API_KEY";
          models = drivaResponsesModels;
        };
        driva-claude = {
          baseUrl = drivaProxyUrl;
          api = "anthropic-messages";
          apiKey = "$DRIVA_PROXY_API_KEY";
          models = drivaMessagesModels;
        };
      };
    };
  };

  # Keep Pi's custom Nord theme declarative. Pi hot-reloads the active theme
  # when this file changes.
  home.file.".pi/agent/themes/jarvis-nord.json" = lib.mkIf enablePi {
    source = ./pi-themes/jarvis-nord.json;
  };

  # Preserve Pi settings while keeping the selected theme managed.
  home.activation.piTheme = lib.mkIf enablePi (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.python3}/bin/python - "${config.home.homeDirectory}/.pi/agent/settings.json" <<'PY'
    import json
    import os
    import pathlib
    import shutil
    import sys
    import tempfile

    path = pathlib.Path(sys.argv[1])
    original = path.read_text() if path.exists() else ""
    try:
        document = json.loads(original) if original else {}
    except json.JSONDecodeError:
        document = {}
    if not isinstance(document, dict):
        document = {}
    document["theme"] = "JARVIS Nord"
    updated = json.dumps(document, indent=2, ensure_ascii=False) + "\n"
    if updated != original:
        path.parent.mkdir(parents=True, exist_ok=True)
        backup = path.with_name("settings.json.before-managed-theme")
        if path.exists() and not backup.exists():
            shutil.copy2(path, backup)
        fd, temporary = tempfile.mkstemp(dir=path.parent, prefix=".settings-theme-")
        try:
            with os.fdopen(fd, "w") as output:
                output.write(updated)
            os.replace(temporary, path)
        finally:
            if os.path.exists(temporary):
                os.unlink(temporary)
    PY
  '');

  # Same file `herdr integration install pi` writes; pinning the asset from
  # the herdr flake keeps it declarative and in lockstep with the binary.
  home.file.".pi/agent/extensions/herdr-agent-state.ts" = lib.mkIf enablePi {
    source = herdrPiExtension;
  };

  home.file.".claude/themes/nord.json".text = builtins.toJSON {
    name = "Nord";
    base = "dark";
    overrides = {
      claude = "#88c0d0";
      claudeShimmer = "#8fbcbb";
      inverseText = "#2e3440";
      inactive = "#616e88";
      inactiveShimmer = "#81a1c1";
      subtle = "#4c566a";
      suggestion = "#81a1c1";
      permission = "#ebcb8b";
      permissionShimmer = "#d08770";
      remember = "#b48ead";
      success = "#a3be8c";
      error = "#bf616a";
      warning = "#ebcb8b";
      warningShimmer = "#d08770";
      merged = "#b48ead";
      promptBorder = "#88c0d0";
      promptBorderShimmer = "#8fbcbb";
      planMode = "#81a1c1";
      autoAccept = "#a3be8c";
      bashBorder = "#d08770";
      ide = "#5e81ac";
      fastMode = "#b48ead";
      fastModeShimmer = "#d8dee9";
      effortUltra = "#88c0d0";
      diffAdded = "#3b4f3d";
      diffRemoved = "#4f3b42";
      diffAddedDimmed = "#2f3e31";
      diffRemovedDimmed = "#3f3035";
      diffAddedWord = "#a3be8c";
      diffRemovedWord = "#bf616a";
      userMessageBackground = "#3b4252";
      userMessageBackgroundHover = "#434c5e";
      bashMessageBackgroundColor = "#2e3440";
      memoryBackgroundColor = "#3b4252";
      selectionBg = "#4c566a";
      rate_limit_fill = "#88c0d0";
      rate_limit_empty = "#4c566a";
      briefLabelYou = "#8fbcbb";
      briefLabelClaude = "#88c0d0";
    };
  };

  # Claude Code is updated outside Nix, so merge the theme preference into its
  # mutable settings file without replacing any API, permission, or hook data.
  home.activation.claudeTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.python3}/bin/python - "${config.home.homeDirectory}/.claude/settings.json" <<'PY'
    import json, os, pathlib, shutil, tempfile, sys

    path = pathlib.Path(sys.argv[1])
    original = path.read_text() if path.exists() else ""
    try:
        document = json.loads(original) if original else {}
    except json.JSONDecodeError:
        document = {}
    if not isinstance(document, dict):
        document = {}
    environment = document.get("env")
    if isinstance(environment, dict):
        # The effort level is selected by Claude's per-model settings. Keeping
        # this legacy environment override makes it win over the current
        # session and produces a misleading startup warning.
        environment.pop("CLAUDE_CODE_EFFORT_LEVEL", None)
    document["theme"] = "custom:nord"
    updated = json.dumps(document, indent=2, ensure_ascii=False) + "\n"
    if updated != original:
        path.parent.mkdir(parents=True, exist_ok=True)
        backup = path.with_name("settings.json.before-managed-theme")
        if path.exists() and not backup.exists():
            shutil.copy2(path, backup)
        fd, temporary = tempfile.mkstemp(dir=path.parent, prefix=".settings-theme-")
        try:
            with os.fdopen(fd, "w") as output:
                output.write(updated)
            os.replace(temporary, path)
        finally:
            if os.path.exists(temporary):
                os.unlink(temporary)
    PY
  '';

  systemd.user.services.ai-memory = lib.mkIf (!minimalAgentSetup) {
    Unit.Description = "Local shared memory for coding agents";
    Service = {
      ExecStart = "${aiMemoryPackage}/bin/ai-memory serve --transport http --bind 127.0.0.1:49374 --enable-web";
      Environment = [
        "AI_MEMORY_DATA_DIR=${config.xdg.dataHome}/ai-memory"
        "PATH=${lib.makeBinPath [ pkgs.git pkgs.coreutils ]}"
      ];
      Restart = "on-failure";
      RestartSec = 5;
      UMask = "0077";
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Refresh native hook commands when the pinned package changes. The upstream
  # installer merges with existing Codex/Orca hooks and backs up edited files.
  home.activation.aiMemory = lib.mkIf (!minimalAgentSetup)
    (lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "${config.xdg.dataHome}/ai-memory/config.toml" ]; then
      run ${aiMemoryPackage}/bin/ai-memory --data-dir "${config.xdg.dataHome}/ai-memory" init
    fi
    run ${aiMemoryPackage}/bin/ai-memory install-mcp --client codex --apply
    # The installer preserves read-only Nix store permissions when copying hooks.
    # Make its local copies writable before a repeated install overwrites them.
    if [ -d "${config.xdg.dataHome}/ai-memory/hooks" ]; then
      run ${pkgs.findutils}/bin/find "${config.xdg.dataHome}/ai-memory/hooks" \
        -type f -user "${config.home.username}" \
        -exec ${pkgs.coreutils}/bin/chmod u+w {} +
    fi
    run ${aiMemoryPackage}/bin/ai-memory install-hooks --agent codex \
      --hooks-dir ${aiMemoryPackage}/share/ai-memory/hooks \
      --server-url http://127.0.0.1:49374 --project-strategy repo-root --apply
  '');

  home.packages = with pkgs; [
    claude-code
    codex-driva
    codex-openai
    driva-proxy-token

    # Both hosts track this repository, so both need the git credential helper.
    gh

    herdrPackage

    # firstmate (~/firstmate) refuses to dispatch without these. Its own
    # installers use brew, npm -g and curl | sh, none of which fit NixOS.
    # tmux, no-mistakes, chrome-devtools-axi and lavish-axi are left out.
    (callPackage ../../packages/axi-tools { })
    (callPackage ../../packages/treehouse.nix { })
    jq
    nodejs_22
  ] ++ lib.optional enablePi pi-driva ++ lib.optionals (!minimalAgentSetup) [
    (callPackage ../../packages/chatgpt.nix { codexCli = codex-driva; })
    aiMemoryPackage
    btop
    orca-app
    orca-ide

    # Base useful for local development and agent tools.
    pnpm
    python3
    gcc
    gnumake
    pkg-config
    git-lfs
    google-cloud-sdk
    ripgrep
    fd
  ];

  home.sessionVariables = {
    ANTHROPIC_BASE_URL = drivaProxyUrl;
  } // lib.optionalAttrs (!minimalAgentSetup) {
    ANTHROPIC_DEFAULT_OPUS_MODEL = "claude/claude-opus-5-5";
    ANTHROPIC_DEFAULT_SONNET_MODEL = "claude/claude-sonnet-5";
    ANTHROPIC_DEFAULT_HAIKU_MODEL = "claude/claude-haiku-4-5-20251001";
    ANTHROPIC_DEFAULT_FABLE_MODEL = "claude/claude-fable-5-1";
    CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING = "1";
    CLAUDE_CODE_DISABLE_AUTO_MEMORY = "1";
    ORCA_CLI_COMMAND = "orca-ide";
  };

  programs.direnv = lib.mkIf (!minimalAgentSetup) {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fish = {
    shellAliases = lib.optionalAttrs (!minimalAgentSetup) {
      # The official updater keeps the current Claude Code binary here. The
      # Nix package can lag behind new model aliases (including Fable 5.1).
      # Drop stale values inherited by an already-running graphical session.
      claude = "env -u CLAUDE_CODE_EFFORT_LEVEL /home/wagner/.local/bin/claude";
      zed = "zeditor";
      claude-max = "env ANTHROPIC_MODEL=claude/opus claude";
      claude-codex = "env ANTHROPIC_MODEL=codex/opus claude";
      claude-glm = "env ANTHROPIC_MODEL=glm/opus claude";
    };

    interactiveShellInit = lib.mkAfter ''
      # Clear a value inherited by the graphical session before launching
      # Claude from an interactive shell.
      set -e CLAUDE_CODE_EFFORT_LEVEL

      # The key is copied privately to this machine and never enters Git or
      # the Nix store. Both Claude Code and Codex use the same proxy account.
      if test -r "${proxyKeyFile}"
        set -gx ANTHROPIC_API_KEY (string trim < "${proxyKeyFile}")
      end
    '';
  };
}
