#!/usr/bin/env bats

setup() {
  export DOCMOST_VERSION="1.9.0"
  export BUILD_DIR="$BATS_TMPDIR/build"
  mkdir -p "$BUILD_DIR"
}

@test "fetch_and_unpack_docmost downloads and unpacks tarball" {
  run bash -c 'source ../lib/docmost_release.sh; resolve_docmost_version; fetch_and_unpack_docmost'
  [ "$status" -eq 0 ]
  [ -d "$BUILD_DIR/app" ]
}
