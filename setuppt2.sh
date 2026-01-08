if [ $(whoami) != 'root' ]; then
    echo "You are not ROOT, rerunning with sudo..."
    sudo bash "$0" "$@"
    exit
fi

read -p "Target Config (ex: makerlab) " config

echo "Begin Partitioning"
lsblk
read -p "Which Drive? (ex: sda or /dev/sda or nvme0n1) " drive

if [[ "$drive" != /dev/* ]]; then
    drive="/dev/$drive"
fi

parted "$drive" -- mklabel gpt
parted "$drive" -- mkpart root ext4 512MB -8GB
parted "$drive" -- mkpart swap linux-swap -8GB 100%
parted "$drive" -- mkpart ESP fat32 1MB 512MB
parted "$drive" -- set 3 esp on

parted "$drive" name 1 encryptedroot || true
parted "$drive" name 2 swap || true
parted "$drive" name 3 boot || true

echo "Formatting
"
if [[ "$drive" == *"nvme"* || "$drive" == *"mmcblk"* ]]; then
    suf="p"
else
    suf=""
fi

drive1="${drive}${suf}1"
drive2="${drive}${suf}2"
drive3="${drive}${suf}3"

mkfs.ext4 -L nixos /dev/mapper/cryptroot
mkswap -L swap "$drive2"
mkfs.fat -F 32 -n boot "$drive3"

echo "Mounting"
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount -o umask=077 /dev/disk/by-label/boot /mnt/boot

swapon "$drive2"

mkdir -p /mnt/etc
mkdir -p /mnt/config
git clone https://github.com/UTCSheffield/olp-nixos-config /mnt/config
ln -s /mnt/config /mnt/etc/nixos

cachix use utcsheffield
nixos-install --flake /mnt/config#$config

echo "Rebooting in 5 seconds..."
sleep 5
reboot
