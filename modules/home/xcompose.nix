{ config, ... }:
{
  home.file.".XCompose".text = ''
    include "%L"

    <dead_acute> <C> : "Ç"
    <dead_acute> <c> : "ç"
  '';

  home.sessionVariables.XCOMPOSEFILE = "${config.home.homeDirectory}/.XCompose";
}
