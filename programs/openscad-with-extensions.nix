{ pkgs, extensions ? [] }:

let
  fetchedExtensions = map (ext: {
    name = ext.name;
    path = pkgs.fetchFromGitHub {
      inherit (ext) owner repo rev sha256;
    };
  }) extensions;
in pkgs.runCommand "openscad-with-extensions" {
  nativeBuildInputs = [ pkgs.makeWrapper ];
  buildInputs = [ pkgs.openscad ];
  dontPatchELF = true;
  dontStrip = true;
} ''
  mkdir -p $out/bin $out/libraries $out/share/pixmaps $out/share/applications

  # link icons and desktop files
  ln -sT ${pkgs.openscad}/share/pixmaps/vs${pkgs.openscad.meta.mainProgram}.png $out/share/pixmaps/vs${pkgs.openscad.meta.mainProgram}.png
  ln -sT ${pkgs.openscad}/share/applications/${pkgs.openscad.meta.mainProgram}.desktop $out/share/applications/${pkgs.openscad.meta.mainProgram}.desktop
  ln -sT ${pkgs.openscad}/share/applications/${pkgs.openscad.meta.mainProgram}-url-handler.desktop $out/share/applications/${pkgs.openscad.meta.mainProgram}-url-handler.desktop

  # copy extensions
  ${pkgs.lib.concatMapStringsSep "\n" (ext: ''
    mkdir -p "$out/libraries/${ext.name}"
    cp -r "${ext.path}/"* "$out/libraries/${ext.name}/"
  '') fetchedExtensions}

  # wrap OpenSCAD binary
  ${pkgs.makeWrapper} ${pkgs.openscad}/bin/${pkgs.openscad.meta.mainProgram} \
    $out/bin/${pkgs.openscad.meta.mainProgram} --set OPENSCADPATH $out/libraries
''
