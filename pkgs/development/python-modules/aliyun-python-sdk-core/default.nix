{
  lib,
  buildPythonPackage,
  cryptography,
  fetchPypi,
  jmespath,
  pythonOlder,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aliyun-python-sdk-core";
  version = "2.15.2";
  pyproject = true;

  disabled = pythonOlder "3.7";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-VPZqU+GTxhxeFupFBaDKtDVD+K0u8igz9pxNXlFRwX0=";
  };

  pythonRelaxDeps = true;

  build-system = [ setuptools ];


  dependencies = [
    cryptography
    jmespath
  ];

  # All components are stored in a mono repo
  doCheck = false;

  pythonImportsCheck = [ "aliyunsdkcore" ];

  meta = with lib; {
    description = "Core module of Aliyun Python SDK";
    homepage = "https://github.com/aliyun/aliyun-openapi-python-sdk";
    changelog = "https://github.com/aliyun/aliyun-openapi-python-sdk/blob/master/aliyun-python-sdk-core/ChangeLog.txt";
    license = licenses.asl20;
    maintainers = with maintainers; [ fab ];
  };
}
