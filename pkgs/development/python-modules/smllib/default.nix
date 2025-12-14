{
  lib,

  buildPythonPackage,
  fetchFromGitHub,

  setuptools,
}:

buildPythonPackage rec {
  pname = "smllib";
  version = "1.7";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "spacemanspiff2007";
    repo = pname;
    tag = version;
    hash = "sha256-jf9AFjt9xDg4DFYzdoL7rQdo/WdkM4km8fDdzVfbN5E=";
  };

  build-system = [ setuptools ];

  pythonImportsCheck = [
    "smllib"
  ];

  meta = {
    description = "Library to parse SML byte streams";
    homepage = "https://github.com/spacemanspiff2007/SmlLib";
    changelog = "https://github.com/spacemanspiff2007/SmlLib/releases/tag/${version}";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ hensoko ];
    platforms = lib.platforms.linux;
  };
}
