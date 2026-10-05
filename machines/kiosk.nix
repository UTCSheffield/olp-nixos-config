{ pkgs, config, lib, ... }:

{
  imports = [
    ../hardware/generic.nix
    ../programs/kiosk.nix
    ../programs/update-tool.nix
  ];

  boot.kernelParams = [ "ipv6.disable=1" ];

  console.keyMap = lib.mkDefault "uk";
  services.xserver.xkb.layout = lib.mkDefault "gb";

  systemd.tpm2.enable = false; # improve boot time
  boot.initrd.systemd.tpm2.enable = false;
  networking.networkmanager.enable = true;

  environment.systemPackages = with pkgs; [
    git
  ];

  systemd.services."autovt@tty1".enable = false;

  systemd.services."autovt@tty2".enable = false;
  systemd.services.nmtty2 = {
    enable = true;
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 15";
      ExecStart = "${pkgs.networkmanager}/bin/nmtui";
      StandardInput = "tty";
      StandardOutput = "tty";
      TTYPath = "/dev/tty2";
    };
  };

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

    healthcareers-nhs.configuration = {
        kiosk.url = "https://www.healthcareers.nhs.uk/FindYourCareer";
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

      path = [
        pkgs.git
      ];

      serviceConfig = {
        ExecStart =
          "${pkgs.callPackage ../update-tool/update-tool.nix { }}/bin/client --oneshot";
        StandardInput = "tty";
        StandardOutput = "tty";
        TTYPath = "/dev/tty1";
      };
    }
  );
}
