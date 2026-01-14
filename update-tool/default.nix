{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.update-tool;
  updateTool = pkgs.callPackage ./update-tool.nix {};
in
{
  options.services.update-tool = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable the update-tool client service";
    };

    enableServer = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to start the HTTP server (/poll /webhook)";
    };

    listenPort = mkOption {
      type = types.str;
      default = "8080";
      description = "Port for the update-tool HTTP server";
    };

    baseURL = mkOption {
      type = types.str;
      default = "http://127.0.0.1:8080";
      description = "Base URL for polling the server";
    };

    owner = mkOption {
      type = types.str;
      default = "UTCSheffield";
      description = "GitHub owner for the repo";
    };

    repo = mkOption {
      type = types.str;
      default = "olp-nixos-config";
      description = "GitHub repo to track";
    };

    branch = mkOption {
      type = types.str;
      default = "master";
      description = "Branch to track";
    };
  };

  config = mkIf cfg.enable {
    environment.etc."update-tool.conf".text = ''
      listen_port = "${cfg.listenPort}"
      base_url    = "${cfg.baseURL}"
      owner       = "${cfg.owner}"
      repo        = "${cfg.repo}"
      branch      = "${cfg.branch}"
    '';

    environment.systemPackages = [ updateTool ];

    systemd.services.update-tool = {
      description = "Update Tool HTTP client";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${updateTool}/bin/client";
        Restart = "always";
        User = "root";
        Group = "root";
      };
    };

    systemd.services.update-tool-server = mkIf cfg.enableServer {
      description = "Update Tool HTTP server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ pkgs.git ];
      serviceConfig = {
        ExecStart = "${updateTool}/bin/server";
        Restart = "always";
        User = "update-tool";
        Group = "update-tool";
        WorkingDirectory = "/var/lib/update-tool-server";
        StateDirectory = "update-tool-server";
        StateDirectoryMode = "0755";
      };
    };
  };
}
