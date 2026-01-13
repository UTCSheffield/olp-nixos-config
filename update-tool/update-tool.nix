{ lib, pkgs, ... }:

pkgs.buildGoModule {
    pname = "update-tool";
    version = "1.0.0";

    src = builtins.path {
        name = "update-tool-src";
        path = ./.;
    };
    
    vendorHash = null;

    subPackages = [
        "cmd/client"
        "cmd/server"
    ];
}