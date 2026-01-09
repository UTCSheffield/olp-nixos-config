{ config, pkgs, ... }:

{  
  imports = [
    ./vscode-with-extensions.nix
  ];

  vscode.extensions = [
    "VEXRobotics.vexcode"
    "VEXRobotics.vexfeedback"
    "usernamehw.errorlens"
    "ms-python.python"
  ];
}
