{
  lib,
  stdenv,
  autoreconfHook,
  cmake,
  pkg-config,
  ninja,
  SDL2,
  SDL2_net,
  SDL2_mixer,
  libsamplerate,
  fluidsynth,
  zlib,
  libpng,
  glib,
  libsysprof-capture,
  pcre2,
  openssl,
  curl,
  assimp,
  xorg,
  fetchFromGitHub,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "apdoom";
  version = "1.2.0-pre1";

  src = fetchFromGitHub {
    owner = "Daivuk";
    repo = "apdoom";
    tag = finalAttrs.version;
    sha256 = "sha256-C8IcdWIEsfUq5GxHumr2cfa1JC8JKb0Ey50iGx28rRw=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace-fail "SDL2::SDL2main" ""
    for script in $(grep -lr '^#!/usr/bin/env python3$'); do patchShebangs $script; done
    substituteInPlace onut/CMakeLists.txt \
      --replace-fail "add_subdirectory(./thirdparty/assimp/)" ""
  '';

  nativeBuildInputs = [
    autoreconfHook
    cmake
    ninja
    pkg-config
    python3
  ];

  buildInputs = [
    SDL2
    SDL2_mixer
    SDL2_net
    libsamplerate
    fluidsynth
    zlib
    libpng
    glib
    libsysprof-capture
    pcre2
    openssl
    curl
    xorg.libXext
    assimp
  ];

  cmakeFlags = [
    (lib.cmakeBool "ONUT_STATIC_SDL" false)
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=implicit-function-declaration"
    "-Wno-error=implicit-int"
    "-Wno-error=incompatible-pointer-types"
    "-Wno-error=format-security"
  ];
  meta = {
    homepage = "https://github.com/Daivuk/apdoom";
    description = "Fork of Crispy Doom to allow multi-world features from Archipelago.";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ pyrox0 ];
  };
})
