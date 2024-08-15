{
  lib,
  fetchFromGitHub,
  python311Packages,
  xsel,
  xclip,
  mtdev,
  nix-update-script,
  extraPackages ? [ ],
}:
let
  # Once next release is out, it should require the current version, so this can be removed
  zilliandomizer_0_7_1 = python311Packages.zilliandomizer.overridePythonAttrs (old: rec {
    version = "0.7.1";
    src = (
      old.src.override {
        rev = "v${version}";
        hash = "sha256-33WAScKQ9PMEmAy0/+mGKyh++wFLX36sbMCCszBOGC4=";
      }
    );
  });
in
python311Packages.buildPythonApplication rec {
  pname = "archipelago";
  version = "0.5.0";
  pyproject = false;

  src = fetchFromGitHub {
    owner = "ArchipelagoMW";
    repo = "Archipelago";
    rev = version;
    hash = "sha256-I6UHojEpC2/9bYK1khN1r+KsBTmU6zdsW8tpCYtB51I=";
  };

  postPatch = ''
    # This is in a variable assignment, so `pythonRelaxDeps` doesn't work
    substituteInPlace setup.py \
      --replace-fail "cx-Freeze==7.0.0" "cx-Freeze"
    # tested `pythonRelaxDeps`, it doesn't work on this
    substituteInPlace requirements.txt \
      --replace-fail "certifi>=2024.6.2" "certifi"
    substituteInPlace worlds/_sc2common/requirements.txt \
      --replace-fail "protobuf==3.20.3" "protobuf"
  '';

  build-system = with python311Packages; [
    setuptools
    pip
    cx-freeze
  ];

  dependencies =
    with python311Packages;
    [
      aiohttp
      astunparse
      bsdiff4
      certifi
      colorama
      cymem
      cython
      docutils
      factorio-rcon-py
      jellyfish
      jinja2
      kivy
      loguru
      maseya-z3pr
      mpyq
      nest-asyncio
      orjson
      platformdirs
      pillow
      portpicker
      protobuf
      pyevermizer
      pymem
      pyyaml
      requests
      s2clientprotocol
      schema
      six
      typing-extensions
      websockets
      xxtea
      zilliandomizer_0_7_1
    ]
    ++ [
      # Non-python dependencies
      xsel
      xclip
      mtdev
    ]
    ++ extraPackages;

  preBuild = ''
    export HOME=$(mktemp -d)
    unset SOURCE_DATE_EPOCH
  '';

  buildPhase = ''
    python3 setup.py build_exe
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Multi-Game Randomizer and Server";
    homepage = "https://archipelago.gg";
    changelog = "https://github.com/ArchipelagoMW/Archipelago/releases/tag/${version}";
    license = lib.licenses.mit;
    mainProgram = "archipelago";
    maintainers = with lib.maintainers; [ pyrox0 ];
    platforms = lib.platforms.linux;
  };
}
