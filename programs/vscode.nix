{ config, pkgs, ... }:

{  
  imports = [
    ./vscode-with-extensions.nix
  ];

  vscode.extensions = [ ];
}
