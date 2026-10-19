{
  lib,
  rustPlatform,
  src,
  fetchNpmDeps,
  cargo-tauri,
  nodejs_24,
  npmHooks,
  cmake,
  cacert,
  pkg-config,
  wrapGAppsHook3,
  alsa-lib,
  glib-networking,
  gtk3,
  libappindicator-gtk3,
  openssl,
  webkitgtk_4_1,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "driva-meetings";
  version = "0.4.1";
  inherit src;

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;
  cargoHash = "sha256-92bQFMEB3ApBRU+Ji//VKOE0c/mtvON9MwmVz7oPucM=";
  cargoBuildFlags = [ "--bin" "mind-meet-desktop" ];
  # Updater tests deliberately allow local HTTP only with debug assertions.
  checkType = "debug";

  npmDeps = fetchNpmDeps {
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    inherit src;
    hash = "sha256-3rqEDjda3U+UJz+WO0s6wkyMNmbBuMsUw+3+wyJnXf8=";
  };

  nativeBuildInputs = [
    cargo-tauri.hook
    nodejs_24
    npmHooks.npmConfigHook
    cmake
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    glib-networking
    gtk3
    libappindicator-gtk3
    openssl
    webkitgtk_4_1
  ];

  # Opus uses CMake inside Cargo rather than a top-level CMake project.
  dontUseCmakeConfigure = true;

  # Reqwest initializes the native TLS verifier even for local HTTP mocks.
  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libappindicator-gtk3 ]}
    )
  '';

  meta = {
    description = "Driva Meetings desktop recorder";
    homepage = "https://github.com/Driva-tecnologia/meetings-desk";
    license = lib.licenses.unfree;
    mainProgram = "mind-meet-desktop";
    platforms = [ "x86_64-linux" ];
  };
})
