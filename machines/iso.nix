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

  boot.kernelParams = [ "copytoram" ];

  environment.systemPackages = with pkgs; [
    git
  ];

  services.getty.autologinUser = lib.mkForce "root";

  environment.etc."setup.sh".source = ../setup.sh;
  environment.etc."setup.sh".mode = "0755";
  programs.bash.interactiveShellInit = ''
    [[ "$(tty)" != "/dev/tty1" ]] && return

    echo "Available network interfaces:"
    ip -o link show | awk -F': ' '{print $2}'
    
    echo
    read -rp "Use WiFi? (y/N): " use_wifi
    
    if [[ "$use_wifi" == "y" || "$use_wifi" == "Y" ]]; then
        echo
        read -rp "Enter WiFi interface (e.g. wlan0): " iface
    
        if ! ip link show "$iface" >/dev/null 2>&1; then
            echo "Interface '$iface' does not exist"
            exit 1
        fi
    
        echo
        read -rp "SSID: " ssid
        read -rsp "WiFi password: " psk
        echo
    
        # Bring interface up
        ip link set "$iface" up
    
        # Start wpa_supplicant (in background)
        wpa_supplicant -B \
            -i "$iface" \
            -c <(wpa_passphrase "$ssid" "$psk")
    
        echo "WiFi connection started on $iface"
    fi

    FLAG="$HOME/.installer-ran"
    [ -f "$FLAG" ] && return

    # wait for network (up to 30s)
    for i in {1..30}; do ping -c1 -W1 1.1.1.1 &>/dev/null && break; sleep 1; done

    touch "$FLAG"
    /etc/setup.sh
  '';
}
