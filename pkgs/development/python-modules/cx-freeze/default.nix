{
  lib,
  buildPythonPackage,
  fetchPypi,
  pythonOlder,
  ncurses,
  setuptools,
  distutils,
  filelock,
  typing-extensions,
  wheel,
  patchelf,
}:

buildPythonPackage rec {
  pname = "cx-freeze";
  version = "7.2.0";
  pyproject = true;

  disabled = pythonOlder "3.8";

  src = fetchPypi {
    pname = "cx_freeze";
    inherit version;
    hash = "sha256-xX9xAbTTUTJGSx7IjLiUjDt8W07OS7NUwWCRWJyzNYM=";
  };

  pythonRelaxDeps = [
    "setuptools"
    "wheel"
  ];

  build-system = [
    setuptools
    distutils
    wheel
  ];

  buildInputs = [ ncurses ];

  dependencies = [
    filelock
    setuptools
    distutils
  ] ++ lib.optionals (pythonOlder "3.10") [ typing-extensions ];

  postPatch = ''
    sed -i /patchelf/d pyproject.toml
    # pythonRelaxDeps does not work
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools>=65.6.3,<71" "setuptools"
  '';

  makeWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ patchelf ])
  ];

  # fails to find Console even though it exists on python 3.x
  doCheck = false;

  meta = with lib; {
    description = "Set of scripts and modules for freezing Python scripts into executables";
    homepage = "https://marcelotduarte.github.io/cx_Freeze/";
    changelog = "https://github.com/marcelotduarte/cx_Freeze/releases/tag/${version}";
    license = licenses.psfl;
    maintainers = [ ];
    mainProgram = "cxfreeze";
  };
}
