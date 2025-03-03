{ config, pkgs, ... }:

{
  home.username = "makerlab";
  home.homeDirectory = "/home/makerlab";

  # OpenSCAD BOSL2 Library (Impure Fetch)
  home.file.".local/share/OpenSCAD/libraries/BOSL2" = {
    source = builtins.fetchGit {
      url = "https://github.com/BelfrySCAD/BOSL2";
      ref = "master";  # Always fetch the latest master branch
    };
  };

  # Enable Home-Manager
  programs.home-manager.enable = true;
}
