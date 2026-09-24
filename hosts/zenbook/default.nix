{ ... }: {
  imports = [
    ./hardware.nix
    ./disko.nix
    ../../modules/nixos/snapshots.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/laptop-power.nix
    ../../modules/nixos/netbird.nix
    ../../modules/nixos/nix-ld.nix
    ../../modules/nixos/zerotier.nix
  ];

  networking.hostName = "zenbook";
  system.stateVersion = "26.05";

  boot.loader.timeout = 3;

  # The built-in keyboard is ABNT2. The systemd initrd also applies this
  # keymap to the LUKS passphrase prompt.
  console.keyMap = "br-abnt2";

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    NIXOS_OZONE_WL = "1";
  };
}
