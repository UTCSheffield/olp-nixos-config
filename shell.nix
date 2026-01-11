with import <nixpkgs> {};

let
    pam_oauth2_device = pkgs.callPackage ./programs/packages/pam_oauth2_device.nix {};
in
mkShell {
  buildInputs = [
    pam_oauth2_device
  ];
}
