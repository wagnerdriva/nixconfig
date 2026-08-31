{ pkgs, primaryUser, ... }: {
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
