{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../hardware/generic.nix
    ../programs/cachix.nix
    ../programs/firefox.nix
    ../programs/vscode.nix
    ../programs/python.nix
  ];

  users.users.makerlab = {
    description = "MakerLab";
    isNormalUser = true;
    extraGroups = [ "dialout" ];
    hashedPassword = "$y$j9T$EmEGlmnrC0GA5eactKvPR/$RxyEC85GvBOaTEodmuKFJUV0K/Stg9kdehfxsd7oxG9";
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

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
    gh
  ];

  services.displayManager.gdm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver = {
    enable = true;
    xkb.layout = "gb";
  };

  system.stateVersion = "25.11";
}
