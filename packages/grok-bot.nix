{
  appimageTools,
  fetchurl,
  lib,
}:
let
  pname = "grok-bot";
  version = "0.75.8";

  src = fetchurl {
    url = "https://downloads.cursor.com/grokbot/stable/039d88c52f45f8af72fbe7379bc426c171edf62b/linux/x64/Grok_Bot_${version}.AppImage";
    hash = "sha256-OM1gaqpIUIyZazUGjKNMfllvXBGuN3Zg2vokoa3hGGM=";
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
