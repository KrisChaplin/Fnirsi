#!/usr/bin/env bash
# Build libsigrok (with the FNIRSI DLA-32 driver) and sigrok-cli on Linux
# into a local prefix. Usage: tools/build_linux.sh [PREFIX] [BUILD_DIR]
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/.." && pwd)
PREFIX=${1:-$ROOT/../prefix}
BUILD=${2:-$ROOT/../build}
JOBS=$(nproc)
mkdir -p "$PREFIX" "$BUILD"
PREFIX=$(cd "$PREFIX" && pwd)
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"

build() { # name, extra configure args...
	local name=$1; shift
	rsync -a --delete "$ROOT/src/$name/" "$BUILD/$name/"
	(cd "$BUILD/$name" && ./autogen.sh && ./configure --prefix="$PREFIX" "$@" \
		&& make -j"$JOBS" && make install)
}

build libsigrok --enable-cxx --disable-java --disable-ruby
build sigrok-cli
echo "Built into $PREFIX. Run with:"
echo "  LD_LIBRARY_PATH=$PREFIX/lib $PREFIX/bin/sigrok-cli -d fnirsi-dla32:conn=<bus>.<addr> --show"
