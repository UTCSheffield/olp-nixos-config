{ config, pkgs, ... }:

{
  home.username = "makerlab";
  home.homeDirectory = "/home/makerlab";

  home.file.".local/share/OpenSCAD/libraries/BOSL2" = {
    source = builtins.fetchGit {
      url = "https://github.com/BelfrySCAD/BOSL2";
      ref = "4ce427a8a38786e5f74b728c1e33d9fe7d4904d2";
    };
  };

  home.stateVersion = "24.05";
  
  programs.home-manager.enable = true;
}
