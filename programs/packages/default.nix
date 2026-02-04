{ pkgs, ... }:

{
    solidpython2 = pkgs.callPackage ./python313Packages/solidpython2.nix {};
    wordhoard = pkgs.callPackage ./python313Packages/wordhoard.nix {};
}