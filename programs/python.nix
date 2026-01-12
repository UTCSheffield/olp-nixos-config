{ config, pkgs, ... }:

let
  pythonEnv = import ./packages/python.nix { inherit pkgs; };
in
{
  environment.systemPackages = with pkgs; [
    pythonEnv
  ];
}
