{ pkgs, ... }:

{
  imports = [
    ../programs/update-tool.nix
    ../hardware/generic.nix
  ];

  environment.systemPackages = with pkgs; [
    git
  ];
  
  networking.networkmanager.enable = true;

  services.cage = {
    enable = true;
    user = "kioskuser";
    program = ''
      ${pkgs.chromium}/bin/chromium \
        --app=https://utcsheffield.github.io/UTC-Exam-Timer-2/web/timer.html \
        --start-fullscreen \
        --no-first-run \
        --incognito \
        --disable-pinch
    '';
  };

  users.users.kioskuser = {
    isNormalUser = true;
    home = "/home/kioskuser";
  };

  system.stateVersion = "25.11";
}
