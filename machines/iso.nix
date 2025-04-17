{ config, lib, pkgs, ... }:
with lib;
{
    environment.etc."setup.sh".source = ../setup.sh;
    environment.etc."setup.sh".mode = "0755";
    services.getty.autologinUser = lib.mkForce "root";
    environment.systemPackages = [
        pkgs.git
        pkgs.cachix
    ];
}
