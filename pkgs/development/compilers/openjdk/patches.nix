{ fetchurl, fetchpatch }:
# JDK Patchsets
# Each attrset is the name of a patch, with a list of patch attrs
# Any version that does not match a patchset constraint will not have a patch applied.
# Each patch attr has the following values:
# # EITHER:
# # path: The path to the directory where the patch is found
# # func: A fetchpatch call to fetch the patch. Available so not everything has to be vendored.
# # AND
# # EITHER:
# # `only`: Specifies this patch only applies to that major version
# # OR(must have one or both)
# # `atLeast`: The patch is only applied to this version and higher(INCLUSIVE, so "8" includes 8)
# # `before`: The patch applies to versions before this number(EXCLUSIVE, so "8" is versions before 8)
{
  "fix-java-home.patch" = [
    {
      atLeast = "25";
      path = ./25;
    }
    {
      atLeast = "21";
      before = "25";
      path = ./21;
    }
    {
      atLeast = "11";
      before = "21";
      path = ./11;
    }
    {
      only = "8";
      path = ./8;
    }
  ];
  "read-truststore-from-env.patch" = [
    {
      atLeast = "25";
      path = ./25;
    }
    {
      atLeast = "11";
      before = "25";
      path = ./11;
    }
    {
      only = "8";
      path = ./8;
    }
  ];
  "currency-date-range.patch" = [
    {
      atLeast = "11";
      before = "23";
      path = ./11;
    }
    {
      atLeast = "8";
      before = "10";
      path = ./8;
    }
  ];
  "increase-javadoc-heap.patch" = [
    {
      atLeast = "17";
      path = ./17;
    }
    {
      atLeast = "11";
      before = "17";
      path = ./11;
    }
  ];
  "ignore-LegalNoticeFilePlugin.patch" = [
    {
      atLeast = "21";
      path = ./21;
    }
    {
      atLeast = "17";
      before = "21";
      path = ./17;
    }
  ];
  "fix-library-path.patch" = [
    {
      atLeast = "17";
      before = "21";
      path = ./17;
    }
    {
      atLeast = "11";
      before = "17";
      path = ./11;
    }
    {
      only = "8";
      path = ./8;
    }
  ];
  "wformat-fix.patch" = [
    {
      atLeast = "17";
      before = "21";
      func = fetchurl {
        url = "https://src.fedoraproject.org/rpms/java-openjdk/raw/06c001c7d87f2e9fe4fedeef2d993bcd5d7afa2a/f/rh1673833-remove_removal_of_wformat_during_test_compilation.patch";
        sha256 = "082lmc30x64x583vqq00c8y0wqih3y4r0mp1c4bqq36l22qv6b6r";
      };
    }
  ];
  "fix-nullptr-cast.patch" = [
    {
      only = "17";
      func = fetchurl {
        url = "https://git.alpinelinux.org/aports/plain/community/openjdk17/FixNullPtrCast.patch?id=41e78a067953e0b13d062d632bae6c4f8028d91c";
        sha256 = "sha256-LzmSew51+DyqqGyyMw2fbXeBluCiCYsS1nCjt9hX6zo=";
      };
    }
  ];
  "make-4.4.1.patch" = [
    {
      atLeast = "25";
      path = ./25;
    }
    {
      atLeast = "9";
      before = "25";
      func = fetchpatch {
        url = "https://github.com/openjdk/jdk/commit/9341d135b855cc208d48e47d30cd90aafa354c36.patch";
        hash = "sha256-Qcm3ZmGCOYLZcskNjj7DYR85R4v07vYvvavrVOYL8vg=";
      };
    }
  ];
  "make-4.3.patch" = [
    {
      only = "9";
      func = fetchurl {
        url = "https://gitlab.alpinelinux.org/alpine/aports/-/raw/3.18-stable/community/openjdk9/make-4.3.patch";
        hash = "sha256-XscdQ2ri8fjkxF71tYkpW//Y16oPXjrhT7NW838Ttig=";
      };
    }
  ];
  "fix-oopdesc-ptr-alignment-ub.patch" = [
    {
      only = "11";
      path = ./11;
    }
  ];
  "fix-pointer-comparison.patch" = [
    {
      only = "9";
      func = fetchurl {
        url = "https://codeberg.org/guix/guix/raw/commit/3a0d265d403ff13c1082d07b8f0205771ac412b9/gnu/packages/patches/openjdk-9-pointer-comparison.patch";
        hash = "sha256-8rKhrfP4mYRA3feYk202Iguiy1WbZu4kUs2pUA9e9Co=";
      };
    }
  ];
  "fix-missing-include.patch" = [
    {
      only = "9";
      path = ./9;
    }
  ];
  "gcc10-compilation-fix.patch" = [
    {
      only = "9";
      func = fetchurl {
        url = "https://gitlab.alpinelinux.org/alpine/aports/-/raw/3.17-stable/community/openjdk9/gcc10-compilation-fix.patch";
        hash = "sha256-QXJ/9NqbDx3T0jmypAdCeflIrbb0szY5l6UKyHQgt0s=";
      };
    }
  ];
  "fix-c1.patch" = [
    {
      only = "9";
      func = fetchpatch {
        url = "https://gitlab.alpinelinux.org/alpine/aports/-/raw/3.17-stable/community/openjdk9/JDK-8245051.patch";
        hash = "sha256-Ch3kkLoVc0UAw+K++jJeTsMtd0CxMN7RJv05Xh0Xf8k=";
      };
    }
  ];
  "glibc-2.34-stackguardpages-test.patch" = [
    {
      only = "9";
      func = fetchpatch {
        url = "https://github.com/openjdk/jdk/commit/f77a1a156f3da9068d012d9227c7ee0fee58f571.patch";
        stripLen = 4;
        extraPrefix = "hotspot/test/";
        hunks = [ "2-" ];
        hash = "sha256-qpYKM5f/UEVtlLuw8LM6sKwoy9h7QV2xC1SK6rq0tOY=";
      };
    }
  ];
  "fix-setsignalhandler.patch" = [
    {
      only = "10";
      func = fetchurl {
        url = "https://codeberg.org/guix/guix/raw/commit/3a0d265d403ff13c1082d07b8f0205771ac412b9/gnu/packages/patches/openjdk-10-setsignalhandler.patch";
        hash = "sha256-Zydh8WqNOP1g7dChAQ84v3b2wiXf03215eB3hIv3J3Y=";
      };
    }
  ];
}
