{ config, pkgs, lib, ... }:

let
  pamOauth2 = pkgs.stdenv.mkDerivation rec {
    pname = "pam_oauth2_device";
    version = "1.0.0";

    src = ./pam_oauth2_device;

    unpackPhase = "cp -r ${src}/* .";

    nativeBuildInputs = [ pkgs.gnumake ];
    buildInputs = [ pkgs.linux-pam pkgs.curl.dev pkgs.openldap.dev ];

    buildPhase = ''
      mkdir -p build build/include build/include/nayuki
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

    environment.etc."pam_oauth2_device/config.json".source = builtins.toPath ./pam_oauth2_device/pam_oauth2_device.json;

    security.pam.services.login.rules.auth.settings = {
        order = 10;
        control = "sufficient";
        modulePath = "${pamOauth2}/lib/security/pam_oauth2_device.so";
    };
    security.pam.services.login.rules.account.settings = {
        order = 10;
        control = "sufficient";
        modulePath = "${pamOauth2}/lib/security/pam_oauth2_device.so";
    };
    security.pam.services.login.rules.session.settings = {
        order = 10;
        control = "sufficient";
        modulePath = "${pamOauth2}/lib/security/pam_oauth2_device.so";
    };

    environment.etc."bashrc.d/pam_oauth2_device.sh".text = ''
      if [[ $(tty) == /dev/tty1 ]]; then
        exec /run/current-system/sw/bin/startplasma-x11
      fi
    '';
  };
}
