{ lib, pkgs, ... }:
let
  drivaProxyUrl = "http://vpn-driva.netbird.driva.io:8317";
  proxyKeyFile = "$HOME/.config/driva/proxy-key";

  codexVersion = "0.153.0";

  codex-package = pkgs.stdenvNoCC.mkDerivation {
    pname = "codex";
    version = codexVersion;
    # `codex-code-mode-host` ships as a separate release asset; code mode fails
    # closed unless it sits next to the `codex` binary.
    srcs = [
      (pkgs.fetchurl {
        url = "https://github.com/openai/codex/releases/download/rust-v${codexVersion}/codex-x86_64-unknown-linux-musl.tar.gz";
        hash = "sha256-NagsFT2DlZ3gnCy4SscLpp0FeIrusI1Klcpo45+GaA4=";
      })
      (pkgs.fetchurl {
        url = "https://github.com/openai/codex/releases/download/rust-v${codexVersion}/codex-code-mode-host-x86_64-unknown-linux-musl.tar.gz";
        hash = "sha256-K4F6SV41pTMz6Us1r57YeeGA+bKP1X7xWs6ahXuobyw=";
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
    exec ${codex-package}/bin/codex \
      -c 'model="gpt-5.6-sol"' \
      -c 'model_provider="driva_proxy"' \
      -c 'model_reasoning_effort="xhigh"' \
      -c 'service_tier="fast"' \
      -c 'check_for_update_on_startup=false' \
      -c 'model_providers.driva_proxy.name="Driva VPN model proxy"' \
      -c 'model_providers.driva_proxy.base_url="${drivaProxyUrl}/v1"' \
      -c 'model_providers.driva_proxy.wire_api="responses"' \
      -c 'model_providers.driva_proxy.auth.command="${driva-proxy-token}/bin/driva-proxy-token"' \
      "$@"
  '';

  codex-openai = pkgs.writeShellScriptBin "codex-openai" ''
    exec ${codex-package}/bin/codex "$@"
  '';
in
{
  home.packages = with pkgs; [
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
