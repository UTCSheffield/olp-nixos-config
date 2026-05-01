{ pkgs, lib, config, ... }:
{
    options.kiosk = {
        enable = lib.mkEnableOption "Enable kiosk service";

        url = lib.mkOption {
            type = lib.types.str;
            default = "https://google.com";
            description = "URL for kiosk to load";
        };
    };

    config = lib.mkIf config.kiosk.enable {
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
            path = with pkgs; [ xorg.xrandr ];
            description = "Mirror Screens";
            wantedBy = ["multi-user.target"];
            requires = ["greetd.service"];
            script = ''
            export DISPLAY=:0
            PRIMARY=$(xrandr | grep " connected" | cut -d" " -f1 | head -n1)
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

            # launch Chromium in APP MODE (NOT kiosk)
            chromium \
            --app=${config.kiosk.url} \
            --incognito \
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
    };
}