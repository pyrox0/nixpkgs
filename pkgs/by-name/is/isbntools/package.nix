{
  lib,
  python3Packages,
  fetchFromGitHub,
  nix-update-script,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "isbntools";
  version = "4.3.29";
  pyproject = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "xlcnd";
    repo = "isbntools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-s47y14YHL/ihAUCnneDcTlyVQj3rUgUnBLD2dPBGD/Y=";
  };

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    isbnlib
  ];

  pythonImportsCheck = [
    "isbntools"
  ];

  # All tests require internet, so we don't run them
  doCheck = false;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python app/framework for 'all things ISBN' including metadata, descriptions, covers";
    homepage = "https://github.com/xlcnd/isbntools";
    changelog = "https://github.com/xlcnd/isbntools/blob/${finalAttrs.src.rev}/CHANGES.txt";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ pyrox0 ];
  };
})
