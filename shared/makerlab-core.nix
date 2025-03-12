{ config, lib, pkgs, ... }:

{
  imports = [
    ../programs/update-client.nix
    ../programs/python.nix
  ];
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
    emacs
    supercollider
    vscode
    chromium
    tk
    openscad
    obsidian
    sl
  ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.05";
}
