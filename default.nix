{ pkgs, lib ? pkgs.lib, flat ? false, ... }:

let
  readPackages = dir: prefix:
    let
      entries = builtins.readDir ./${dir};

      # Top-level .nix files → name -> derivation
      files = lib.mapAttrs'
        (name: _: {
            name = let base = lib.removeSuffix ".nix" name; in
                   if flat && prefix != "" then prefix + "-" + base else base;
            value = pkgs.callPackage (./${dir}/${name}) { inherit pkgs; };
        })
        (lib.filterAttrs (name: _: lib.hasSuffix ".nix" name && !lib.hasPrefix "default" name) entries);

      # Subdirectories → recursive packages
      subdirsRaw = lib.mapAttrs
        (name: _: readPackages (dir + "/" + name) (if flat && prefix != "" then prefix + "-" + name else name))
        (lib.filterAttrs (name: type: type == "directory") entries);

      # Merge subdirs
      subdirs = if flat then
                  # Flatten: merge all subdir packages into top-level
                  lib.foldl' (acc: v: acc // v) {} (lib.attrValues subdirsRaw)
                else
                  subdirsRaw;

    in
      files // subdirs;

in
# Start recursion with empty prefix
readPackages "./programs/packages" ""
