{ pkgs, ... }:

{
  hardware.graphics.enable = true;

  services.cage = {
    enable = true;
    user = "kioskuser";
    program = "${pkgs.chromium}/bin/chromium --kiosk https://utcsheffield.github.io/UTC-Exam-Timer-2/web/timer.html";
  };

  users.users.kioskuser = {
    isNormalUser = true;
    home = "/home/kioskuser";
  };

  services.getty.autologinUser = "kioskuser";
}
