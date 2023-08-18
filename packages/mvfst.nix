{
  source,
  lib,
  fastStdenv,
  cmake,
  fizz,
  folly,
  boost,
  libsodium,
  fmt_9,
  zlib,
  gflags,
  glog,
  libtool,
  ...
}:
fastStdenv.mkDerivation rec {
  inherit (source) pname version src;
  # https://github.com/cachix/cachix/issues/373
  # __contentAddressed = true;

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    fizz
    folly
    fmt_9
    boost
    libsodium
    zlib
    gflags
    glog
    libtool
  ];

  preConfigure = ''
    export ZLIB_LIBRARY=${zlib}/lib
  '';

  meta.platforms = lib.platforms.linux;
}
