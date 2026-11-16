{ pkgs, ... }: {
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
  ];

  networking.hostName = "zenbook";
  system.stateVersion = "26.05";

  services.tailscale = {
    enable = true;
    openFirewall = true;
    # Tailscale's netfilter rules drop 100.64.0.0/10 traffic outside tailscale0, breaking NetBird (100.90.0.0/16) DNS.
    extraSetFlags = [ "--netfilter-mode=off" ];
  };
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  boot.loader.timeout = 3;

  # The built-in keyboard is ABNT2. The systemd initrd also applies this
  # keymap to the LUKS passphrase prompt.
  console.keyMap = "br-abnt2";

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    NIXOS_OZONE_WL = "1";
  };
}
