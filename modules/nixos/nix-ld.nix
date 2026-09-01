{ pkgs, ... }: {
  # Enable nix-ld to run dynamically linked executables
  # This is needed for tools like Zed that download their own binaries (e.g., Node.js)
  programs.nix-ld = {
    enable = true;
    # Common libraries that dynamically linked programs might need
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      curl
      glib
      nss
      nspr
      atk
      cups
      dbus
      libdrm
      gtk3
      pango
      cairo
      libx11
      libxcomposite
      libxdamage
      libxext
      libxfixes
      libxrandr
      libxcb
      mesa
      expat
      libxkbcommon
      alsa-lib
      icu
    ];
  };
}
