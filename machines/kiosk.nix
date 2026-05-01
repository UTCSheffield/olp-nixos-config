{ pkgs, config, lib, ... }:

{
  imports = [
    ../hardware/generic.nix
    ../programs/kiosk.nix
    ../programs/update-tool.nix
  ];

  specialisation.test.configuration = {
    kiosk.enable = true;
    kiosk.url = "https://example.com";
  };

  system.stateVersion = "25.11";
}
// lib.mkIf (config.specialisation != {}) {
  systemd.services.update-tool = lib.mkForce {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    requires = [ "network.target" ];

    serviceConfig = {
      ExecStart =
        "${pkgs.callPackage ../update-tool/update-tool.nix { }}/bin/client";
      StandardInput = "tty";
      StandardOutput = "tty";
      TTYPath = "/dev/tty1";
    };
  };

  systemd.services."autovt@tty1".enable = false;
}