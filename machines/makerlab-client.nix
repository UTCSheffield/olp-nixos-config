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
     hashedPassword = "$y$j9T$.IYpfqUfad1f75Cis.NmG1$nBq/MwwZXcQhIB.nVrJtLuGGDcvmvI8GrJ5XmqLaxjA";
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
}

