{ config, pkgs }:

let client = rustPlatform.buildRustPackage rec {
  pname = "update-tool-client";
  version = "1.0.0";

  src = ./client;  # Use current directory as source
  cargoHash = "sha256-g6M3SZXk5ReUNi1MHfLHE3CtDy9P41ZofTmhAekI0LQ=";
  subPackages = ["client"];
};
in
{
  config = {
    systemd.services.updateClient = {
      description = "Update tool Client";
      serviceConfig = {
      ExecStart = "${client}/bin/client";
      User = "root";
      Restart = "on-failure";
      RestartSec = 10;
      StartLimitIntervalSec = 30;
      StartLimitBurst = 3;
    };
    wantedBy = [ "multi-user.target" ];
  }
