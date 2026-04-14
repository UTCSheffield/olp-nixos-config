{ pkgs,
  lib ? pkgs.lib,
  buildPythonPackage ? pkgs.python313Packages.buildPythonPackage,
  fetchPypi ? pkgs.python313Packages.fetchPypi,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  ...
}:

buildPythonPackage rec {
  pname = "streamlit_stl";
  version = "0.0.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-PZj+DyuS0ks+5p3dVI/HH2wskXX4vKiht47tMjD2c1c=";
  };

  format = "setuptools";

  build-system = with pkgs.python313Packages; [ setuptools ];

  meta = {
    homepage = "https://github.com/Lucandia/streamlit_stl";
    description = "A Streamlit component to display STL files ";
    license = lib.licenses.gpl3;
  };
}
