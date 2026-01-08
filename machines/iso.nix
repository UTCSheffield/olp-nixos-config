{ config, lib, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        git
        cachix
    ];
    services.getty.autologinUser = lib.mkForce "root";
    environment.etc."setup.sh".source = ../setup.sh;
    environment.etc."setup.sh".mode = "0755";

    programs.bash.interactiveShellInit = ''
      [[ "$(tty)" != "/dev/tty1" ]] && return
      FLAG="$HOME/.installer-ran"
      [ -f "$FLAG" ] && return
    
      # wait for network (up to 30s)
      for i in {1..30}; do ping -c1 -W1 1.1.1.1 &>/dev/null && break; sleep 1; done
    
      touch "$FLAG"
      /etc/setup.sh
    '';
}
