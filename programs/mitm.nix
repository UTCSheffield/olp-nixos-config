{ config, pkgs, lib, ... }:

let
  mitmCA = pkgs.runCommand "mitmproxy-ca" {} ''
    export HOME=$TMPDIR
    ${pkgs.mitmproxy}/bin/mitmdump --quit >/dev/null 2>&1
    mkdir -p $out
    cp $HOME/.mitmproxy/mitmproxy-ca-cert.pem $out/mitmproxy-ca-cert.pem
  '';
in
{
  #### 1. Install mitmproxy
  environment.systemPackages = [ pkgs.mitmproxy ];

  #### 2. Trust CA system-wide (pure)
  security.pki.certificates = [
    "${mitmCA}/mitmproxy-ca-cert.pem"
  ];

  nix.settings = {
    http-proxy = "";
    https-proxy = "";
  };
}
