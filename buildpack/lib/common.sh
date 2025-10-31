#!/usr/bin/env bash
set -e

BUILD_DIR=${BUILD_DIR:-$(pwd)}
CACHE_DIR=${CACHE_DIR:-"$BUILD_DIR/.cache"}
TMP_DIR=${TMP_DIR:-"$BUILD_DIR/.tmp"}

step() {
  echo ":: $1 :: $2"
}

fail() {
  echo "ERROR: $1" >&2
  exit 1
}
