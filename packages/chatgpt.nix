{ appimageTools, buildFHSEnv, fetchurl, lib, stdenvNoCC, binutils, xz, writeShellScript, codexCli ? null }:
let
  version = "26.901.51231";
  contents = stdenvNoCC.mkDerivation {
    pname = "chatgpt-unpacked";
    inherit version;
    src = fetchurl {
      url = "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";
      hash = "sha256-YlgBiNh8PTqTadq3xztCqKMlGNTfii1brmRm3erFwF4=";
    };
    nativeBuildInputs = [ binutils xz ];
    unpackPhase = ''
      ar x $src
      tar -xf data.tar.xz
    '';
    installPhase = ''
      mkdir -p $out
      cp -r usr/lib usr/share $out/
    '';
  };
in
buildFHSEnv (appimageTools.defaultFhsEnvArgs // {
  pname = "chatgpt";
  inherit version;
  runScript = if codexCli == null then "${contents}/lib/chatgpt/ChatGPT" else
    writeShellScript "chatgpt-launcher" ''
      export CODEX_CLI_PATH=${lib.escapeShellArg "${codexCli}/bin/codex"}
      exec ${contents}/lib/chatgpt/ChatGPT "$@"
    '';
  extraInstallCommands = ''
    mkdir -p $out/share
    cp -r ${contents}/share/applications ${contents}/share/pixmaps $out/share/
    substituteInPlace $out/share/applications/chatgpt.desktop \
      --replace-fail "Exec=chatgpt %U" "Exec=$out/bin/chatgpt %U"
  '';
  meta = {
    description = "Official ChatGPT desktop app with Codex";
    homepage = "https://learn.chatgpt.com/docs/linux/linux-app";
    license = lib.licenses.unfree;
    mainProgram = "chatgpt";
    platforms = [ "x86_64-linux" ];
  };
})
