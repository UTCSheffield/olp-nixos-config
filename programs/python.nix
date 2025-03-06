{ config, lib, pkgs, ... }:
let solidPythonFull = pkgs.callPackage ./solidpython2-package.nix {};
in
{
  environment.systemPackages = with pkgs; [
    (python312Full.withPackages (python-pkgs: [
      solidPythonFull
    ]))
  ];
}
