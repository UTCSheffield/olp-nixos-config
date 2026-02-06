{
  pkgs,
  lib ? pkgs.lib,
  buildPythonPackage ? pkgs.python313Packages.buildPythonPackage,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  ...
}:

let
  deckar01-ratelimit = pkgs.callPackage ./deckar01-ratelimit.nix {};
in
buildPythonPackage rec {
  pname = "wordhoard";
  version = "1.5.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "johnbumgarner";
    repo = "wordhoard";
    rev = version;
    sha256 = "sha256-fj5GXmmH23Gpsnib4EegI9Nd4WU7oVKyoQZAMv2XIeg=";
  };

  build-system = with pkgs.python313Packages; [ setuptools ];

  propagatedBuildInputs = with pkgs.python313Packages; [
    deckar01-ratelimit
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
