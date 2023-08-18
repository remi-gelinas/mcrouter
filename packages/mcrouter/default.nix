{
  source,
  lib,
  fastStdenv,
  pkg-config,
  autoreconfHook,
  fizz,
  folly,
  wangle,
  fbthrift,
  glog,
  ragel,
  python38,
  boost,
  libevent,
  openssl,
  zlib,
  double-conversion,
  libsodium,
  gtest,
  fmt_9,
  zstd,
  snappy,
  lz4,
  lzma,
  libunwind,
  jemalloc,
  bzip2,
  bison,
  flex,
  gflags,
  libtool,
  libxcrypt,
  mvfst,
  libiberty,
  ...
}: let
  thriftSearchPath = lib.strings.makeSearchPathOutput "out" "include" [fbthrift];
in
  fastStdenv.mkDerivation rec {
    inherit (source) pname version src;
    __contentAddressed = true;

    sourceRoot = "source/mcrouter";

    patches = [./patches/mcrouter-version.patch];

    nativeBuildInputs = [
      pkg-config
      autoreconfHook
      bison
      flex
    ];

    buildInputs = [
      fizz
      folly
      wangle
      fbthrift
      glog
      ragel
      python38
      boost
      libevent
      openssl
      zlib
      double-conversion
      libsodium
      gtest
      fmt_9
      zstd
      snappy
      lz4
      lzma
      libunwind
      jemalloc
      bzip2
      libtool
      gflags
      libxcrypt
      mvfst
      libiberty
    ];

    configureFlags = [
      "--with-boost-libdir=${boost}/lib"
    ];

    postUnpack = ''
      echo "${version}" > $sourceRoot/VERSION
    '';

    preConfigure = ''
      export FBTHRIFT_BIN="${fbthrift}/bin/"
    '';

    preBuild = ''
      export THRIFT_INCLUDE_PATH="${thriftSearchPath}"
    '';

    env.NIX_CFLAGS_COMPILE = lib.optionalString fastStdenv.isAarch64 "-flax-vector-conversions";

    meta.platforms = lib.platforms.linux;
  }
