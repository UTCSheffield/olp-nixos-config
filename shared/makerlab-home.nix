{ config, pkgs, ... }:

{
  home.username = "makerlab";
  home.homeDirectory = "/home/makerlab";

  home.file.".local/share/OpenSCAD/libraries/BOSL2" = {
    source = pkgs.fetchFromGitHub {
      owner = "UTCSheffield";
      repo = "BOSL2";
      rev = "master";
      sha256 = "d5558cd419c8d46bdc958064cb97f963d1ea793866414c025906ec15033512ed";
    };
  };

  home.stateVersion = "24.05";
  
  programs.home-manager.enable = true;
}
