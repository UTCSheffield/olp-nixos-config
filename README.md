# School Nixos Config


## Need to implement:
- ### Flakes
- ### Config Sync/Auto upgrade
- ### SMB Shares
- ### Active Directory Login
## Configs:
### AD
```nix
{ config, pkgs, ... }:

{
  # Install SSSD package
  environment.systemPackages = with pkgs; [
    sssd
  ];

  # Enable and configure SSSD for AD
  services.sssd = {
    enable = true;
    config = {
      # SSSD domains and configuration
      domains = [ "ad.example.com" ];
      
      # SSSD configuration
      services = "nss, pam";

      # AD domain configuration
      domains."ad.example.com" = {
        id_provider = "ad";
        access_provider = "ad";
        ad_domain = "ad.example.com";
        krb5_realm = "AD.EXAMPLE.COM";
        realmd_tags = "manages-system joined-with-samba";

        # Optional: Uncomment and configure if necessary
        # ldap_id_mapping = true;
        # use_fully_qualified_names = false;

        # Optional: Configuration for advanced scenarios
        # ad_hostname = "hostname.ad.example.com";
        # ad_server = "dc.ad.example.com";
        # ad_backup_server = "backupdc.ad.example.com";
        # ad_gpo_access_control = "enforcing";
      };
    };
  };

  # Configure PAM to use SSSD
  services.pam.services.sssd = {
    enable = true;
  };

  # Enable NSS module for SSSD
  networking.nsswitch = {
    passwd = [ "files" "sss" ];
    group = [ "files" "sss" ];
    shadow = [ "files" "sss" ];
  };

  # Kerberos configuration
  networking.kerberos = {
    enable = true;
    realms = {
      "AD.EXAMPLE.COM" = {
        kdc = "dc.ad.example.com";
        admin_server = "dc.ad.example.com";
      };
    };
  };
}
```
