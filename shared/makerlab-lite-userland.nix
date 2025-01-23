{ config, lib, pkgs, ... }:
{
  imports = [
    ../programs/firefox.nix
  ];
  services.xserver = {
    enable = true;
    xkb.layout = "gb";
  };
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.lxqt.enable = true;
  services.printing.enable = true; # Enables printing
}
