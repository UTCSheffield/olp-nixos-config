{
  self,
  config,
  lib,
  pkgs,
  ...
}:

let
  starwars-hostname = self.packages.${pkgs.stdenv.hostPlatform.system}.starwars-hostname;
in
{
  imports = [
    ../programs/cachix.nix
    ../programs/firefox.nix
    ../programs/python.nix
  ];

  swapDevices = [{
    device = "/swapfile";
    size = 6 * 1024;
  }];

  users.users.pi = {
    description = "Raspberry Pi";
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
    initialPassword = "raspberry";
  };

  documentation.man.enable = false;

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
    starwars-hostname
    (pkgs.callPackage ../programs/pycharm.nix { inherit self; })
  ];

  services.xserver = {
    enable = true;
    xkb.layout = "gb";
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
  };

  environment.defaultPackages = [];

  system.stateVersion = "25.11";
}
