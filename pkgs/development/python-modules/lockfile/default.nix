{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  pbr,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "lockfile";
  version = "0.12.2";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-au0C3gPLok76vNYAswVAFAY0/AbPpgOCLVCNU2Hp95k=";
  };

  # The __init__ method doesn't do anything relevant as far as I can tell
  # So we disable it, since it also makes pytest fail.
  postPatch = ''
    substituteInPlace test/compliancetest.py \
      --replace-fail "def setup" "def setUp" \
      --replace-fail "def teardown" "def tearDown" \
      --replace-fail "def __init__" "def init"
  '';

  build-system = [
    pbr
    setuptools
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  meta = {
    homepage = "https://launchpad.net/pylockfile";
    description = "Platform-independent advisory file locking capability for Python applications";
    license = lib.licenses.asl20;
  };
}
