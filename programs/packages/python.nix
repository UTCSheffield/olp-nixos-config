{ pkgs, ... }:

let
    utc-solidpython2 = pkgs.callPackage ./solidpython2.nix {};
in
pkgs.python313.withPackages (python-pkgs: with python-pkgs; [
    utc-solidpython2

    pygame

    # ── QOL ────────────────────────────────────
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
])
