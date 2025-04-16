{
  description = "OLP NixOS config";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    himmelblau.url = "github:himmelblau-idm/himmelblau/main";
    himmelblau.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, home-manager, himmelblau, ... }@attrs: {
    nixosModules.azureEntraId = {
          imports = [ himmelblau.nixosModules.himmelblau ];
          services.himmelblau = {
              enable = true;
              settings = {
                  domains = ["utcsheffield.org.uk"];
                  #pam_allow_groups = [ "ENTRA-GROUP-GUID-HERE" ];
                  local_groups = [ "wheel" "docker" ];
              };
          };
      };
    nixosConfigurations = {
      makerlab-3040 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = attrs;
        modules = [
          self.nixosModules.azureEntraId
          ./hardware/dell-3040.nix
          ./machines/makerlab-client.nix
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
   
