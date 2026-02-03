{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../programs/cachix.nix
    ../programs/firefox.nix
  ];

  users.users.pi = {
    description = "Raspberry Pi";
    isNormalUser = true;
    extraGroups = [ "networkmanager" ];
    initialPassword = "";
  };

  networking.networkmanager.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = "nix-command flakes";

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "uk";
    useXkbConfig = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    thonny
    (python313.withPackages (python-pkgs: with python-pkgs; [
      pygame
      colorama
      rich
      art
      pyfiglet
      faker
      wordhoard
      emoji
    ]))
  ];

  services.xserver = {
    enable = true;
    xkb.layout = "gb";
    desktopManager.mate.enable = true;
    displayManager.lightdm = true;
  };

  system.stateVersion = "25.11";
}
