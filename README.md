# School Nixos Config

## How to

Boot a minimal NixOS https://nixos.org/download/#nixos-iso

```bash
curl -s -L https://tinyurl.com/olpnixos  | sudo bash -
sudo ./setup.sh
```

## TODO
* ~~Install VSCode extensions while allowing new extensions to be installed~~

## Building
```bash
nix build .#nixosConfigurations.makerlab.config.system.build.toplevel \
  --print-build-logs
```
```bash
nix build .#nixosConfigurations.iso.config.system.build.isoImage \
  --print-build-logs
```