{
  buildNpmPackage,
  lib,
  nodejs_22,
}:
# gh-axi, tasks-axi and quota-axi are the npm CLIs firstmate requires before it
# dispatches work. Firstmate installs them with `npm install -g`, which cannot
# write to a Nix profile, so they are pinned here from package-lock.json.
buildNpmPackage {
  pname = "firstmate-axi-tools";
  version = "1.0.0";

  src = ./.;
  nodejs = nodejs_22;
  npmDepsHash = "sha256-qPWaVO59Ymgg+uOW5Xx5OCOCxCHKvwomRMB7CN5ve6c=";

  dontNpmBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin
    cp -r node_modules $out/lib/node_modules
    for tool in gh-axi tasks-axi quota-axi; do
      ln -s $out/lib/node_modules/.bin/$tool $out/bin/$tool
    done

    runHook postInstall
  '';

  meta = {
    description = "AXI command line tools used by firstmate";
    homepage = "https://github.com/kunchenguid/firstmate";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
