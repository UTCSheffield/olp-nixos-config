#!/usr/bin/env bash
set -e

NO_FORMAT=0

for arg in "$@"; do
    case "$arg" in
        --no-disk-format)
            NO_FORMAT=1
            ;;
    esac
done

if [ $(whoami) != 'root' ]; then
    echo "You are not ROOT, rerunning with sudo..."
    sudo bash "$0" "$@"
    exit
fi

read -p "Hostname: " hostname
if [ -z "$hostname" ]; then
    echo "Hostname empty, restarting..."
    bash "$0" "$@"
    exit
fi

read -sp "Root Password: " ROOT_PASSWORD
echo
if [ -z "$ROOT_PASSWORD" ]; then
    echo "Root password empty, restarting..."
    bash "$0" "$@"
    exit
fi

read -p "Config (default: makerlab): " config
if [ -z "$config" ]; then
    config="makerlab"
fi
read -p "Branch (default: master): " branch
if [ -z "$branch" ]; then
    branch="master"
fi

if [ "$NO_FORMAT" -eq 0 ]; then
    lsblk
    read -p "Which Drive? (ex: sda or /dev/sda or /dev/nvme0n1) " drive
    if [[ "$drive" != /dev/* ]]; then
        drive="/dev/$drive"
    fi

    suf=$([[ "$drive" == *nvme* || "$drive" == *mmcblk* ]] && echo "p" || echo "")

    drive1="${drive}${suf}1"
    drive2="${drive}${suf}2"
    drive3="${drive}${suf}3"
    echo "Partitioning..."

    parted -s $drive -- mklabel gpt
    parted -s $drive -- mkpart ESP fat32 1MiB 2049MiB
    parted -s $drive -- set 1 esp on
    parted -s $drive -- mkpart root ext4 2050MiB -8GiB
    parted -s $drive -- mkpart swap linux-swap -8GiB 100%
    partprobe "$drive"
    udevadm settle

    echo "Formatting Disks..."
    mkfs.fat -I -F 32 -n boot "$drive1"
    mkfs.ext4 -F -L nixos "$drive2"
    mkswap -f -L swap "$drive3"

    echo "Mounting Disks..."
    mount "$drive2" /mnt
    mkdir -p /mnt/boot
    mount "$drive1" /mnt/boot
    swapon "$drive3"
fi

echo "Installing System..."
mkdir -p /mnt/etc
rm -rf /mnt/etc/nixos
git clone https://github.com/UTCSheffield/olp-nixos-config /mnt/etc/nixos --depth 1 --branch $branch

cat <<EOF > "/mnt/etc/nixos/system.conf"
hostname = "$hostname"
config = "$config"
EOF

nixos-install --flake /mnt/etc/nixos#$config --no-root-password
echo -e "root:$ROOT_PASSWORD" | nixos-enter -c "chpasswd"

WIFI_LINE=$(nmcli -t -f NAME,TYPE,DEVICE connection show --active | grep ':802-11-wireless:' || true)

if [ -n "$WIFI_LINE" ]; then
    echo "Copying WiFi profile..."

    CONN=$(echo "$WIFI_LINE" | head -n1 | cut -d: -f1)
    FILE=$(grep -rl "id=$CONN" /etc/NetworkManager/system-connections/ || true)

    if [ -n "$FILE" ]; then
        mkdir -p /mnt/etc/NetworkManager/system-connections
        cp "$FILE" /mnt/etc/NetworkManager/system-connections/
        chmod 600 /mnt/etc/NetworkManager/system-connections/*.nmconnection
        echo "Copied WiFi profile: $CONN"
    else
        echo "Active WiFi connection found, but profile file was not located"
    fi
else
    echo "No active WiFi connection found"
fi

echo "Exiting in 5 seconds..."
sleep 5
