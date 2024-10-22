{ config, lib, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "uk";
    useXkbConfig = true;
  };
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    gh
    vscode
    emacs
    android-studio
    "android-studio-tools"
    supercollider
  ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.05";
}
