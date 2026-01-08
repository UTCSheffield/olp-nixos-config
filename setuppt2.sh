#!/usr/bin/env bash
set -e

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

parted -s $drive -- mklabel gpt
parted -s $drive -- mkpart root ext4 512MB -8GB
parted -s $drive -- mkpart swap linux-swap -8GB 100%
parted -s $drive -- mkpart ESP fat32 1MB 512MB
parted -s $drive -- set 3 esp on
partprobe "$drive"

echo "Formatting Disks..."
suf=$([[ "$drive" == *nvme* || "$drive" == *mmcblk* ]] && echo "p" || echo "")

drive1="${drive}${suf}1"
drive2="${drive}${suf}2"
drive3="${drive}${suf}3"

mkfs.ext4 -F -L nixos "$drive1"
mkswap -f -L swap "$drive2"
mkfs.fat -I -F 32 -n boot "$drive3"

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
