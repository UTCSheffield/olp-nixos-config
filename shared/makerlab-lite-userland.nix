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
  services.windowManager.default = "lxqt";
  services.printing.enable = true; # Enables printing
}
