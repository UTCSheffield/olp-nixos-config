{lib, ...}:
let himmelblau = builtins.getFlake "github:himmelblau-idm/himmelblau/0.9.0";
in {
    imports = [ himmelblau.nixosModules.himmelblau ];

    services.himmelblau.enable = true;
    services.himmelblau.settings = {
        domains = ["utcsheffield.org.uk"];
      #  pam_allow_groups = [ "ENTRA-GROUP-GUID-HERE" ];
        local_groups = [ "wheel" "docker" ];
    };
}
