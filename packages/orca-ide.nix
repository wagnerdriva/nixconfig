{
  appimageTools,
  fetchurl,
  lib,
}:
let
  pname = "orca-ide";
  version = "1.4.193";

  src = fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v${version}/orca-linux.AppImage";
    hash = "sha256-P4Fv8i+cM/nEoeUSzIgoXAEu6/bKqujOvr3ft56QCFU=";
  };

  contents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    # Keep the graphical executable separate from Orca's public Linux CLI.
    # The latter is assembled in modules/home/development.nix.
    mv $out/bin/orca-ide $out/bin/orca-ide-app

    install -Dm444 \
      ${contents}/orca-ide.desktop \
      $out/share/applications/orca-ide.desktop

    substituteInPlace $out/share/applications/orca-ide.desktop \
      --replace-fail "Exec=AppRun --no-sandbox %U" "Exec=orca-ide-app --no-sandbox %U"

    for size in 16 24 32 48 64 128 256 512; do
      install -Dm444 \
        ${contents}/usr/share/icons/hicolor/''${size}x''${size}/apps/orca-ide.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/orca-ide.png
    done
  '';

  passthru = { inherit contents; };

  meta = {
    description = "IDE for parallel agentic development";
    homepage = "https://github.com/stablyai/orca";
    license = lib.licenses.unfree;
    mainProgram = "orca-ide-app";
    platforms = [ "x86_64-linux" ];
  };
}
