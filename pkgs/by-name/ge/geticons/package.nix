{
  lib,
  rustPlatform,
  fetchFromSourcehut,
  gitUpdater,
}:

rustPlatform.buildRustPackage rec {
  pname = "geticons";
  version = "1.2.2";

  src = fetchFromSourcehut {
    owner = "~zethra";
    repo = "geticons";
    rev = version;
    hash = "sha256-HEnUfOLeRTi2dRRqjDPVwVVHo/GN9wE28x5qv3qOpCY=";
  };

  cargoHash = "sha256-V3e3boIzn76irAfn9fF9MycPRAWorUUSD/CUZhgKv0E=";
  passthru.updateScript = gitUpdater { };

  meta = with lib; {
    description = "CLI utility to get icons for apps on your system or other generic icons by name";
    mainProgram = "geticons";
    homepage = "https://git.sr.ht/~zethra/geticons";
    license = with licenses; [ gpl3Plus ];
    maintainers = with maintainers; [ Madouura ];
  };
}
