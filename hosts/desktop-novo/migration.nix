{ lib, primaryUser, ... }: {
  networking.networkmanager.ensureProfiles.profiles.cabo-migracao = {
    connection = {
      id = "cabo-migracao";
      type = "ethernet";
      interface-name = "enp5s0";
      autoconnect = true;
      autoconnect-priority = 100;
    };
    ethernet = { };
    ipv4 = {
      method = "manual";
      address1 = "10.203.0.2/24";
      gateway = "10.203.0.1";
      dns = "1.1.1.1;";
      route-metric = 50;
    };
    ipv6.method = "disabled";
  };

  users.users.${primaryUser}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID/RhmwFjFWJcU+NRx7dfMFN5lFp3kR1BD5jQ5bMG2Dv migracao-live-20261008"
  ];

  services.netbird.enable = lib.mkForce false;
  services.netbird.clients = lib.mkForce { };
  services.netbird.ui.enable = lib.mkForce false;
  services.zerotierone.enable = lib.mkForce false;
  nix.gc.automatic = lib.mkForce false;
  virtualisation.docker.autoPrune.enable = lib.mkForce false;
  services.snapper.configs.home.TIMELINE_CLEANUP = lib.mkForce false;
  services.snapper.configs.home.NUMBER_CLEANUP = lib.mkForce false;
  systemd.timers.snapper-cleanup.enable = lib.mkForce false;
}
