final: prev: {
  sources =
    builtins.mapAttrs
    (_: src:
      src
      // {
        version = prev.lib.strings.removePrefix "v" src.version;
      })
    (import _sources/generated.nix {inherit (prev) dockerTools fetchurl fetchgit fetchFromGitHub;});

  folly = (prev.folly.override {stdenv = final.fastStdenv;}).overrideAttrs (_: {
    inherit (final.sources.folly) pname version src;
    # https://github.com/cachix/cachix/issues/373
    # __contentAddressed = true;

    buildInputs = with final; [
      boost
      double-conversion
      glog
      gflags
      libevent
      libiberty
      openssl
      lz4
      xz
      zlib
      libunwind
      fmt_9
      zstd
      bzip2
      libsodium
      liburing
      libaio
      libdwarf
      snappy
      jemalloc
    ];

    env.NIX_CFLAGS_COMPILE = final.lib.optionalString final.stdenv.isAarch64 "-flax-vector-conversions";
  });

  fizz = (prev.fizz.override {stdenv = final.fastStdenv;}).overrideAttrs (prev: let
    inherit (final.lib) optional optionalString;
    inherit (final.stdenv) isAarch64;
  in {
    inherit (final.sources.fizz) pname version src;
    # https://github.com/cachix/cachix/issues/373
    # __contentAddressed = true;

    buildInputs = with final; [
      fmt_9
      boost
      double-conversion
      folly
      glog
      gflags
      gtest
      libevent
      libiberty
      libsodium
      openssl
      zlib
      zstd
    ];

    patches = (prev.patches or []) ++ [./packages/fizz/patches/fizz-disable-tests.patch] ++ optional isAarch64 [./packages/fizz/patches/fizz-remove-aegis-flags.patch];
    cmakeFlags = optional isAarch64 ["BUILD_TESTS=OFF"];
    env.NIX_CFLAGS_COMPILE = optionalString isAarch64 "-flax-vector-conversions";
  });

  wangle = (prev.wangle.override {stdenv = final.fastStdenv;}).overrideAttrs (_: {
    inherit (final.sources.wangle) pname version src;
    # https://github.com/cachix/cachix/issues/373
    # __contentAddressed = true;

    buildInputs = with final; [
      fmt_9
      libsodium
      zlib
      boost
      double-conversion
      fizz
      folly
      gtest
      glog
      gflags
      libevent
      openssl
    ];

    env.NIX_CFLAGS_COMPILE = final.lib.optionalString final.stdenv.isAarch64 "-flax-vector-conversions";
  });

  fbthrift = (prev.fbthrift.override {stdenv = final.fastStdenv;}).overrideAttrs (_: {
    inherit (final.sources.fbthrift) pname version src;
    # https://github.com/cachix/cachix/issues/373
    # __contentAddressed = true;

    nativeBuildInputs = with final; [
      makeWrapper
      cmake
      bison
      flex
    ];

    buildInputs = with final; [
      boost
      double-conversion
      fizz
      fmt_9
      folly
      glog
      gflags
      libevent
      libiberty
      openssl
      wangle
      zlib
      zstd
      libsodium
      mvfst
    ];

    env.NIX_CFLAGS_COMPILE = final.lib.optionalString final.stdenv.isAarch64 "-flax-vector-conversions";
  });

  mvfst = final.callPackage packages/mvfst.nix {source = final.sources.mvfst;};
  mcrouter = final.callPackage packages/mcrouter {source = final.sources.mcrouter;};
}
