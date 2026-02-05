{
  pkgs,
  lib,
  stdenv,
  runCommand,
  buildEnv,
  vscode,
  vscode-utils,
  jq,
  makeWrapper,
  writeTextFile,
  vscodeExtensions ? [ ],
}:

let
  inherit (vscode) executableName longName;
  wrappedPkgVersion = lib.getVersion vscode;
  wrappedPkgName = lib.removeSuffix "-${wrappedPkgVersion}" vscode.name;
  
  extensions = vscodeExtensions ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "github-vscode-theme";
          publisher = "GitHub";
          version = "6.3.5";
          sha256 = "sha256-dOadoYBPcYrpzmqOpJwG+/nPwTfJtlsOFDU3FctdR0o=";
        }
      ];

  extensionJsonFile = writeTextFile {
    name = "vscode-extensions-json";
    destination = "/share/vscode/extensions/extensions.json";
    text = vscode-utils.toExtensionJson extensions;
  };

  combinedExtensionsDrv = buildEnv {
    name = "vscode-extensions";
    paths = extensions ++ [ extensionJsonFile ];
  };
  
  pythonEnv = import ./python-env.nix { inherit pkgs; };

  wrapperScript = writeTextFile {
    name = "vscode-wrapper";
    text = ''
      #!/usr/bin/env bash
      set -e

      HOME_DIR="$HOME"
      [ -d "$HOME_DIR" ] || exit 0

      PYTHON="${pythonEnv}/bin/python3.13"

      # Get site-packages of the pythonEnv
      EXTRA_PATHS="$($PYTHON - <<'EOF'
import site, json
print(json.dumps(site.getsitepackages()))
EOF
)"

      # ── Extensions ─────────────────────────────
      mkdir -p "$HOME_DIR/.vscode/extensions"
      for ext in ${combinedExtensionsDrv}/share/vscode/extensions/*; do
        name="$(basename "$ext")"
        [ "$name" = "extensions.json" ] && continue
        ln -sfn "$ext" "$HOME_DIR/.vscode/extensions/$name"
      done

      # ── VS Code Settings (Pylance) ─────────────
      SETTINGS_DIR="$HOME_DIR/.config/Code/User"
      SETTINGS_FILE="$SETTINGS_DIR/settings.json"
      mkdir -p "$SETTINGS_DIR"

      if [ ! -f "$SETTINGS_FILE" ]; then
        cat > "$SETTINGS_FILE" <<EOF
{
  "workbench.colorTheme": "GitHub Dark",
  "python.defaultInterpreterPath": "$PYTHON",
  "python.analysis.extraPaths": $EXTRA_PATHS,
  "python.analysis.autoImportCompletions": true,
  "python.analysis.typeCheckingMode": "basic"
}
EOF
      else
        ${jq}/bin/jq \
          --arg interp "$PYTHON" \
          --argjson paths "$EXTRA_PATHS" \
          '.["python.defaultInterpreterPath"]=$interp
           | .["python.analysis.extraPaths"]=$paths' \
          "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp" \
          && mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
      fi
    '';
  };


  extensionsFlag = ''
    --add-flags "--extensions-dir \$HOME/.vscode/extensions"
  '';
in

runCommand "${wrappedPkgName}-with-extensions-${wrappedPkgVersion}"
  {
    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [ vscode ];
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