#!/usr/bin/env bats

setup() {
  export BUILD_DIR="$BATS_TMPDIR/build-node"
  rm -rf "$BUILD_DIR"; mkdir -p "$BUILD_DIR"
  echo '{"name":"docmost","engines":{"pnpm":"11"}}' > "$BUILD_DIR/package.json"
}

@test "pin_node_engine sets engines.node and keeps other engines" {
  run bash -c 'source ../lib/docmost_release.sh; DOCMOST_NODE_VERSION=26.x pin_node_engine'
  [ "$status" -eq 0 ]
  [ "$(jq -r .engines.node "$BUILD_DIR/package.json")" = "26.x" ]
  [ "$(jq -r .engines.pnpm "$BUILD_DIR/package.json")" = "11" ]
}

@test "pin_node_engine is a no-op without DOCMOST_NODE_VERSION" {
  run bash -c 'source ../lib/docmost_release.sh; pin_node_engine'
  [ "$status" -eq 0 ]
  [ "$(jq -r .engines.node "$BUILD_DIR/package.json")" = "null" ]
}
