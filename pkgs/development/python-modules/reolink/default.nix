{
  lib,
  aiohttp,
  aiounittest,
  buildPythonPackage,
  fetchFromGitHub,
  ffmpeg-python,
  pytestCheckHook,
  pythonOlder,
  requests,
}:

buildPythonPackage rec {
  pname = "reolink";
  version = "0053";
  format = "setuptools";

  disabled = pythonOlder "3.8";

  src = fetchFromGitHub {
    owner = "fwestenberg";
    repo = "reolink";
    tag = "v${version}";
    hash = "sha256-DZcTfmzO9rBhhRN2RkgoPwUPE+LPPeZgc8kmhYU9V2I=";
  };

  propagatedBuildInputs = [
    aiohttp
    ffmpeg-python
    requests
  ];

  nativeCheckInputs = [
    aiounittest
    pytestCheckHook
  ];

  postPatch = ''
    # Packages in nixpkgs is different than the module name
    substituteInPlace setup.py \
      --replace "ffmpeg" "ffmpeg-python"
  '';

  # https://github.com/fwestenberg/reolink/issues/83
  doCheck = false;

  enabledTestPaths = [ "test.py" ];

  disabledTests = [
    # Tests require network access
    "test1_settings"
    "test2_states"
    "test3_images"
    "test4_properties"
    "test_succes"
  ];

  pythonImportsCheck = [ "reolink" ];

  meta = with lib; {
    description = "Module to interact with the Reolink IP camera API";
    homepage = "https://github.com/fwestenberg/reolink";
    changelog = "https://github.com/fwestenberg/reolink/releases/tag/v${version}";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ fab ];
  };
}
