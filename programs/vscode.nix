{
  config,
  pkgs,
  lib,
  ...
}:
let
  normalUsers = lib.attrNames (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
in
{
  options = {
    vscode.extensions = lib.mkOption { default = [ ]; };
    vscode.user = lib.mkOption { };
  };

  config = {
    environment.systemPackages = [ pkgs.vscode ];

    system.activationScripts.fix-vscode-extensions.text = ''
      for user in ${lib.concatStringsSep " " normalUsers}; do
          HOME_DIR=$(getent passwd "$user" | cut -d: -f6)
          EXT_DIR="$HOME_DIR/.vscode/extensions"

          mkdir -p "$EXT_DIR"
          chown "$user:users" "$EXT_DIR"

          for ext in ${lib.concatMapStringsSep " " toString config.vscode.extensions}; do
          ln -sf "$ext/share/vscode/extensions/"* "$EXT_DIR/"
          done

          chown -R "$user:users" "$EXT_DIR"
      done
    '';
  };
}
