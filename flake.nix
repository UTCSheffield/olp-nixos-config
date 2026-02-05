{
  description = "OLP NixOS config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    himmelblau.url = "github:himmelblau-idm/himmelblau";
    himmelblau.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    { self, nixpkgs, home-manager, himmelblau, ... }@attrs:
    let
      eachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];

      packages = eachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          lib = pkgs.lib;
        in
        (import ./programs/packages { inherit pkgs; })
        // lib.optionalAttrs (system == "x86_64-linux") {
          iso = self.nixosConfigurations.iso.config.system.build.isoImage;
        }
        // lib.optionalAttrs (system == "aarch64-linux") {
          sdImage = self.nixosConfigurations.rpi.config.system.build.sdImage;
        }
      );
    in
    {
      nixosConfigurations = {
        makerlab = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [
            ./machines/MakerLab.nix
          ];
        };
        rpi = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = attrs;
          modules = [
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./machines/RaspberryPi.nix
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


      packages = packages;

      hydraJobs = self.packages;
    };
}
