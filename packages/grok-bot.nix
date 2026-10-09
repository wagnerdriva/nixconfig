{
  appimageTools,
  fetchurl,
  lib,
}:
let
  pname = "grok-bot";
  version = "0.24.0";

  src = fetchurl {
    url = "https://downloads.cursor.com/grokbot/stable/302d75da596fc8d11ee0446a19b31c33c6676c2c/linux/x64/Grok_Bot_${version}.AppImage";
    hash = "sha256-Y3hh7sHeefZOBlYU4PPfZpC8yUdLrjy62S4d/1q+dhg=";
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
      ${contents}/usr/share/icons/hicolor/1024x1024/apps/grok-bot.png \
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
