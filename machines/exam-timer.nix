{ pkgs, ... }:

{
  imports = [
    ../hardware/generic.nix
  ];

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

  services.xserver.windowManager.openbox.enable = false;

  services.greetd = {
    enable = true;

    settings.default_session = {
      user = "kioskuser";
      command = "startx";
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

    # mirror all outputs to primary
    for out in $(xrandr | grep " connected" | cut -d" " -f1); do
      xrandr --output "$out" --auto
      if [ "$out" != "$PRIMARY" ]; then
        xrandr --output "$out" --same-as "$PRIMARY"
      fi
    done

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