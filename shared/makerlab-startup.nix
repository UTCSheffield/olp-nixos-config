{ config, lib, pkgs, ... }:

let
  fetchScript = pkgs.writeShellScriptBin "fetch-update-script" ''
    set -e
    SCRIPT_URL="https://your-script-url.com/update.sh"
    TMP_SCRIPT="$(mktemp)"
    curl -fsSL "$SCRIPT_URL" -o "$TMP_SCRIPT"
    chmod +x "$TMP_SCRIPT"
    "$TMP_SCRIPT"
    rm -f "$TMP_SCRIPT"
  '';
in
{
  environment.systemPackages = [ fetchScript ];

  systemd.services.updateScript = {
    description = "Fetch and run update script";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${fetchScript}/bin/fetch-update-script";
      User = "root";
      StandardOutput = "journal";
      StandardError = "journal";
      ProtectSystem = "false";
    };
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    requires = [ "network.target" ];
  };
}
