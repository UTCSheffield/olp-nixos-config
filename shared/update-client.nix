{ config, lib, pkgs, ... }:

let updateClient = pkgs.callPackage ../update-tool/client.nix {};
in
{
  environment.systemPackages = with pkgs; [
     updateClient
  ];
  systemd.services.updateClient = {
      description = "Update tool Client";
      serviceConfig = {
        ExecStart = "${updateClient}/bin/update-client --wss-path=127.0.0.1:8080";
        User = "root";
        Restart = "on-failure";
        RestartSec = 10;
        StartLimitIntervalSec = 30;
        StartLimitBurst = 3;
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      requires = [ "network.target" ];
  };
}   
