{
  description = "OLP NixOS config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs =
    { self, nixpkgs, home-manager, ... }@attrs:
    let
      eachSystem = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ];

      nixosConfigsForSystem = system:
        nixpkgs.lib.mapAttrs
          (_: cfg: cfg.config.system.build.toplevel)
          (nixpkgs.lib.filterAttrs
            (_: cfg: cfg.pkgs.stdenv.hostPlatform.system == system)
            self.nixosConfigurations);
    in
    {
      nixosConfigurations = {
        makerlab = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [
            ./machines/MakerLab.nix
          ];
        };
        makerlab-us = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [
            ./machines/MakerLab.nix
            ({ lib, ... }:
            {
              console.keyMap = lib.mkForce "us";
              services.xserver.xkb.layout = lib.mkForce "us";
            })
          ];
        };
        exam-timer = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [
            ./machines/exam-timer.nix
          ];
        };
        kiosk = nixpkgs.lib.nixosSystem rec {
          system = "x86_64-linux";
          specialArgs = attrs;
          modules = [
            ./machines/kiosk.nix
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

      legacyPackages = eachSystem (system:
        import ./. {
          pkgs = import nixpkgs {
            inherit system;
          };
          lib = nixpkgs.lib;
          flat = false;
        }
      );

      packages = eachSystem (system:
        import ./. {
          pkgs = import nixpkgs {
            inherit system;
          };
          lib = nixpkgs.lib;
          flat = true;
        }
      );

      hydraJobs = {
        packages = self.packages;
        configs = eachSystem (system:
          nixosConfigsForSystem system
        );
        images = eachSystem (system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            lib = pkgs.lib;
          in
          lib.optionalAttrs (system == "x86_64-linux") {
            iso = self.nixosConfigurations.iso.config.system.build.isoImage;
          }
        );
      };
    };
}
