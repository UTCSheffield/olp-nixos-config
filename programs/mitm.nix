{ config, pkgs, lib, ... }:

{
  security.pki.certificates = [
    "/var/mitm.pem"
  ];

  environment.sessionVariables = {
    http_proxy  = "http://192.168.5.229:8080";
    https_proxy = "http://192.168.5.229:8080";
    HTTP_PROXY  = "http://192.168.5.229:8080";
    HTTPS_PROXY = "http://192.168.5.229:8080";
    no_proxy    = "localhost,127.0.0.1,::1";
    NO_PROXY    = "localhost,127.0.0.1,::1";
  };
}
