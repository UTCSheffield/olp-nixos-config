{ config, pkgs, ... }:

{  
  imports = [
    ./vscode-with-extensions.nix
  ];

  vscode.extensions = [
  # ── VEX Robotics ─────────────────────────────
  "VEXRobotics.vexcode"
  "VEXRobotics.vexfeedback"

  # ── Python ───────────────────────────────────
  "ms-python.python"
  "ms-python.vscode-pylance"
  "ms-toolsai.jupyter"
  "magicstack.MagicPython"
  "charliermarsh.ruff"
  "ms-python.black-formatter"
  "ms-python.isort"

  # ── Testing ──────────────────────────────────
  "hbenl.vscode-test-explorer"
  "ms-vscode.test-adapter-converter"
  "littlefoxteam.vscode-python-test-adapter"

  # ── Git / SCM ────────────────────────────────
  "eamodio.gitlens"
  "github.vscode-github-actions"

  # ── Editor QoL ───────────────────────────────
  "streetsidesoftware.code-spell-checker"
  "christian-kohler.path-intellisense"
  "gruntfuggly.todo-tree"
  "alefragnani.Bookmarks"
  "wayou.vscode-todo-highlight"
  "formulahendry.code-runner"
  "usernamehw.errorlens"

  # ── Formatting / Web ─────────────────────────
  "esbenp.prettier-vscode"
  "dbaeumer.vscode-eslint"
  "ms-python.flake8"
  "humao.rest-client"
  "ritwickdey.LiveServer"

  # ── Markdown / Docs ──────────────────────────
  "yzhang.markdown-all-in-one"
  "shd101wyy.markdown-preview-enhanced"
  "bierner.markdown-mermaid"

  # ── Containers / Remote ──────────────────────
  "ms-azuretools.vscode-docker"
  "ms-vscode-remote.remote-ssh"
  "ms-vscode-remote.remote-containers"

  # ── GitHub Theme ─────────────────────────────
  "GitHub.github-vscode-theme"

  # ── Misc Nice-to-have ────────────────────────
  "johnpapa.vscode-peacock"
  ];
}
