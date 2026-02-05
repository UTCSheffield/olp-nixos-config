{ pkgs,
  lib ? pkgs.lib,
  buildPythonPackage ? pkgs.python313Packages.buildPythonPackage,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  ...
}:

buildPythonPackage rec {
  pname = "deckar01-ratelimit";
  version = "3.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "deckar01";
    repo = "ratelimit";
    rev = version;
    sha256 = "sha256-2I0G2b6ngL2LEgtWruf2JNmvfAdOCAViqhZzxVdq4Nw=";
  };

  build-system = with pkgs.python313Packages; [ setuptools ];

  propagatedBuildInputs = with pkgs.python313Packages; [
    backoff
    beautifulsoup4
    certifi
    cloudscraper
    deepl
    idna
    lxml
    pyparsing
    requests
    requests-toolbelt
    soupsieve
    urllib3
  ];

  meta = {
    homepage = "https://github.com/johnbumgarner/wordhoard";
    description = "Python module to obtain antonyms, synonyms, hypernyms, hyponyms, homophones, and definitions.";
    license = lib.licenses.mit;
  };
}
