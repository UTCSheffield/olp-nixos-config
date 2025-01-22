{ config, lib, pkgs, ... }:
{
  imports = [
    ../programs/firefox.nix
  ];
  services.xserver = {
    enable = true;
    xkb.layout = "gb";
  };
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.windowManager.default = "lxqt";
  services.printing.enable = true; # Enables printing
}
