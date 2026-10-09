{ primaryUser, ... }: {
  imports = [
    ./hardware.nix
    ./migration.nix
    ../../modules/nixos/snapshots.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/netbird.nix
    ../../modules/nixos/nix-ld.nix
    ../../modules/nixos/zerotier.nix
  ];

  networking.hostName = "desktop-novo";
  system.stateVersion = "26.05";

  boot.loader.timeout = 10;
  boot.loader.systemd-boot.configurationLimit = 10;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  users.mutableUsers = true;
  users.groups.users.gid = 100;
  users.users.${primaryUser} = {
    uid = 1000;
    group = "users";
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
