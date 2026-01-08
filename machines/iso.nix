{ config, lib, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        git
        cachix
    ];
    services.getty.autologinUser = lib.mkForce "root";
    environment.etc."setup.sh".source = ../setup.sh;
    environment.etc."setup.sh".mode = "0755";

    environment.etc."nixos-shell-hook.sh".text = ''
        #!/usr/bin/env bash
        [[ "$(tty)" != "/dev/tty1" ]] && return

        FLAG="$HOME/.installer-ran"
        if [ -f "$FLAG" ]; then
        return
        fi
        touch "$FLAG"

        /etc/setup.sh
    '';

    programs.bash.interactiveShellInit = ''
        source /etc/nixos-shell-hook.sh
    '';
}