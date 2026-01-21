{ config, pkgs, lib, ... }:

let
  mitmDir = "/var/lib/mitmproxy";
  caCert  = "${mitmDir}/mitmproxy-ca-cert.pem";
in
{
  #### 1. Install proxy
  environment.systemPackages = with pkgs; [
    mitmproxy
  ];

  #### 2. Generate CA automatically (once, at activation)
  system.activationScripts.mitmproxyCA = lib.stringAfter [ "var" ] ''
    if [ ! -f ${caCert} ]; then
      echo "Generating mitmproxy CA…"
      mkdir -p ${mitmDir}
      ${pkgs.mitmproxy}/bin/mitmdump --quit >/dev/null 2>&1
      cp /root/.mitmproxy/mitmproxy-ca-cert.pem ${caCert}
      chmod 644 ${caCert}
    fi
  '';

  #### 3. Trust the CA system-wide
  security.pki.certificates = [
    (builtins.readFile caCert)
  ];

  #### 4. Proxy env vars (system-wide)
  environment.sessionVariables = {
    http_proxy  = "http://127.0.0.1:8080";
    https_proxy = "http://127.0.0.1:8080";
    HTTP_PROXY  = "http://127.0.0.1:8080";
    HTTPS_PROXY = "http://127.0.0.1:8080";
  };
}
