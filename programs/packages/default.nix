{ pkgs, ... }:

{
    python313Packages = {
        solidpython2 = pkgs.callPackage ./python313Packages/solidpython2.nix {};
        wordhoard = pkgs.callPackage ./python313Packages/wordhoard.nix {};
        deckar01-ratelimit = pkgs.callPackage ./python313Packages/deckar01-ratelimit.nix {};
    };
}