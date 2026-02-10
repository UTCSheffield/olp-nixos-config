{ self, config, pkgs, ... }:

let
  pythonEnv = import ./python-env.nix { inherit pkgs self; };
in
{
  environment.systemPackages = with pkgs; [
    (pkgs.callPackage ./packages/thonny.nix { inherit pythonEnv; })
  ];
}
