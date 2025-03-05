{ config, pkgs, ... }:

{
  home.username = "makerlab";
  home.homeDirectory = "/home/makerlab";

  home.file.".local/share/OpenSCAD/libraries/BOSL2" = {
    source = pkgs.fetchFromGitHub {
      owner = "UTCSheffield";
      repo = "BOSL2";
      rev = "master";
      sha256 = "sha256-wdiWvf7fXA3IL8ph4yR1k+lYkmuEAt11oU+rjcBGkw8=";
    };
  };

  home.stateVersion = "24.05";
  
  programs.home-manager.enable = true;
}
