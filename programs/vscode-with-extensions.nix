{
  lib,
  stdenv,
  runCommand,
  buildEnv,
  vscode,
  vscode-utils,
  makeWrapper,
  writeTextFile,
  vscodeExtensions ? [ ],
  jq
}:

let
  inherit (vscode) executableName longName;
  wrappedPkgVersion = lib.getVersion vscode;
  wrappedPkgName = lib.removeSuffix "-${wrappedPkgVersion}" vscode.name;

  extensionJsonFile = writeTextFile {
    name = "vscode-extensions-json";
    destination = "/share/vscode/extensions/extensions.json";
    text = vscode-utils.toExtensionJson vscodeExtensions;
  };

  combinedExtensionsDrv = buildEnv {
    name = "vscode-extensions";
    paths = vscodeExtensions ++ [ extensionJsonFile ];
  };

  wrapperScript = writeTextFile {
    name = "vscode-wrapper";
    text = ''
      #!/usr/bin/env bash
      # Loop over normal users
      for user in $(awk -F: '$3 >= 1000 && $3 < 60000 {print $1}' /etc/passwd); do
        home=$(getent passwd "$user" | cut -d: -f6)
        [ -d "$home" ] && [ -w "$home" ] || continue

        mkdir -p "$home/.vscode/extensions"
        for ext in ${combinedExtensionsDrv}/share/vscode/extensions/*; do
          name="$(basename "$ext")"
          ln -sfn "$ext" "$home/.vscode/extensions/$name"
        done

        user_json="$home/.vscode/extensions/extensions.json"
        system_json="${extensionJsonFile}/share/vscode/extensions/extensions.json"
        if [ ! -f "$user_json" ]; then
          cp "$system_json" "$user_json"
          continue
        fi
        
        tmpfile="$(mktemp)"
        jq -s '
          { recommendations:
            (.[0].recommendations + .[1].recommendations) | unique
          }
        ' "$system_json" "$user_json" > "$tmpfile"
        mv "$tmpfile" "$user_json" 
      done
    '';
  };

  extensionsFlag = ''
    --add-flags "--extensions-dir \$HOME/.vscode/extensions"
  '';
in

runCommand "${wrappedPkgName}-with-extensions-${wrappedPkgVersion}"
  {
    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [ vscode jq ];
    dontPatchELF = true;
    dontStrip = true;
    meta = vscode.meta;
  }
  ''
    mkdir -p "$out/bin"
    mkdir -p "$out/share/applications"
    mkdir -p "$out/share/pixmaps"

    ln -sT "${vscode}/share/pixmaps/vs${executableName}.png" "$out/share/pixmaps/vs${executableName}.png"
    ln -sT "${vscode}/share/applications/${executableName}.desktop" "$out/share/applications/${executableName}.desktop"
    ln -sT "${vscode}/share/applications/${executableName}-url-handler.desktop" "$out/share/applications/${executableName}-url-handler.desktop"

    makeWrapper "${vscode}/bin/${executableName}" "$out/bin/${executableName}" --run "bash ${wrapperScript}" ${extensionsFlag}

  ''