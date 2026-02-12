{ self, config, pkgs, ... }:

{
  imports = [ ../update-tool ];

  services.update-tool.enable = true;
  services.update-tool.baseURL = "https://nixos-updates.archiesbytes.xyz";
}