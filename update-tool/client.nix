{ rustPlatform, lib }:

rustPlatform.buildRustPackage rec {
  pname = "update-tool-client";
  version = "1.0.0";

  src = ./client;  # Use current directory as source

  cargoHash = "sha256-g6M3SZXk5ReUNi1MHfLHE3CtDy9P41ZofTmhAekI0LQ=";

  meta = {
    description = "Update Client";
    homepage = "https://github.com/UTCSheffield/olp-nixos-config";
    license = lib.licenses.unlicense;
    maintainers = [ ];
  };
}
