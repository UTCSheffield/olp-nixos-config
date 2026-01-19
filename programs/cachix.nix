{
  config,
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    cachix
  ];
  nix = {
    settings = {
      substituters = [
        "https://utcsheffield.cachix.org"
        "https://himmelblau.cachix.org"
      ];
      trusted-public-keys = [
        "utcsheffield.cachix.org-1:JlnNbGhsj00NjGND1yb6SHRoM6JO2HjgrbhpqwAp8xo="
        "himmelblau.cachix.org-1:yu8mq/NIBYsZHWzo4SOge97gpf02qugdZFT/JdRkswc="
      ];
    };
  };
}
