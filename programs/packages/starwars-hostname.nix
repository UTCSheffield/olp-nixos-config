{ pkgs, lib, ... }:

let
  pkg = pkgs.stdenv.mkDerivation {
    pname = "starwars-hostname";
    version = "1.0";

    src = ./starwars-hostname.sh;
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/starwars-hostname
      chmod +x $out/bin/starwars-hostname
    '';
  };
in
pkg.overrideAttrs (_: {
  passthru.nixosModule = { config, pkgs, lib, ... }: {
    systemd.services.starwars-hostname = {
      description = "Deterministic Star Wars hostname";
      after = [ "systemd-machine-id-commit.service" ];
      before = [ "network-pre.target" ];
      wantedBy = [ "multi-user.target" ];

      path = with pkgs; [ gawk iproute2 inetutils ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${pkg}/bin/starwars-hostname";
      };
    };
  };
})
