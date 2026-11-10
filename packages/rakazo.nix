{
  appimageTools,
  desktop-file-utils,
  fetchurl,
  lib,
}:
let
  pname = "rakazo";
  version = "0.8.0";

  src = fetchurl {
    url = "https://github.com/elie222/rakazo/releases/download/v${version}/Rakazo-${version}.AppImage";
    hash = "sha256-PKuU/wfhsm7UkQVve8hZIQ6c8F8dpaCxFmr0MwjjLl4=";
  };

  contents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${contents}/rakazo.desktop $out/share/applications/rakazo.desktop
    substituteInPlace $out/share/applications/rakazo.desktop \
      --replace-fail "Exec=AppRun" "Exec=$out/bin/rakazo"
    ${desktop-file-utils}/bin/desktop-file-validate $out/share/applications/rakazo.desktop
    install -Dm444 ${contents}/rakazo.png \
      $out/share/icons/hicolor/1024x1024/apps/rakazo.png
  '';

  meta = {
    description = "Rakazo desktop app";
    homepage = "https://github.com/elie222/rakazo";
    license = lib.licenses.asl20;
    mainProgram = "rakazo";
    platforms = [ "x86_64-linux" ];
  };
}
