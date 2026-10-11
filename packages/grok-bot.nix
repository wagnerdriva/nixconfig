{
  appimageTools,
  fetchurl,
  lib,
}:
let
  pname = "grok-bot";
  version = "0.68.1";

  src = fetchurl {
    url = "https://downloads.cursor.com/grokbot/stable/33103062f95061ccf9c81c5b365d37ab152c3b66/linux/x64/Grok_Bot_${version}.AppImage";
    hash = "sha256-L+fFrOzM1VehM7DGGSmX7AwTIPHp/Hvv/MprXozvuls=";
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
