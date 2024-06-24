{ config, lib, pkgs, ... }:
{
  imports = [
   ../programs/firefox.nix
  ];
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma6.enable = true;
    xkb.layout = "gb";
  };
  services.printing.enable = true; # Enables printing
}
