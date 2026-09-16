{ ... }: {
  imports = [
    ./hardware.nix
    ./disko.nix
    ./nvidia.nix
    ../../modules/nixos/snapshots.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/netbird.nix
    ../../modules/nixos/nix-ld.nix
    ../../modules/nixos/zerotier.nix
  ];

  networking.hostName = "ryzen";
  system.stateVersion = "26.05";

  boot.loader.timeout = 3;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };
}
