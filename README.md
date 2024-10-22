# School Nixos Config

## How to

Boot a minimal NixOS https://nixos.org/download/#nixos-iso

```bash
curl -s -L https://tinyurl.com/olpnixos  | sudo bash -
sudo ./setup.sh
```

or build iso in this repo

```bash
nix build .#nixosConfigurations.iso.config.system.build.isoImage --experimental-features "nix-command flakes"
```

then boot the outputted iso and run 

```bash
sudo /etc/setup.sh
```


## Need to implement:
- ### Flakes : Done
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
      domains = [ "sutc.internal" ];
      
      # SSSD configuration
      services = "nss, pam";

      # AD domain configuration
      domains."sutc.internal" = {
        id_provider = "ad";
        access_provider = "ad";
        ad_domain = "sutc.internal";
        krb5_realm = "SUTC.INTERNAL";
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
      "SUTC.INTERNAL" = {
        kdc = "sutc.internal";
        admin_server = "sutc.internal";
      };
    };
  };
}
```
