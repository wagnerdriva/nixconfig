#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  printf 'Execute no PC novo: sudo bash %s\n' "$0" >&2
  exit 1
fi

if [ "$(hostname)" != desktop-novo ] ||
   [ ! -d /sys/firmware/efi ] ||
   [ "$(findmnt -n -o UUID /)" != 3c07da7e-cca5-436f-bb82-8bb01cb2d123 ] ||
   [ "$(findmnt -n -o UUID /home)" != 3c07da7e-cca5-436f-bb82-8bb01cb2d123 ] ||
   [ "$(findmnt -n -o UUID /nix)" != 3c07da7e-cca5-436f-bb82-8bb01cb2d123 ] ||
   [ "$(findmnt -n -o FSROOT /)" != /@root ] ||
   [ "$(findmnt -n -o FSROOT /home)" != /@home ] ||
   [ "$(findmnt -n -o FSROOT /nix)" != /@nix ] ||
   [ "$(findmnt -n -o UUID /boot)" != B9BF-0245 ]; then
  printf 'Abortado: esta não é a instalação verificada do desktop novo.\n' >&2
  exit 1
fi

luks_device=$(cryptsetup status nixos-root | awk '$1 == "device:" { print $2 }')
if [ "$(cryptsetup luksUUID "$luks_device")" != 17a0fe8b-72ea-4de0-8cf6-127869db1e65 ] ||
   [ "$(id -u wagner)" != 1000 ] || [ "$(id -g wagner)" != 100 ] ||
   [ "$(passwd -S wagner | awk '{ print $2 }')" != P ]; then
  printf 'Abortado: volume LUKS ou conta local divergem do estado verificado.\n' >&2
  exit 1
fi

repository=$(cd -- "$(dirname -- "$0")/../.." && pwd -P)
if [ "$repository" != /home/wagner/nixos-config ]; then
  printf 'Abortado: repositório fora do caminho esperado.\n' >&2
  exit 1
fi

baseline=/nix/var/nix/gcroots/migracao-desktop-base
if [ ! -e "$baseline" ]; then
  nix-store --add-root "$baseline" --realise "$(readlink -f /run/current-system)"
fi

if ! btrfs subvolume show /home/.snapshots >/dev/null 2>&1; then
  if [ -e /home/.snapshots ] || [ -L /home/.snapshots ]; then
    printf 'Abortado: /home/.snapshots já existe; revisar sem apagar dados.\n' >&2
    exit 1
  fi
  btrfs subvolume create /home/.snapshots
  chmod 0750 /home/.snapshots
  chown root:root /home/.snapshots
fi

nixos-rebuild boot --flake "$repository#desktop-novo" \
  --no-update-lock-file --no-write-lock-file --max-jobs 4 --cores 8

printf '\nConfiguração preparada para o próximo boot. Não houve reboot automático.\n'
printf 'Mantenha a geração base e reinicie somente quando estiver pronto.\n'
