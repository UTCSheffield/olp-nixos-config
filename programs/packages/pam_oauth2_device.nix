{ config, pkgs, lib, ... }:

let
  pamOauth2 = pkgs.stdenv.mkDerivation rec {
    pname = "pam_oauth2_device";
    version = "1.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "ICS-MU";
      repo = "pam_oauth2_device";
      rev = "master";
      sha256 = "sha256-y9utniTxnE1gEq3CcO2s2PbIyahaJphmA9dSMJWdijo=";
    };

    nativeBuildInputs = [ pkgs.gnumake ];
    buildInputs = [ pkgs.linux-pam pkgs.curl.dev pkgs.openldap.dev ];

    buildPhase = ''
      make
    '';

    installPhase = ''
      mkdir -p $out/lib/security
      cp pam_oauth2_device.so $out/lib/security/
    '';
  };
in
{
  config = {
    environment.systemPackages = [ pamOauth2 ];

    environment.etc."pam_oauth2_device/config.json".source = builtins.toPath ./pam_oauth2_device.json;

    security.pam.services.login.rules.auth.settings = {
        order = 10;
        control = "sufficient";
        modulePath = "${pamOauth2}/lib/security/pam_oauth2_device.so";
    };
  };
}
