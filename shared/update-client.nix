{ config, lib, pkgs }:

{
  environment.systemPackages = with pkgs; [
    (callPackage ../update-tool/client.nix {})
  ];
  systemd.services.updateClient = {
      description = "Update tool Client";
      serviceConfig = {
        ExecStart = "update-client";
        User = "root";
        Restart = "on-failure";
        RestartSec = 10;
        StartLimitIntervalSec = 30;
        StartLimitBurst = 3;
      };
      wantedBy = [ "multi-user.target" ];
  };
}   
