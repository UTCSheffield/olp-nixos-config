#!/usr/bin/env bash
set -e

if [ $(whoami) != 'root' ]; then
    echo "You are not ROOT, rerunning with sudo..."
    sudo bash "$0" "$@"
    exit
fi

read -p "Hostname: " hostname
read -p "Config (default: makerlab): " config
if [ -z "$config" ]; then
    config="makerlab"
fi
read -p "Branch (default: master): " branch
if [ -z "$branch" ]; then
    branch="master"
fi
read -sp "Root Password: " ROOT_PASSWORD

lsblk
read -p "Which Drive? (ex: sda or /dev/sda or /dev/nvme0n1) " drive
echo "Partitioning..."

if [[ "$drive" != /dev/* ]]; then
    drive="/dev/$drive"
fi

parted -s $drive -- mklabel gpt
parted -s $drive -- mkpart ESP fat32 1MiB 2049MiB
parted -s $drive -- set 1 esp on
parted -s $drive -- mkpart root ext4 2050MiB -8GiB
parted -s $drive -- mkpart swap linux-swap -8GiB 100%
partprobe "$drive"
udevadm settle

echo "Formatting Disks..."
suf=$([[ "$drive" == *nvme* || "$drive" == *mmcblk* ]] && echo "p" || echo "")

drive1="${drive}${suf}1"
drive2="${drive}${suf}2"
drive3="${drive}${suf}3"

mkfs.fat -I -F 32 -n boot "$drive1"
mkfs.ext4 -F -L nixos "$drive2"
mkswap -f -L swap "$drive3"

echo "Mounting Disks..."
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
swapon "$drive3"

echo "Installing System..."
mkdir -p /mnt/etc
git clone https://github.com/UTCSheffield/olp-nixos-config /mnt/etc/nixos --depth 1 --branch $branch

cat <<EOF > "/mnt/etc/nixos/system.conf"
hostname = "$hostname"
config = "$config"
EOF

nixos-install --flake /mnt/etc/nixos#$config --no-root-password
echo -e "root:$ROOT_PASSWORD" | nixos-enter -c "chpasswd"

echo "Rebooting in 5 seconds..."
sleep 5
reboot
