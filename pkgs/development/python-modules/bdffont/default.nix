{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  pytestCheckHook,
  nix-update-script,
  hatchling,
}:

buildPythonPackage rec {
  pname = "bdffont";
  version = "0.0.27";
  pyproject = true;

  disabled = pythonOlder "3.10";

  src = fetchPypi {
    pname = "bdffont";
    inherit version;
    hash = "sha256-1sYjiCklQ2gfQQIZcZ/Fk27XBzRrbZEY+1JNaJ/8LTs=";
  };

  build-system = [ hatchling ];

  nativeCheckInputs = [ pytestCheckHook ];

  pythonImportsCheck = [ "bdffont" ];

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/TakWolf/bdffont";
    description = "A library for manipulating Glyph Bitmap Distribution Format (BDF) Fonts";
    platforms = lib.platforms.all;
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      TakWolf
      h7x4
    ];
  };
}
