{ config, lib, pkgs, ... }:

let solidPython2 = pkgs.callPackage ../update-tool/client.nix {};
in
{
  environment.systemPackages = with pkgs; [
     solidPython2
  ];
}   
