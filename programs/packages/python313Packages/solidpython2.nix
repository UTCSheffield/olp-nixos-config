{
  pkgs,
  lib ? pkgs.lib,
  openscad ? pkgs.openscad,
  buildPythonPackage ? pkgs.python313Packages.buildPythonPackage,
  fetchFromGitHub ? pkgs.fetchFromGitHub,
  poetry-core ? pkgs.python313Packages.poetry-core,
  ply ? pkgs.python313Packages.ply,
  setuptools ? pkgs.python313Packages.setuptools,
  ...
}:

buildPythonPackage rec {
  pname = "solidpython2";
  version = "2.1.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "jeff-dh";
    repo = "SolidPython";
    rev = "v${version}";
    hash = "sha256-3A1vYqIHFUiOH2cEx/XSOien3PmNpMAhLOe3T1yubx4=";
  };

  bosl = fetchFromGitHub {
    owner = "BelfrySCAD";
    repo = "BOSL2";
    rev = "84de8a307068420f50c396d9c5363b4413db1c4f";
    hash = "sha256-Hvz4w1h/cMgy7hmGZq2YvmnOrALQG7BjIRk3kdJzOT8=";
  };

  postPatch = ''
    mkdir -p solid2/extensions/bosl2/BOSL2
    cp -r ${bosl}/* solid2/extensions/bosl2/BOSL2/
  '';

  build-system = [ poetry-core ];
  dependencies = [ ply setuptools ];

  buildInputs = [ openscad ];

  pythonImportsCheck = [ "solid2" ];
  
  meta = {
    homepage = "https://github.com/jeff-dh/SolidPython";
    description = "Python frontend for solid modelling that compiles to OpenSCAD";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ jonboh ];
  };
}
