{ config, lib, pkgs, ... }:

{
  imports = [
    ../programs/update-client.nix
    ../programs/python.nix
  ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
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
  networking.networkmanager.insertNameservers = [
    "10.102.237.136"
    "1.1.1.1"
    "1.0.0.1"
  ];
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.11";
}
