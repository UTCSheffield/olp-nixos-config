{ config, pkgs, ... }:

let
  mitmCert = pkgs.fetchurl {
    url = "http://192.168.5.229:8081/mitmproxy-ca-cert.pem";
    hash = "084k5c1c0mi5i1y1pny3y0q75hh1njqa2ph2jxaz504mwyra89rh";
  };
in
{
  security.pki.certificates = [
    mitmCert
  ];

  environment.sessionVariables = {
    http_proxy  = "http://192.168.5.229:8080";
    https_proxy = "http://192.168.5.229:8080";
  };
}
