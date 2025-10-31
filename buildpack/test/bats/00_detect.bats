#!/usr/bin/env bats

@test "detect passes with DOCMOST_VERSION" {
  run ../bin/detect
  [ "$status" -eq 0 ]
}

@test "detect passes with Procfile" {
  touch $BUILD_DIR/Procfile
  run ../bin/detect
  [ "$status" -eq 0 ]
}
