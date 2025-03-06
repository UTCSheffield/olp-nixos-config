{ pkgs, lib, buildPythonPackage, fetchFromGithub, withOpenSCAD ? false }:

buildPythonPackage rec {
  pname = "solidpython2";
  version = "2.1.0";
  pyproject = true;
  src = fetchFromGitHub {
    owner = "jeff-dh";
    repo = "SolidPython";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-Tq3hrsC2MmueCqChk6mY/u/pCjF/pFuU2o3K+qw7ImY=";
  };

  # patches = [ ./difftool_tests.patch ];

  propagatedBuildInputs = lib.optionals withOpenSCAD [ pkgs.openscad ];

  build-system = [
    pkgs.poetry-core
  ];

  dependencies = [
    pkgs.ply
    pkgs.setuptools
  ];

  pythonImportsCheck = [ "solid2" ];
  checkPhase = ''
    runHook preCheck
    python $TMPDIR/source/tests/run_tests.py
    runHook postCheck
  '';

  meta = with lib; {
    homepage = "https://github.com/jeff-dh/SolidPython";
    description = "A python frontend for solid modelling that compiles to OpenSCAD";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ jonboh ];
  };
}
