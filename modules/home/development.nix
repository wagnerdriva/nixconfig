{ config, lib, pkgs, aiMemoryPackage, ... }:
let
  drivaProxyUrl = "http://vpn-driva.netbird.driva.io:8317";
  proxyKeyFile = "$HOME/.config/driva/proxy-key";

  codexVersion = "0.153.4";

  codex-package = pkgs.stdenvNoCC.mkDerivation {
    pname = "codex";
    version = codexVersion;
    # `codex-code-mode-host` ships as a separate release asset; code mode fails
    # closed unless it sits next to the `codex` binary.
    srcs = [
      (pkgs.fetchurl {
        url = "https://github.com/openai/codex/releases/download/rust-v${codexVersion}/codex-x86_64-unknown-linux-musl.tar.gz";
        hash = "sha256-9HlCTsoJJITcQNh64oxE9MxAI0pgBF1hMeSTgA2BSjA=";
      })
      (pkgs.fetchurl {
        url = "https://github.com/openai/codex/releases/download/rust-v${codexVersion}/codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz";
        hash = "sha256-+VgwqGlZCVdmS7/Ge8ywh3OAa2k2cLrxWQgXb4m0zTE=";
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

  driva-proxy-token = pkgs.writeShellScriptBin "driva-proxy-token" ''
    set -eu

    key_file="''${XDG_CONFIG_HOME:-$HOME/.config}/driva/proxy-key"
    if [ ! -r "$key_file" ]; then
      echo "Driva proxy key not found at $key_file" >&2
      exit 1
    fi

    exec ${pkgs.coreutils}/bin/cat "$key_file"
  '';

  codex-driva = pkgs.writeShellScriptBin "codex" ''
    set -eu
    DRIVA_PROXY_API_KEY="$(${driva-proxy-token}/bin/driva-proxy-token)"
    export DRIVA_PROXY_API_KEY

    exec ${codex-package}/bin/codex \
      -c 'model_provider="driva_proxy"' \
      -c 'model_catalog_json="${./codex-models.json}"' \
      -c 'service_tier="fast"' \
      -c 'check_for_update_on_startup=false' \
      -c 'model_providers.driva_proxy.name="Driva VPN model proxy"' \
      -c 'model_providers.driva_proxy.base_url="${drivaProxyUrl}/v1"' \
      -c 'model_providers.driva_proxy.wire_api="responses"' \
      -c 'model_providers.driva_proxy.env_key="DRIVA_PROXY_API_KEY"' \
      "$@"
  '';

  codex-openai = pkgs.writeShellScriptBin "codex-openai" ''
    exec ${codex-package}/bin/codex "$@"
  '';
in
{
  # Keep the user-local launcher in sync with Home Manager package updates.
  home.file.".local/bin/codex".source = "${codex-driva}/bin/codex";

  systemd.user.services.ai-memory = {
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
  home.activation.aiMemory = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
  '';

  home.packages = with pkgs; [
    (callPackage ../../packages/chatgpt.nix { codexCli = codex-driva; })
    aiMemoryPackage
    btop
    claude-code
    codex-driva
    codex-openai
    driva-proxy-token
    orca-app
    orca-ide

    # Base useful for local development and agent tools.
    nodejs_22
    pnpm
    python3
    gcc
    gnumake
    pkg-config
    git-lfs
    gh
    jq
    ripgrep
    fd
  ];

  home.sessionVariables = {
    ANTHROPIC_BASE_URL = drivaProxyUrl;
    ANTHROPIC_DEFAULT_OPUS_MODEL = "claude/claude-opus-5";
    ANTHROPIC_DEFAULT_SONNET_MODEL = "claude/claude-sonnet-5";
    ANTHROPIC_DEFAULT_HAIKU_MODEL = "claude/claude-haiku-4-5-20251001";
    ANTHROPIC_DEFAULT_FABLE_MODEL = "claude/claude-fable-5-1";
    CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING = "1";
    CLAUDE_CODE_DISABLE_AUTO_MEMORY = "1";
    CLAUDE_CODE_EFFORT_LEVEL = "max";
    ORCA_CLI_COMMAND = "orca-ide";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fish = {
    shellAliases = {
      # The official updater keeps the current Claude Code binary here. The
      # Nix package can lag behind new model aliases (including Fable 5.1).
      claude = "/home/wagner/.local/bin/claude";
      zed = "zeditor";
      claude-max = "env ANTHROPIC_MODEL=claude/opus claude";
      claude-codex = "env ANTHROPIC_MODEL=codex/opus claude";
      claude-glm = "env ANTHROPIC_MODEL=glm/opus claude";
    };

    interactiveShellInit = lib.mkAfter ''
      # The key is copied privately to this machine and never enters Git or
      # the Nix store. Both Claude Code and Codex use the same proxy account.
      if test -r "${proxyKeyFile}"
        set -gx ANTHROPIC_API_KEY (string trim < "${proxyKeyFile}")
      end
    '';
  };
}
