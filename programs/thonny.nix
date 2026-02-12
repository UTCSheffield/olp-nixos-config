{ self, config, pkgs, ... }:

let
  pythonEnv = import ./python-env.nix { inherit pkgs self; };
in
{
  environment.systemPackages = with pkgs; [
    (self.packages.${pkgs.stdenv.hostPlatform.system}.thonny.override { inherit pythonEnv; })
  ];
}
