{
  autoPatchelfHook,
  fetchurl,
  lib,
  stdenv,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "opencode";
  version = "2.0.32";

  # V2 is published under @opencode/cli; the GitHub release marked latest
  # still belongs to V1. Use the same native package as the official installer.
  src = fetchurl {
    url = "https://registry.npmjs.org/@opencode/cli-linux-x64/-/cli-linux-x64-${version}.tgz";
    hash = "sha256-ZKH0s4HC0u/BjI12ss45kUF3i0IbVMmLlL6OgIA2Btw=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];
  dontBuild = true;
  # Preserve Bun's embedded bundle. Patch the executable's loader directly:
  # V2 spawns its server using process.execPath, which cannot be a loader wrapper.
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/opencode $out/bin/opencode
    runHook postInstall
  '';

  meta = {
    description = "OpenCode V2 coding agent for the terminal";
    homepage = "https://opencode.ai/v2/docs";
    license = lib.licenses.mit;
    mainProgram = "opencode";
    platforms = [ "x86_64-linux" ];
  };
}
