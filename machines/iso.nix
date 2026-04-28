{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../programs/cachix.nix
  ];

  environment.systemPackages = with pkgs; [
    git
  ];

  services.getty.autologinUser = lib.mkForce "root";

  hardware.enableRedistributableFirmware = true;

  networking.networkmanager.enable = true;

  environment.etc."setup.sh".source = ../setup.sh;
  environment.etc."setup.sh".mode = "0755";

  programs.bash.interactiveShellInit = ''
    [[ "$(tty)" != "/dev/tty1" ]] && return

    echo "Available network devices:"
    nmcli -t -f DEVICE,TYPE,STATE device status | column -t -s :

    echo
    read -rp "Use WiFi? (y/N): " use_wifi

    if [[ "$use_wifi" == "y" || "$use_wifi" == "Y" ]]; then
        echo
        read -rp "Enter WiFi device (e.g. wlan0): " iface

        if ! nmcli device status | awk '{print $1}' | grep -qx "$iface"; then
            echo "Device '$iface' does not exist"
            exit 1
        fi

        echo
        nmcli device set "$iface" managed yes

        echo "Scanning for WiFi networks..."
        nmcli device wifi rescan ifname "$iface"
        sleep 2
        nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list ifname "$iface" \
          | awk -F: '
            $2 != "" {
              if (!($2 in max) || $3 > max[$2]) {
                max[$2] = $3
                line[$2] = $0
              }
            }
            END {
              for (s in line) print line[s]
            }
          ' \
          | sort -t: -k3 -nr \
          | column -t -s :

        echo
        read -rp "SSID: " ssid
        read -rsp "WiFi password: " psk
        echo

        if nmcli device wifi connect "$ssid" password "$psk" ifname "$iface"; then
            echo "Connected to WiFi network '$ssid'"
        else
            echo "Failed to connect to WiFi"
            exit 1
        fi
    fi

    FLAG="$HOME/.installer-ran"
    [ -f "$FLAG" ] && return

    # wait for network (up to 30s)
    for i in {1..30}; do
        ping -c1 -W1 1.1.1.1 &>/dev/null && break
        sleep 1
    done

    touch "$FLAG"
    /etc/setup.sh
  '';
}
