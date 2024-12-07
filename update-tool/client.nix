{ rustPlatform, lib, pkg-config, openssl_3 }:

rustPlatform.buildRustPackage rec {
  pname = "update-tool-client";
  version = "1.0.0";

  src = ./client;  # Use current directory as source

  cargoHash = "sha256-beNik/xLr4adwFcFOxcplvwvjvE7dpQhqBA+gKPPFEM=";
  buildInputs = [ openssl_3 pkg-config ];

  preBuild = ''
    export OPENSSL_DIR=${openssl_3.dev}
    export OPENSSL_INCLUDE_DIR=${openssl_3.dev}/include
    export OPENSSL_LIB_DIR=${openssl_3.out}/lib
    export PKG_CONFIG_PATH=${openssl_3.dev}/lib/pkgconfig
  '';

  meta = {
    description = "Update Client";
    homepage = "https://github.com/UTCSheffield/olp-nixos-config";
    license = lib.licenses.unlicense;
    maintainers = [ ];
  };
}
