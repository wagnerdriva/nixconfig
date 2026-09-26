{ pkgs, ... }: {
  imports = [
    ./hardware.nix
    ./disko.nix
    ../../modules/nixos/snapshots.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/fingerprint.nix
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

  # ZeroTier sets its TAP MTU to 2800 after the link appears. On networks that
  # drop large encapsulated packets, small SSH commands work but transfers hang.
  # Apply a safe MTU after ZeroTier has finished creating each zt interface.
  services.udev.extraRules = ''
    SUBSYSTEM=="net", ACTION=="add", KERNEL=="zt*", TAG+="systemd", ENV{SYSTEMD_WANTS}+="zerotier-mtu@%k.service"
  '';
  systemd.services."zerotier-mtu@" = {
    description = "Set a safe MTU for ZeroTier interface %I";
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
      ExecStart = "${pkgs.iproute2}/bin/ip link set dev %I mtu 1280";
    };
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    NIXOS_OZONE_WL = "1";
  };
}
