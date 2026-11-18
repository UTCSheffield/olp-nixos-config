{ pkgs, lib, config, ... }:
{
    options.kiosk = {
        url = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "URL for kiosk to load";
        };
    };

    config = lib.mkIf (config.kiosk.url != "") {
        time.timeZone = "Europe/London";

        environment.systemPackages = with pkgs; [
            chromium
            openbox

            xorg.xorgserver
            xorg.xinit
            xorg.xrandr
            xorg.xset
        ];
        
        services.xserver.enable = true;

        services.xserver.displayManager.startx.enable = true;
        services.xserver.windowManager.openbox.enable = true;

        systemd.services.mirror = {
            path = with pkgs; [ xorg.xrandr ];
            description = "Mirror Screens";
            wantedBy = ["multi-user.target"];
            after = [ "display-manager.service" ];
            wants = [ "display-manager.service" ];
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
                OnCalendar = "*:*:00/15";
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
            # Log everything to a file and the X session output
            exec > >(tee -a /tmp/xinit-debug.log) 2>&1
        
            echo "===================================="
            echo " XINIT DEBUG START: $(date)"
            echo "===================================="
        
            echo "[DEBUG] Disabling screen blanking..."
            xset s off
            xset -dpms
            xset s noblank
        
            sleep 2
        
            echo "[DEBUG] Starting Openbox..."
            openbox-session &
            OPENBOX_PID=$!
        
            echo "[DEBUG] Openbox PID: $OPENBOX_PID"
            sleep 2
        
            echo "[DEBUG] Checking Openbox..."
            if kill -0 $OPENBOX_PID 2>/dev/null; then
                echo "[OK] Openbox is running"
            else
                echo "[ERROR] Openbox process has exited"
            fi
        
            echo "===================================="
            echo "[DEBUG] Launching Chromium..."
            echo "[DEBUG] URL: ${config.kiosk.url}"
            echo "===================================="
        
            chromium \
                --user-data-dir=/var/lib/chromium-kiosk \
                --app=${config.kiosk.url} \
                --incognito \
                --start-maximized \
                --no-first-run \
                --disable-pinch \
                --disable-infobars \
                --noerrdialogs \
                --disable-session-crashed-bubble \
                --ozone-platform=x11
        
            CHROMIUM_EXIT=$?
        
            echo ""
            echo "===================================="
            echo "[ERROR/EXIT] Chromium terminated"
            echo "[EXIT CODE] $CHROMIUM_EXIT"
            echo "[TIME] $(date)"
            echo "===================================="
        
            echo ""
            echo "[DEBUG] Log: /tmp/xinit-debug.log"
            echo ""
        '';

        users.users.kioskuser = {
            isNormalUser = true;
            home = "/home/kioskuser";
            extraGroups = [ "video" "input" ];
        };

        system.stateVersion = "25.11";
    };
}
