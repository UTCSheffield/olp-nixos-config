{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (python312Full.withPackages (python-pkgs: with python-pkgs; [
      solidpython2
    ]))
  ];
}
