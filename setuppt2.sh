echo "OLP NixOS Setup"
if [ $(whoami) != 'root' ]; then
  echo "You are not ROOT";
  exit
fi
read -p "Target Config (ex: makerlab-3040) " config
  echo "Partitioning"
  lsblk
  read -p "Which Drive? (ex: sda) " drive
  parted /dev/$drive -- mklabel gpt
  parted /dev/$drive -- mkpart root ext4 512MB -8GB
  parted /dev/$drive -- mkpart swap linux-swap -8GB 100%
  parted /dev/$drive -- mkpart ESP fat32 1MB 512MB
  parted /dev/$drive -- set 3 esp on
  echo "Formatting"

  drive1="$drive"1
  drive2="$drive"2
  drive3="$drive"3

  mkfs.ext4 -L nixos /dev/$drive1
  mkswap -L swap /dev/$drive2
  mkfs.fat -F 32 -n boot /dev/$drive3
  echo "Mounting"
  mount /dev/disk/by-label/nixos /mnt
  mkdir -p /mnt/boot
  mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
  swapon /dev/$drive2
  echo "Setup Nixos"
  mkdir -p /mnt/etc
  mkdir -p /mnt/etc/nixos

  nix-env -iA nixos.git
  git clone https://github.com/UTCSheffield/olp-nixos-config /mnt/etc/nixos

  nixos-install --flake /mnt/etc/nixos#$config

  touch /mnt/root/setup.toml
  echo config="$config" >> /mnt/root/setup.toml
  
  echo "Done, reboot."
