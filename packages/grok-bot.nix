{
  appimageTools,
  fetchurl,
  lib,
}:
let
  pname = "grok-bot";
  version = "0.71.2";

  src = fetchurl {
    url = "https://downloads.cursor.com/grokbot/stable/92808c0ad869b2e3725dbc3b8fa2fcc991687502/linux/x64/Grok_Bot_${version}.AppImage";
    hash = "sha256-a8SI+sg9tWbojxx1BzkBLbceGPS8Z+af6Tz/M0nZH+g=";
  };

  contents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${contents}/grok-bot.desktop $out/share/applications/grok-bot.desktop
    substituteInPlace $out/share/applications/grok-bot.desktop \
      --replace-fail "Exec=AppRun --no-sandbox %U" "Exec=$out/bin/grok-bot --no-sandbox %U"
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
