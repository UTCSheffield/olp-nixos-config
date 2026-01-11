{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ../hardware/generic.nix
    ../programs/cachix.nix
    ../programs/packages/pam_oauth2_device.nix
    ../programs/firefox.nix
    ../programs/vscode.nix
    ../programs/openscad.nix
    ../programs/python.nix
  ];

  users.users.makerlab = {
    description = "MakerLab";
    isNormalUser = true;
    extraGroups = [ "dialout" ];
    hashedPassword = "$y$j9T$EmEGlmnrC0GA5eactKvPR/$RxyEC85GvBOaTEodmuKFJUV0K/Stg9kdehfxsd7oxG9";
  };
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = "nix-command flakes";

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "uk";
    useXkbConfig = true;
  };

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    gh
  ];

  services.xserver.displayManager.lightdm.enable = false;
  services.desktopManager.plasma6.enable = true;
  services.xserver = {
    enable = true;
    xkb.layout = "gb";
  };

  services.dbus.enable = true;

  services.xserver.displayManager.startx.enable = true;

  environment.etc."profile.d/pam_oauth2_device.sh".text = ''
    XINITRC="$HOME/.xinitrc"
      cat > "$XINITRC" <<'EOF'
#!/bin/sh
exec startplasma-x11
EOF
    chmod 755 "$XINITRC"

    if [ -z "$DISPLAY " ] && [ "$(tty)" = "/dev/tty1" ]; then
      exec startx
    fi
  '';

  system.stateVersion = "25.11";
}
