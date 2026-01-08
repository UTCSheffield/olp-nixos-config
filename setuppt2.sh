#!/usr/bin/env bash

if [ $(whoami) != 'root' ]; then
    echo "You are not ROOT, rerunning with sudo..."
    sudo bash "$0" "$@"
    exit
fi

read -p "Hostname: " hostname
read -p "Config (ex: makerlab): " config

lsblk
read -p "Which Drive? (ex: sda or /dev/sda or /dev/nvme0n1) " drive
echo "Partitioning..."

if [[ "$drive" != /dev/* ]]; then
    drive="/dev/$drive"
fi

parted "$drive" -- mklabel gpt
parted "$drive" -- mkpart root ext4 512MB -8GB
parted "$drive" -- mkpart swap linux-swap -8GB 100%
parted "$drive" -- mkpart ESP fat32 1MB 512MB
parted "$drive" -- set 3 esp on

parted "$drive" name 1 nixos || true
parted "$drive" name 2 swap || true
parted "$drive" name 3 boot || true

echo "Formatting Disks..."
suf=$([[ "$drive" == *nvme* || "$drive" == *mmcblk* ]] && echo "p" || echo "")

drive1="${drive}${suf}1"
drive2="${drive}${suf}2"
drive3="${drive}${suf}3"

mkfs.ext4 -L nixos "$drive1"
mkswap -L swap "$drive2"
mkfs.fat -F 32 -n boot "$drive3"

echo "Mounting Disks..."
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
swapon "$drive2"

echo "Installing System..."
mkdir -p /mnt/etc
git clone https://github.com/UTCSheffield/olp-nixos-config /mnt/etc/nixos

cat <<EOF > "/mnt/etc/nixos/system.conf"
hostname = $hostname
config = $config
EOF

nixos-install --flake /mnt/etc/nixos#$config

echo "Rebooting in 5 seconds..."
sleep 5
reboot
