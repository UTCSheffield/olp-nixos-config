let
  pkgs = import (fetchTarball("channel:nixpkgs-unstable")) {};
in pkgs.mkShell {
  buildInputs = with pkgs; [
    cargo
    rustc
    typescript
    openssl
    pkgs.pkg-config
    nodejs_20
  ];
}
