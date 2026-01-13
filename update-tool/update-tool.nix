{ lib, buildGoModule, ... }:

buildGoModule {
    pname = "update-tool";
    version = "1.0.0";

    src = builtins.toPath ./.;
    
    vendorHash = null;

    subPackages = [
        "cmd/client"
        "cmd/server"
    ];
}