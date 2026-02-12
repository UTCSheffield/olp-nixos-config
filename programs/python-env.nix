{ self, pkgs, python313 ? pkgs.python313, ... }:

let
    pythonPkgs = self.legacyPackages.${pkgs.stdenv.hostPlatform.system}.python313Packages;
in
python313.withPackages (python-pkgs: with python-pkgs // pythonPkgs; [
    solidpython2
    wordhoard

    jedi

    pygame-ce
    colorama
    rich
    art
    pyfiglet
    faker
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
