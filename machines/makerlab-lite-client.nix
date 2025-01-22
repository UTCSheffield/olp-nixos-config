# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ../shared/makerlab-core.nix
    ../shared/makerlab-lite-userland.nix
  ];
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.makerlab = {
     description = "MakerLab";
     isNormalUser = true;
     extraGroups = [ "dialout" ]; # Enable ‘sudo’ for the user.
     packages = with pkgs; [
     ];
     hashedPassword = "$y$j9T$tZxf41zJFng6RPVjkF1XJ1$yusYNqRcnRozLOrUMvdOCF9CFMFdilJVmw0/BTHmC.0";
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  networking.networkmanager.enable = true;
}
