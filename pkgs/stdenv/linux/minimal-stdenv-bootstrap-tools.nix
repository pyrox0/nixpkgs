{
  lib,
  stdenv,
  binutils,
  bootGCC,
  buildPackages,
  busyboxMinimal,
  gmpxx,
  gnugrep,
  libmpc,
  mpfr,
  runCommand,
  minimal-bootstrap,
}:
let
  # ${libc.src}/sysdeps/unix/sysv/linux/loongarch/lp64/libnsl.abilist does not exist!
  withLibnsl = !stdenv.hostPlatform.isLoongArch64;

  inherit (minimal-bootstrap)
    bash-static
    binutils-static
    bzip2-static
    coreutils-static
    diffutils-static
    findutils-static
    gawk-static
    gcc-latest
    glibc
    gnugrep-static
    gnumake-static
    gnupatch-static
    gnused-static
    gnutar-static
    gzip-static
    musl
    patchelf-static
    zlib
    ;
in
stdenv.mkDerivation (finalAttrs: {
  name = "stdenv-bootstrap-tools";

  meta = {
    # Increase priority to unblock nixpkgs-unstable
    # https://github.com/NixOS/nixpkgs/pull/104679#issuecomment-732267288
    schedulingPriority = 200;
  };

  nativeBuildInputs = [
    buildPackages.nukeReferences
    buildPackages.cpio
  ];

  buildCommand = ''
    set -x
    mkdir -p $out/bin $out/lib $out/libexec

  ''
  + (
    if (stdenv.hostPlatform.libc == "glibc") then
      ''
        # Copy what we need of Glibc.
        cp -d ${glibc.out}/lib/ld*.so* $out/lib
        cp -d ${glibc.out}/lib/libc*.so* $out/lib
        cp -d ${glibc.out}/lib/libc_nonshared.a $out/lib
        cp -d ${glibc.out}/lib/libm*.so* $out/lib
        cp -d ${glibc.out}/lib/libdl*.so* $out/lib
        cp -d ${glibc.out}/lib/librt*.so*  $out/lib
        cp -d ${glibc.out}/lib/libpthread*.so* $out/lib
      ''
      + lib.optionalString withLibnsl ''
        cp -d ${glibc.out}/lib/libnsl*.so* $out/lib
      ''
      + ''
        cp -d ${glibc.out}/lib/libnss*.so* $out/lib
        cp -d ${glibc.out}/lib/libresolv*.so* $out/lib
        # Copy all runtime files to enable non-PIE, PIE, static PIE and profile-generated builds
        cp -d ${glibc.out}/lib/*.o $out/lib

        # Hacky compat with our current unpack-bootstrap-tools.sh
        ln -s librt.so "$out"/lib/librt-dummy.so

        cp -rL ${glibc.out}/include $out
        chmod -R u+w "$out"

        # libc can contain linker scripts: find them, copy their deps,
        # and get rid of absolute paths (nuke-refs would make them useless)
        local lScripts=$(grep --files-with-matches --max-count=1 'GNU ld script' -R "$out/lib")
        cp -d -t "$out/lib/" $(cat $lScripts | tr " " "\n" | grep -F '${glibc.out}' | sort -u)
        for f in $lScripts; do
          substituteInPlace "$f" --replace '${glibc.out}/lib/' ""
        done

        # Hopefully we won't need these.
        rm -rf $out/include/mtd $out/include/rdma $out/include/sound $out/include/video
        find $out/include -name .install -exec rm {} \;
        find $out/include -name ..install.cmd -exec rm {} \;
        mv $out/include $out/include-glibc
      ''
    else if (stdenv.hostPlatform.libc == "musl") then
      ''
        # Copy what we need from musl
        cp ${musl.out}/lib/* $out/lib
        cp -rL ${musl.dev}/include $out
        chmod -R u+w "$out"

        rm -rf $out/include/mtd $out/include/rdma $out/include/sound $out/include/video
        find $out/include -name .install -exec rm {} \;
        find $out/include -name ..install.cmd -exec rm {} \;
        mv $out/include $out/include-libc
      ''
    else
      throw "unsupported libc for bootstrap tools"
  )
  + ''
    # Copy coreutils, bash, etc.
    cp -d ${coreutils-static.out}/bin/* $out/bin
    (cd $out/bin && rm vdir dir sha*sum pinky factor pathchk runcon shuf who whoami shred users)

    cp ${bash-static.out}/bin/bash $out/bin
    cp ${findutils-static.out}/bin/find $out/bin
    cp ${findutils-static.out}/bin/xargs $out/bin
    cp -d ${diffutils-static.out}/bin/* $out/bin
    cp -d ${gnused-static.out}/bin/* $out/bin
    cp -d ${gnugrep-static.out}/bin/grep $out/bin
    cp ${gawk-static.out}/bin/gawk $out/bin
    cp -d ${gawk-static.out}/bin/awk $out/bin
    cp ${gnutar-static.out}/bin/tar $out/bin
    cp ${gzip-static.out}/bin/.gzip-wrapped $out/bin/gzip
    cp ${bzip2-static.bin}/bin/bzip2 $out/bin
    cp -d ${gnumake-static.out}/bin/* $out/bin
    cp -d ${gnupatch-static}/bin/* $out/bin
    cp ${patchelf-static}/bin/* $out/bin

    cp -d ${gnugrep.pcre2.out}/lib/libpcre2*.so* $out/lib # needed by grep

    # Copy what we need of GCC.
    cp -d ${gcc-latest.out}/bin/gcc $out/bin
    cp -d ${gcc-latest.out}/bin/cpp $out/bin
    cp -d ${gcc-latest.out}/bin/g++ $out/bin
    cp    ${gcc-latest.lib}/lib/libgcc_s.so* $out/lib
    cp -d ${gcc-latest.lib}/lib/libstdc++.so* $out/lib
    cp -d ${gcc-latest.out}/lib/libssp.a* $out/lib
    cp -d ${gcc-latest.out}/lib/libssp_nonshared.a $out/lib
    cp -rd ${gcc-latest.out}/lib/gcc $out/lib
    chmod -R u+w $out/lib
    rm -f $out/lib/gcc/*/*/include*/linux
    rm -f $out/lib/gcc/*/*/include*/sound
    rm -rf $out/lib/gcc/*/*/include*/root
    rm -f $out/lib/gcc/*/*/include-fixed/asm
    rm -rf $out/lib/gcc/*/*/plugin
    #rm -f $out/lib/gcc/*/*/*.a
    cp -rd ${gcc-latest.out}/libexec/* $out/libexec
    chmod -R u+w $out/libexec
    rm -rf $out/libexec/gcc/*/*/plugin
    mkdir -p $out/include
    cp -rd ${gcc-latest.out}/include/c++ $out/include
    chmod -R u+w $out/include
    rm -rf $out/include/c++/*/ext/pb_ds
    rm -rf $out/include/c++/*/ext/parallel

    cp -d ${gmpxx.out}/lib/libgmp*.so* $out/lib
    cp -d ${mpfr.out}/lib/libmpfr*.so* $out/lib
    cp -d ${libmpc.out}/lib/libmpc*.so* $out/lib
    cp -d ${zlib.out}/lib/libz.so* $out/lib

  ''
  + lib.optionalString (stdenv.hostPlatform.isRiscV) ''
    # libatomic is required on RiscV platform for C/C++ atomics and pthread
    # even though they may be translated into native instructions.
    cp -d ${bootGCC.out}/lib/libatomic.a* $out/lib

  ''
  + ''
    cp -d ${bzip2-static.out}/lib/libbz2.so* $out/lib

    # Copy binutils.
    for i in as ld ar ranlib nm strip readelf objdump; do
      cp ${binutils-static.out}/bin/$i $out/bin
    done
    cp -r '${lib.getLib binutils.bintools}'/lib/* "$out/lib/"

    chmod -R u+w $out

    # Strip executables even further.
    for i in $out/bin/* $out/libexec/gcc/*/*/*; do
        if test -x $i -a ! -L $i; then
            chmod +w $i
            $STRIP -s $i || true
        fi
    done

    nuke-refs $out/bin/*
    nuke-refs $out/lib/*
    nuke-refs $out/lib/*/*
    nuke-refs $out/libexec/gcc/*/*/*
    nuke-refs $out/lib/gcc/*/*/*
    nuke-refs $out/lib/gcc/*/*/include-fixed/*{,/*}

    mkdir $out/.pack
    mv $out/* $out/.pack
    mv $out/.pack $out/pack

    mkdir $out/on-server
    XZ_OPT="-9 -e" tar cvJf $out/on-server/bootstrap-tools.tar.xz --hard-dereference --sort=name --numeric-owner --owner=0 --group=0 --mtime=@1 -C $out/pack .
    cp ${busyboxMinimal}/bin/busybox $out/on-server
    chmod u+w $out/on-server/busybox
    nuke-refs $out/on-server/busybox
  ''; # */

  # The result should not contain any references (store paths) so
  # that we can safely copy them out of the store and to other
  # locations in the store.
  allowedReferences = [ ];

  passthru = {
    bootstrapFiles = {
      # Make them their own store paths to test that busybox still works when the binary is named /nix/store/HASH-busybox
      busybox = runCommand "busybox" { } "cp ${finalAttrs.finalPackage}/on-server/busybox $out";
      bootstrapTools =
        runCommand "bootstrap-tools.tar.xz" { }
          "cp ${finalAttrs.finalPackage}/on-server/bootstrap-tools.tar.xz $out";
    };
  };
})
