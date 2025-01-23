{ config, lib, pkgs, ... }:
{
  imports = [
    ../programs/firefox.nix
  ];
  services.xserver = {
    enable = true;
    xkb.layout = "gb";
  };
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.printing.enable = true; # Enables printing
}
