{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ((pkgs.callPackage ./packages/vscode-with-extensions.nix {}).override {
      vscode = pkgs.vscode;
      vscodeExtensions = with pkgs.vscode-extensions; [
        # ── Python ───────────────────────────────────
        ms-python.python
        ms-python.vscode-pylance
        ms-toolsai.jupyter
        charliermarsh.ruff
        ms-python.black-formatter
        ms-python.isort

        # ── Testing ──────────────────────────────────
        hbenl.vscode-test-explorer
        ms-vscode.test-adapter-converter

        # ── Git / SCM ────────────────────────────────
        eamodio.gitlens
        github.vscode-github-actions

        # ── Editor QoL ───────────────────────────────
        streetsidesoftware.code-spell-checker
        christian-kohler.path-intellisense
        gruntfuggly.todo-tree
        formulahendry.code-runner
        usernamehw.errorlens

        # ── Formatting / Web ─────────────────────────
        esbenp.prettier-vscode
        dbaeumer.vscode-eslint
        ms-python.flake8
        humao.rest-client
        ritwickdey.liveserver

        # ── Markdown / Docs ──────────────────────────
        yzhang.markdown-all-in-one
        shd101wyy.markdown-preview-enhanced
        bierner.markdown-mermaid

        # ── Containers / Remote ──────────────────────
        ms-azuretools.vscode-docker
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-containers

        # ── Misc Nice-to-have ────────────────────────
        johnpapa.vscode-peacock
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "github-vscode-theme";
          publisher = "GitHub";
          version = "6.3.5";
          sha256 = "sha256-dOadoYBPcYrpzmqOpJwG+/nPwTfJtlsOFDU3FctdR0o=";
        }
      ];
    })
  ];
}
