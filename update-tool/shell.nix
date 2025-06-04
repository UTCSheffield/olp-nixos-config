let
  pkgs = import (fetchTarball("channel:nixpkgs-unstable")) {};
in pkgs.mkShell {
  buildInputs = with pkgs; [
    cargo
    rustc
    python312Full
    python312Packages.pip
  ];
  shellHook = ''
    python -m venv venv
    source venv/bin/activate
    pip install -r server/requirements.txt
  '';
}
