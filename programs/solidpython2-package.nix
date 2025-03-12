{ pkgs, lib, withOpenSCAD ? false }:

let
  solidPythonRepo = pkgs.fetchFromGitHub {
    owner = "jeff-dh";
    repo = "SolidPython";
    rev = "v2.1.1";
    fetchSubmodules = true;
    hash = "sha256-Tq3hrsC2MmueCqChk6mY/u/pCjF/pFuU2o3K+qw7ImY=";
  };
 
  bosl2Repo = pkgs.fetchFromGitHub {
    owner = "your-owner";  # Replace with the actual owner of BOSL2
    repo = "BOSL2";
    rev = "main";  # Replace with the desired branch, tag, or commit hash
    fetchSubmodules = true;
    hash = "";  # Replace with the actual hash
  };
 
in pkgs.python3Packages.buildPythonPackage rec {
  pname = "solidpython2";
  version = "2.1.1";
  pyproject = true;
  src = solidPythonRepo;

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

  buildPhase = ''
    # Call the default build phase
    runHook preBuild
 
    # Create the extensions directory and move BOSL2 into it
    mkdir -p $out/extension/bosl2
    cp -r ${bosl2Repo} $out/extension/bosl2/
 
    # Call the default build phase again
    runHook postBuild
  '';

  meta = with lib; {
    homepage = "https://github.com/jeff-dh/SolidPython";
    description = "A python frontend for solid modelling that compiles to OpenSCAD";
    license = licenses.lgpl2Plus;
    maintainers = with maintainers; [ jonboh ];
  };
}
