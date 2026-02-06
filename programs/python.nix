{ self, config, pkgs, ... }:

let
  pythonEnv = import ./python-env.nix { inherit pkgs self; };
in
{
  environment.systemPackages = with pkgs; [
    pythonEnv
  ];
}
