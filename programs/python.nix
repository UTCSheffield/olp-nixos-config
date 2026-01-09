{ config, pkgs, ... }:

{  
  environment.systemPackages = with pkgs; [
    (python313.withPackages (python-pkgs: with python-pkgs; [
      flake8
      rich
      typer
      click
      loguru
      python-dotenv
      tqdm
      humanize
      attrs
      pydantic

      # ── HTTP / Web ─────────────────────────────
      requests
      httpx
      aiohttp
      beautifulsoup4
      lxml

      # ── Data / Math ────────────────────────────
      numpy
      pandas
      scipy
      matplotlib
      seaborn
      tabulate
      sympy

      # ── Dev / Testing ──────────────────────────
      pytest
      pytest-cov
      hypothesis
      black
      ruff
      mypy
      pre-commit
      tox

      # ── Serialization / Formats ────────────────
      pyyaml
      tomli
      toml
      orjson
      msgpack
      jsonschema
      openpyxl
      pillow

      # ── System / Utils ─────────────────────────
      psutil
      watchdog

      # ── GUI ────────────────────────────────────
      tkinter
    ]))
  ];
}
