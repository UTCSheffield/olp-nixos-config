{ self, config, pkgs, ... }:

{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      ncurses5
      stdenv.cc.cc.lib
    ];
  };

  environment.systemPackages = with pkgs; [
    ((pkgs.callPackage ./vscode-with-extensions.nix { inherit self; }).override {
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
        christian-kohler.path-intellisense
        gruntfuggly.todo-tree
        formulahendry.code-runner
        usernamehw.errorlens

        # ── Formatting / Web ─────────────────────────
        esbenp.prettier-vscode
        dbaeumer.vscode-eslint
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
          name = "vexcode";
          publisher = "VEXRobotics";
          version = "0.8.2026020401";
          sha256 = "5hyFx6tTrBJ9dY/fUjkBja9S+i6Tksz3fPCdtT0qDqU=";
        }
        {
          name = "vexfeedback";
          publisher = "VEXRobotics";
          version = "0.2.9";
          sha256 = "0HwkH/ryPhV04zB3wxZ7uSV5ZPJBX4d3KcdsyWdukeE=";
        }
      ];
    })
  ];
}
