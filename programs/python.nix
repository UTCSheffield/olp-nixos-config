{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    (python.withPackages (with pythonPackages: [
      solidpython2
    ]));
  ];
}
