#!/usr/bin/env bats

setup() {
  export BUILD_DIR="$BATS_TMPDIR/build"
  mkdir -p "$BUILD_DIR/app/apps/server/dist"
  touch "$BUILD_DIR/app/apps/server/dist/main.js"
}

@test "entrypoint inference finds main.js" {
  run bash -c 'source ../lib/docmost_release.sh; infer_entrypoint'
  [ "$status" -eq 0 ]
  grep -q "node apps/server/dist/main.js" "$BUILD_DIR/.docmost_web_cmd"
}
