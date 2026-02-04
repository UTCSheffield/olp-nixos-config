{ config, pkgs, ... }:

let
  pythonEnv = import ./python-env.nix { inherit pkgs; };
in
{
  environment.systemPackages = with pkgs; [
    pythonEnv
  ];
}
