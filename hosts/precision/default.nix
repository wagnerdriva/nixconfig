{ ... }: {
  imports = [
    ./hardware.nix
    ./disko.nix
    ./nvidia.nix
    ./snapshots.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
  ];

  networking.hostName = "precision";
  system.stateVersion = "26.05";

  boot.loader.timeout = 3;

  # The Precision 5530 is an Intel laptop; keep the integrated GPU as the
  # default and invoke the Quadro explicitly through nvidia-offload.
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
  };
}

