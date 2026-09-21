{
  autoPatchelfHook,
  fetchurl,
  lib,
  libxcb,
  makeWrapper,
  stdenv,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation rec {
  pname = "pi";
  version = "0.87.0";

  src = fetchurl {
    url = "https://github.com/earendil-works/pi/releases/download/v${version}/pi-linux-x64.tar.gz";
    hash = "sha256-9V0CZSF1zT8i5tuCI8k++XoIc4KrtR3JzhMPwE3o90Y=";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];
  buildInputs = [ libxcb ];

  # `pi` is a Bun single-file executable: its bundle is appended past the last
  # ELF section, and anything that rewrites the file (patchelf, strip) drops it.
  # The X11 addon is a plain shared object, so it is the only thing safe to patch.
  dontAutoPatchelf = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/pi
    cp -r . $out/lib/pi/
    chmod +x $out/lib/pi/pi

    # The executable locates its assets through /proc/self/exe, which resolves
    # to the loader instead. PI_PACKAGE_DIR is upstream's escape hatch for it.
    makeWrapper ${stdenv.cc.bintools.dynamicLinker} $out/bin/pi \
      --add-flags $out/lib/pi/pi \
      --set PI_PACKAGE_DIR $out/lib/pi

    runHook postInstall
  '';

  postFixup = ''
    autoPatchelf $out/lib/pi/native
  '';

  meta = {
    description = "Coding agent for the terminal";
    homepage = "https://github.com/earendil-works/pi";
    license = lib.licenses.mit;
    mainProgram = "pi";
    platforms = [ "x86_64-linux" ];
  };
}
