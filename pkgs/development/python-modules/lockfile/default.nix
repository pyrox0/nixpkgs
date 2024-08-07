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
    sha256 = "6aed02de03cba24efabcd600b30540140634fc06cfa603822d508d5361e9f799";
  };

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

  meta = with lib; {
    homepage = "https://launchpad.net/pylockfile";
    description = "Platform-independent advisory file locking capability for Python applications";
    license = licenses.asl20;
  };
}
