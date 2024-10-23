{ config, lib, pkgs, ... }:
{
  imports = [
    ../programs/firefox.nix
  ];
  services.xserver = {
    enable = true;
    xkb.layout = "gb";
  };
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.printing.enable = true; # Enables printing
}
