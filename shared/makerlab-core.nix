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
    emacs
    android-studio
    supercollider
    python310
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "vexcode";
          publisher = "VEXRobotics";
          version = "0.6.0";
          sha256 = "sha256-7O3vRuWhPpS6yfyLBlRfmvttJ1qeAP1gPLef3B+jspI=";
        }
        {
          name = "vexfeedback";
          publisher = "VEXRobotics";
          version = "0.2.4";
          sha256 = ""
        }
      ];
    })
  ];
  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "24.05";
}
