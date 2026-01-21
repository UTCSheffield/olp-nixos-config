{ himmelblau, ... }:

{
    imports = [ himmelblau.nixosModules.himmelblau ];
    services.himmelblau = {
        enable = true;
        settings = {
            oidc_issuer_url="https://dev-a66o74ww13tx0ori.uk.auth0.com/";
            app_id="ucjoleQifb1ifdCYLXeojZqcwgx7BzFF";
            shell = "/run/current-system/sw/bin/bash";
        };
    };
}
