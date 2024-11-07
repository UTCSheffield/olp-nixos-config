{ lib, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "update-tool-client";
  version = "1.0.0";

  src = ./client;  # Use current directory as source

  cargoHash = "sha256-jtBw4ahSl88L0iuCXxQgZVm1EcboWRJMNtjxLVTtzts=";

  meta = {
    description = "Update Client";
    homepage = "https://github.com/UTCSheffield/olp-nixos-config";
    license = lib.licenses.unlicense;
    maintainers = [ ];
  };
}