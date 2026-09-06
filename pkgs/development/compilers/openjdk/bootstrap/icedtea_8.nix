{
  lib,
  stdenv,
  fetchzip,
  fetchurl,
  # System dependencies - libraries
  alsa-lib,
  cups,
  freetype,
  fontconfig,
  giflib,
  krb5,
  lcms2,
  libjpeg_turbo,
  libpng,
  libx11,
  libxcomposite,
  libxi,
  libxinerama,
  libxrender,
  libxt,
  libxtst,
  nss,
  pcsclite,
  which,
  zlib,
  # System dependencies - tools
  # keep-sorted start
  attr,
  autoconf,
  automake,
  coreutils,
  cpio,
  gawk,
  gnugrep,
  gnused,
  hostname,
  libtool,
  libxslt,
  perl,
  pkg-config,
  procps,
  unzip,
  wget,
  zip,
  # keep-sorted end
  # Bootstrap dependencies
  ant_1_8,
  icedtea_7,
}:
let
  version = "3.40.1";
  fetchdrop =
    name: hash:
    fetchurl {
      name = "${name}-drop-src";
      url = "http://icedtea.classpath.org/download/drops/icedtea8/${version}/${name}-git.tar.xz";
      inherit hash;
    };

  drops = {
    openjdk-src = fetchdrop "openjdk" "sha256-rx7Fs7obXFbVCa3wknubwQ73YRGuB5ffSPEjZDxKX+o=";
    aarch32-src = fetchdrop "aarch32" "sha256-QMrm+jlLq5gGPeHoVjImdPzIqxCfPT/SmFS56i8WTkY=";
    shenandoah-src = fetchdrop "shenandoah" "sha256-5VuHW3SLHV/2R7Q+nUlEXvetAwGNVVwcnimWhsYinyg=";
  };
in
stdenv.mkDerivation {
  pname = "icedtea";
  inherit version;

  outputs = [
    "out"
  ];

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchzip {
    url = "https://icedtea.classpath.org/download/source/icedtea-${version}.tar.xz";
    hash = "sha256-kE3z6RcWUQcRTaWmuutQXkJdOLcbCNMTCNLYuLs0dFw=";
  };

  postUnpack =
    let
      unpackDrop =
        comp:
        let
          compsrc = drops."${comp}-src";
        in
        ''
          echo "unpacking ${comp}"
          mkdir ${comp}
          tar xf ${compsrc} --strip-components=1 -C ${comp}
        '';
    in
    ''
      pushd source
      # Unpack all drops to the correct directory
      mkdir openjdk-src
      tar xf ${drops.openjdk-src} --strip-components=1 -C openjdk-src
      pushd openjdk-src
      ${unpackDrop "aarch32"}
      ${unpackDrop "shenandoah"}
      # Fixes icedtea makefile
      mv README.md README

      substituteInPlace jdk/src/share/classes/sun/security/provider/JavaKeyStore.java \
        --replace-fail "date = new Date();" "date = (System.getenv(\"SOURCE_DATE_EPOCH\") != null) ?
          new Date(Long.parseLong(System.getenv(\"SOURCE_DATE_EPOCH\"))) :
          new Date();"
      popd

      # Add this since we can't set it in `configureFlags` below
      configureFlagsArray+=("--with-parallel-jobs=$NIX_BUILD_CORES")

      # Exit source to prepare for build
      popd
    '';

  env = {
    LANG = "C.UTF-8";
    LC_ALL = "C.UTF-8";
    NIX_CFLAGS_COMPILE = "-std=gnu99 -fcommon -Wno-error=format-security -Wno-error=implicit-int -Wno-error=return-mismatch -Wno-error=implicit-function-declaration";
    CXXFLAGS = "-std=gnu++98 -fcommon";
    UTILS_COMMAND_PATH = "${coreutils}/bin/";
    UTILS_USR_BIN_PATH = "${coreutils}/bin/";
    UTILS_CCS_BIN_PATH = "${stdenv.cc}/bin/";
    DISABLE_HOTSPOT_OS_VERSION_CHECK = "ok";
  };

  configureFlags = [
    "--enable-bootstrap"
    "--enable-nss"
    "--disable-docs"
    "--disable-downloading"
    "--disable-system-pcsc"
    "--disable-system-sctp"
    "--disable-tests"
    "--with-openjdk-src-dir=./openjdk-src"
    "--with-jdk-home=${icedtea_7}"
    "--with-pkgversion=nixpkgs-bootstrap"
  ];

  nativeBuildInputs = [
    # bootstrap dependencies
    ant_1_8
    icedtea_7
    # system dependencies
    attr
    autoconf
    automake
    coreutils
    cpio
    gawk
    gnugrep
    gnused
    hostname
    libtool
    libxslt
    perl
    pkg-config
    procps
    unzip
    wget
    which
    zip
  ];

  buildInputs = [
    alsa-lib
    cups
    freetype
    fontconfig
    giflib
    krb5
    lcms2
    libjpeg_turbo
    libpng
    libx11
    libxcomposite
    libxi
    libxinerama
    libxrender
    libxt
    libxtst
    nss
    pcsclite
    zlib
  ];

  # This saves time, and the real test we do is compiling further JDKs, so this is fine to disable.
  doCheck = false;

  meta = {
    description = "Java development kit";
    homepage = "https://icedtea.classpath.org";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
}
