{ config, pkgs, ... }:

{
  home.username = "makerlab";
  home.homeDirectory = "/home/makerlab";

  home.file.".local/share/OpenSCAD/libraries/BOSL2" = {
    source = builtins.fetchGit {
      url = "https://github.com/BelfrySCAD/BOSL2";
      ref = "master";  # Always fetch the latest master branch
    };
  };

  home.stateVersion = "24.05";
  
  programs.home-manager.enable = true;
}
