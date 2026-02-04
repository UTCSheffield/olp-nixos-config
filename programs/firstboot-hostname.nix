{ pkgs, lib, ... }:

let
  firstboot-hostname = pkgs.stdenv.mkDerivation {
    pname = "firstboot-hostname";
    version = "1.0";

    src = ./firstboot-hostname.sh;
    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/firstboot-hostname
      chmod +x $out/bin/firstboot-hostname
    '';
  };
in
{
  systemd.services.firstboot-hostname = {
    description = "Deterministic Star Wars hostname";
    after = [ "systemd-machine-id-commit.service" ];
    before = [ "network-pre.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ gawk iproute2 inetutils ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      ExecStart = "${firstboot-hostname}/bin/firstboot-hostname";
    };
  };
}
