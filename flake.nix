{
  description = "OLP NixOS config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@attrs:
    {
      nixosConfigurations = {
        makerlab = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [
            ./machines/MakerLab.nix
          ];
        };
        iso = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-base.nix"
            ./machines/iso.nix
          ];
        };
        packages.x86_64-linux.iso =
          self.nixosConfigurations.iso.config.system.build.isoImage;
      };
    };
}

