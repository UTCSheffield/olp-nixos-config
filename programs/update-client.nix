{ config, lib, pkgs, ... }:

let updateClient = pkgs.callPackage ../update-tool/client.nix {};
in
{
  environment.systemPackages = with pkgs; [
     updateClient
  ];
  systemd.services.updateClient = {
      description = "Update tool Client";
      path = [
	pkgs.git
      ];
      serviceConfig = {
        ExecStart = "${updateClient}/bin/update-client --wss-path='wss://olp-nixos-config-production.up.railway.app'";
        User = "root";
        Restart = "on-failure";
        RestartSec = 10;
        StartLimitIntervalSec = 30;
        StartLimitBurst = 3;
        StandardOutput = "journal";
	StandardError = "journal";
	ProtectSystem = "false";
	ReadWritePaths = [ "/etc/nixos" ];
      };
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      requires = [ "network.target" ];
  };
}   
