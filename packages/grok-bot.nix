{
  appimageTools,
  fetchurl,
  lib,
}:
let
  pname = "grok-bot";
  version = "1.1.0";

  src = fetchurl {
    url = "https://downloads.cursor.com/grokbot/stable/83d46d618ef4c12afa17edd8e3c29d6caf046d17/linux/x64/Grok_Bot_${version}.AppImage";
    hash = "sha256-1w5UaS045tFt3x3Rf7zAeokuzMiQ4KWu38Ow4T5thx0=";
  };

  contents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${contents}/grok-bot.desktop $out/share/applications/grok-bot.desktop
    sed -i "s|^Exec=AppRun|Exec=$out/bin/grok-bot|" $out/share/applications/grok-bot.desktop
    grep -q "^Exec=$out/bin/grok-bot" $out/share/applications/grok-bot.desktop
    install -Dm444 \
      ${contents}/resources/icon.png \
      $out/share/icons/hicolor/1024x1024/apps/grok-bot.png
  '';

  meta = {
    description = "Grok Bot desktop app";
    homepage = "https://x.ai/bot";
    license = lib.licenses.unfree;
    mainProgram = "grok-bot";
    platforms = [ "x86_64-linux" ];
  };
}
