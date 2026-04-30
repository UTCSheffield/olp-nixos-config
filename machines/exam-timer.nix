{ pkgs, ... }:

{
  imports = [
    ../hardware/generic.nix
    ../programs/update-tool.nix
  ];

  time.timeZone = "Europe/London";

  environment.systemPackages = with pkgs; [
    chromium
    openbox

    xorg.xorgserver
    xorg.xinit
    xorg.xrandr
    xorg.xset
  ];

  networking.networkmanager.enable = true;

  services.xserver.enable = true;

  services.xserver.displayManager.startx.enable = true;
  services.xserver.windowManager.openbox.enable = true;

  systemd.services.mirror = {
    description = "Mirror Screens";
    wantedBy = ["multi-user.target"];
    requires = ["greetd.service"];
    script = ''
      for out in $(xrandr | grep " connected" | cut -d" " -f1); do
        xrandr --output "$out" --auto --scale-from 1920x1080
        if [ "$out" != "$PRIMARY" ]; then
          xrandr --output "$out" --same-as "$PRIMARY" --scale-from 1920x1080
        fi
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "kioskuser";
    };
  };

  systemd.timers.mirror = {
    description = "Mirror Screens Timer";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*:*:00/5";
      AccuracySec = "1";
    };
  };

  services.greetd = {
    enable = true;

    settings.default_session = {
      user = "kioskuser";
      command = "startx -- :0 vt1";
    };
  };

  environment.etc."xdg/openbox/rc.xml".text = ''
  <openbox_config>
    <applications>
      <application class="*">
        <decor>no</decor>
        <maximized>yes</maximized>
      </application>
    </applications>
  </openbox_config>
  '';

  environment.etc."X11/xinit/xinitrc".text = ''
    xset s off
    xset -dpms
    xset s noblank

    sleep 2

    # start window manager FIRST
    openbox-session &
    sleep 2

    # detect primary output
    PRIMARY=$(xrandr | grep " connected" | cut -d" " -f1 | head -n1)

    # launch Chromium in APP MODE (NOT kiosk)
    chromium \
    --app=https://utcsheffield.github.io/UTC-Exam-Timer-2/web/timer.html \
    --start-maximized \
    --no-first-run \
    --disable-pinch \
    --disable-infobars \
    --noerrdialogs \
    --disable-session-crashed-bubble \
    --ozone-platform=x11
  '';

  users.users.kioskuser = {
    isNormalUser = true;
    home = "/home/kioskuser";
  };

  system.stateVersion = "25.11";
}