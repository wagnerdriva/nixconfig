{ lib, pkgs, primaryUser, hostName, ... }:
let
  powerProfileBySource = pkgs.writeShellScript "power-profile-by-source" ''
    set -eu

    target=power-saver
    for supply in /sys/class/power_supply/*; do
      [ -r "$supply/type" ] || continue
      [ "$(< "$supply/type")" = "Mains" ] || continue
      [ -r "$supply/online" ] || continue
      if [ "$(< "$supply/online")" = "1" ]; then
        target=performance
        break
      fi
    done

    current="$(${pkgs.power-profiles-daemon}/bin/powerprofilesctl get)"
    if [ "$current" != "$target" ]; then
      ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set "$target"
    fi
  '';
in {
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  nixpkgs.config.allowUnfree = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  boot.kernelParams = [ "quiet" ];

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  time.timeZone = "America/Sao_Paulo";
  i18n.defaultLocale = "pt_BR.UTF-8";
  console.keyMap = "us";

  hardware.enableRedistributableFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
      publish = {
        enable = true;
        addresses = true;
        workstation = true;
      };
    };
    blueman.enable = true;
    fwupd.enable = true;
    fstrim.enable = true;
    thermald.enable = true;
    power-profiles-daemon.enable = true;
    upower.enable = true;
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };

  # Keep the laptop fast on AC and efficient on battery. The NixOS module
  # enables power-profiles-daemon but does not select a profile per power
  # source, so apply the policy whenever the source state is checked.
  systemd.services.power-profile-by-source = lib.mkIf (hostName == "precision") {
    description = "Select a power profile from the active power source";
    after = [ "power-profiles-daemon.service" "upower.service" ];
    wants = [ "power-profiles-daemon.service" "upower.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = powerProfileBySource;
    };
  };

  systemd.timers.power-profile-by-source = lib.mkIf (hostName == "precision") {
    description = "Check the power-source power profile";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "5s";
      OnUnitActiveSec = "30s";
      Unit = "power-profile-by-source.service";
    };
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  users.users.${primaryUser} = {
    isNormalUser = true;
    description = "Wagner";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "storage"
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/X+zSF5di3nf9MOjoWXCpLhvQqJjc2kd+VAImDQgZ+"
    ];
  };

  programs.fish.enable = true;
  security.sudo.wheelNeedsPassword = true;

  environment.systemPackages = with pkgs; [
    curl
    git
    helix
    pciutils
    smartmontools
    unzip
    usbutils
    wget
    nvme-cli
  ];
}
