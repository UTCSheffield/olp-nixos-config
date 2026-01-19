{ himmelblau, ... }:

{
    imports = [ himmelblau.nixosModules.himmelblau ];
    services.himmelblau = {
        enable = true;
        settings = {
            oidc_issuer_url="tbc";
            app_id="tbc";
            shell = "/run/current-system/sw/bin/bash";
        };
    };
}