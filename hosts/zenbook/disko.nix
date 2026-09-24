{ primaryUser, ... }: {
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";

    content = {
      type = "gpt";
      partitions = {
        ESP = {
          label = "EFI";
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        cryptroot = {
          label = "cryptroot";
          size = "100%";
          content = {
            type = "luks";
            name = "cryptroot";
            askPassword = true;
            settings.allowDiscards = true;

            content = {
              type = "btrfs";
              extraArgs = [ "-f" "-L" "nixos" ];
              subvolumes = {
                "@" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" "noatime" "ssd" "discard=async" ];
                };
                "@home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" "noatime" "ssd" "discard=async" ];
                };
                "@nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" "ssd" "discard=async" ];
                };
                "@log" = {
                  mountpoint = "/var/log";
                  mountOptions = [ "compress=zstd" "noatime" "ssd" "discard=async" ];
                };
                "@cache" = {
                  mountpoint = "/home/${primaryUser}/.cache";
                  mountOptions = [ "compress=zstd" "noatime" "ssd" "discard=async" ];
                };
                "@snapshots" = {
                  mountpoint = "/home/.snapshots";
                  mountOptions = [ "compress=zstd" "noatime" "ssd" "discard=async" ];
                };
              };
            };
          };
        };
      };
    };
  };

  # zram is enough for 16 GiB of RAM. Hibernation is deliberately
  # deferred because encrypted swap needs a separate design and validation.
  swapDevices = [];
}

