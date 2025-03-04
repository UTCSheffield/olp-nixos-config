{ config, lib, pkgs, ... }:
let solidPythonFull = pkgs.callPackage ../update-tool/client.nix {};
in
{
  environment.systemPackages = with pkgs; [
    (python312Full.withPackages (python-pkgs: with python-pkgs; [
      solidPythonFull
    ]))
  ];
}
