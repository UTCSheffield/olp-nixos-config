{ config, pkgs, ... }:

{
  imports = [
    ./openscad-with-extensions.nix
  ];
  
  environment.systemPackages = [
    (import ./openscad-with-extensions.nix {
      inherit pkgs;
      extensions = [
        {
          owner = "BelfrySCAD";
          repo = "BOSL2";
          rev = "6ce86cd8a4a29a87444052dffb8704c2d90fd5a4";
          sha256 = "0000000000000000000000000000000000000000000000000000";
          name = "BOSL2";
        }
      ];
    })
  ]
}
