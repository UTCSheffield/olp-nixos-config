{
  description = "OLP NixOS config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    himmelblau.url = "github:iLikeToCode/himmelblau/oidc_fix";
    himmelblau.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    { self, nixpkgs, home-manager, himmelblau, ... }@attrs:
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
      };
    };
}
