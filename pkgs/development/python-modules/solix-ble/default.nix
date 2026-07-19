{ fetchFromGitHub, pkgs }:

pkgs.python3Packages.buildPythonPackage rec {
  pname = "SolixBLE";
  version = "3.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "flip-dots";
    repo = pname;
    tag = "v${version}";
    hash = "";
  };

  build-system = [ pkgs.python3Packages.setuptools ];

  pythonImportsCheck = [
  ];
}
