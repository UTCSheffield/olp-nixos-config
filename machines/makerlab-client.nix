# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ../shared/makerlab-core.nix
    ../shared/makerlab-userland.nix
  ];
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.makerlab = {
     description = "MakerLab";
     isNormalUser = true;
     extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
     ];
     hashedPassword = null;
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  systemd.services.utc-update-client = {
    enable = true;
    serviceConfig = {
      ExecStart = "utc-update-client";
      User = "root";
      Restart = "on-failure";
      RestartSec = 10;
      StartLimitIntervalSec = 30;
      StartLimitBurst = 3;
    };
    wantedBy = [ "multi-user.target" ];
  };
}

