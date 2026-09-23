{
  fetchurl,
  lib,
  stdenvNoCC,
}:
# Git worktree pool that firstmate uses to give each task an isolated checkout.
# Upstream ships a statically linked Go binary, so it runs on NixOS unpatched.
stdenvNoCC.mkDerivation rec {
  pname = "treehouse";
  version = "2.3.0";

  src = fetchurl {
    url = "https://github.com/kunchenguid/treehouse/releases/download/v${version}/treehouse-v${version}-linux-amd64.tar.gz";
    hash = "sha256-lP0rLCDDWqwd3ClBMXiQrYLJkW9czsusSlDNp4Pu0Q8=";
  };

  sourceRoot = ".";
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 treehouse $out/bin/treehouse
    runHook postInstall
  '';

  meta = {
    description = "Git worktree pool for parallel agents";
    homepage = "https://github.com/kunchenguid/treehouse";
    license = lib.licenses.mit;
    mainProgram = "treehouse";
    platforms = [ "x86_64-linux" ];
  };
}
