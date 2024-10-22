echo "OLP NixOS Setup"
if [ $(whoami) != 'root' ]; then
  echo "You are not ROOT";
  exit
fi
read -p "Target Config (ex: dell-3040-client)" config
  echo "Partitioning"
  parted /dev/sda -- mklabel gpt
  parted /dev/sda -- mkpart root ext4 512MB -8GB
  parted /dev/sda -- mkpart swap linux-swap -8GB 100%
  parted /dev/sda -- mkpart ESP fat32 1MB 512MB
  parted /dev/sda -- set 3 esp on
  
  echo "Formatting"
  mkfs.ext4 -L nixos /dev/sda1
  mkswap -L swap /dev/sda2
  mkfs.fat -F 32 -n boot /dev/sda3
  
  echo "Mounting"
  mount /dev/disk/by-label/nixos /mnt
  mkdir -p /mnt/boot
  mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
  swapon /dev/sda2
  echo "Setup Nixos"
  mkdir -p /mnt/etc
  mkdir -p /mnt/etc/nixos

  echo "Setup Nixos"
  mkdir -p /mnt/etc
  mkdir -p /mnt/etc/nixos
  nix-env -iA nixos.git
  git clone https://github.com/UTCSheffield/olp-nixos-config /mnt/etc/nixos
  
  nixos-install --flake .#$config
  touch /mnt/root/setup.toml
  echo config=$config >> /mnt/root/setup.toml
  
  echo "Finishing touches"
  nixos-enter --root /mnt -c passwd
  echo hostname=$1 >> /mnt/root/setup.toml
  
  echo "Done now rebooting with reboot"

