with import <nixpkgs> {};

let
  version = "1.0.0";
in
buildGoModule {
  pname = "utc-updater";
  inherit version;

  src = fetchFromGitHub {
    owner = "UTCSheffield";
    repo = "olp-nixos-update";
    rev = "latest";
    hash = "sha256-dnvixov+T18FP0Y6YGUl0fxcXH810GVk9CbvosB36ng=";
  };

  buildPhase = ''
    go build -tags client -o utc-update-client
    go build -tags server -o utc-update-server
    go build -tags updater -o utc-update
    runHook buildPhase
    mkdir -p $out/bin
    cp ./utc-update-client $out/bin
    cp ./utc-update-server $out/bin
    cp ./utc-update $out/bin
  '';

  vendorHash = "sha256-96ur548mmeFfC0qcIv9KU0f2sX/OzeUnAa4PrphwiwM=";

  meta = with lib; {
    homepage = "https://github.com/UTCSheffield/olp-nixos-update";
    description = "UTC OLP NixOS Update Client";
    license = licenses.mit;
    maintainers = with maintainers; [ archie ];
  };
}
