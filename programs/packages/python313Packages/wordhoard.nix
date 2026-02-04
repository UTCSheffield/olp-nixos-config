{
  pkgs,
  lib ? pkgs.lib,
  buildPythonPackage ? pkgs.python313Packages.buildPythonPackage,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  setuptools ? pkgs.python313Packages.setuptools,
  ...
}:

buildPythonPackage rec {
  pname = "wordhoard";
  version = "1.5.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "johnbumgarner";
    repo = "wordhoard";
    rev = "${version}";
    hash = "sha256-3A1vYqIHFUiOH2cEx/XSOien3PmNpMAhLOe3T1yubx4=";
  };

  build-system = [ setuptools ];

  meta = {
    homepage = "https://github.com/johnbumgarner";
    description = "This Python module can be used to obtain antonyms, synonyms, hypernyms, hyponyms, homophones and definitions.";
    license = lib.licenses.mit;
  };
}
