{ pkgs, python313 ? pkgs.python313, ... }:

let
    solidpython2 = import ./packages/python313Packages/solidpython2.nix { inherit pkgs; };
    wordhoard = import ./packages/python313Packages/wordhoard.nix { inherit pkgs; };
in
python313.withPackages (python-pkgs: with python-pkgs; [
    solidpython2

    pygame
    colorama
    rich
    art
    pyfiglet
    faker
    wordhoard
    emoji

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
