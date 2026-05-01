{ pkgs, config, lib, ... }:

{
  imports = [
    ../hardware/generic.nix
    ../programs/kiosk.nix
    ../programs/update-tool.nix
  ];

  systemd.tpm2.enable = false; # improve boot time
  boot.initrd.systemd.tpm2.enable = false;

  specialisation = {
    art.configuration = {
        kiosk.url = "https://utcsheffield.github.io/olp-hydra-art/";
    };

    sprig-gallery.configuration = {
        kiosk.url = "https://utcsheffield.github.io/sprig-arcade/";
    };

    sprig-random.configuration = {
        kiosk.url = "https://utcsheffield.github.io/sprig-arcade/random/";
    };

    exam-timer.configuration = {
        kiosk.url = "https://utcsheffield.github.io/UTC-Exam-Timer-2/web/timer.html";
    };

    adhoc-exam-timer.configuration = {
        kiosk.url = "https://utcsheffield.github.io/UTC-Exam-Timer-2/web/adhoc.html";
    };
  };

  system.stateVersion = "25.11";

  systemd.services.update-tool = lib.mkIf (config.specialisation != {}) (
    lib.mkForce {
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
    }
  );

  systemd.services."autovt@tty1".enable =
    lib.mkIf (config.specialisation != {}) false;
}