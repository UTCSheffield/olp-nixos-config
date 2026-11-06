# School Nixos Config

## How to

Boot a minimal NixOS https://nixos.org/download/#nixos-iso

```bash
curl -s -L https://tinyurl.com/olpnixos  | sudo bash -
sudo ./setup.sh
```

# Updating
```bash
cd /etc/nixos
nixos-rebuild switch --flake .#config-name
```

# Switching Config
```bash
cd /etc/nixos
nano system.conf
```
* Edit Config Name
```bash
nixos-rebuild switch --flake .#new-config
```

# TODO
* Auth0 authentication (Himmelblau?)

## Building
```bash
nix build .#nixosConfigurations.makerlab.config.system.build.toplevel \
  --print-build-logs
```
```bash
nix build .#nixosConfigurations.iso.config.system.build.isoImage \
  --print-build-logs
```
