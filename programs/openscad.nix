{ config, pkgs, ... }:

{  
  environment.systemPackages = [
    (pkgs.callPackage ./openscad-with-extensions.nix {
      extensions = [
        {
          owner = "BelfrySCAD";
          repo = "BOSL2";
          rev = "6ce86cd8a4a29a87444052dffb8704c2d90fd5a4";
          sha256 = "sha256-eO1DV/xrC2PuolSX4nM8t6B4F1hDQjjuqVH20hiUdh4=";
        }
      ];
    })
  ];
}
