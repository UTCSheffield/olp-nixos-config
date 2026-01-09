{
  lib,
  stdenv,
  runCommand,
  buildEnv,
  openscad,
  makeWrapper,
  writeTextFile,
  openscadExtensions ? [ ],
}:

let
  wrappedPkgVersion = lib.getVersion openscad;
  wrappedPkgName = lib.removeSuffix "-${wrappedPkgVersion}" openscad.name;
in

runCommand "${wrappedPkgName}-with-extensions-${wrappedPkgVersion}"
  {
    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [ openscad ];
    dontPatchELF = true;
    dontStrip = true;
    meta = openscad.meta;
  }
  (
    ''
        mkdir -p "$out/bin"
        mkdir -p "$out/share/applications"
        mkdir -p "$out/share/pixmaps"
        mkdir -p "$out/libraries"

        ln -sT "${openscad}/share/pixmaps/vs${openscad.meta.mainProgram}.png" "$out/share/pixmaps/vs${openscad.meta.mainProgram}.png"
        ln -sT "${openscad}/share/applications/${openscad.meta.mainProgram}.desktop" "$out/share/applications/${openscad.meta.mainProgram}.desktop"
        ln -sT "${openscad}/share/applications/${openscad.meta.mainProgram}-url-handler.desktop" "$out/share/applications/${openscad.meta.mainProgram}-url-handler.desktop"

        for ext in ${lib.concatStringsSep " " openscadExtensions}; do
            repoName=$(basename "$ext" | sed 's/^[^-]*-//')
            mkdir -p "$out/libraries/$repoName"
            cp -r "$ext/"* "$out/libraries/$repoName/"
        done

        makeWrapper "${openscad}/bin/${openscad.meta.mainProgram}" "$out/bin/${openscad.meta.mainProgram}" --set OPENSCADPATH="$out/libraries"
      ''
  )