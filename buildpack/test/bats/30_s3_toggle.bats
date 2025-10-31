#!/usr/bin/env bats

setup() {
  export BUILD_DIR="$BATS_TMPDIR/build"
  mkdir -p "$BUILD_DIR"
}

@test "fails if S3 enabled but missing envs" {
  export STORAGE_DRIVER="s3"
  run bash -c 'source ../lib/config_render.sh; configure_storage'
  [ "$status" -ne 0 ]
  [[ "$output" == *"Missing required S3 env"* ]]
}

@test "passes with all S3 envs" {
  export STORAGE_DRIVER="s3"
  export AWS_S3_ACCESS_KEY_ID="key"
  export AWS_S3_SECRET_ACCESS_KEY="secret"
  export AWS_S3_REGION="region"
  export AWS_S3_BUCKET="bucket"
  run bash -c 'source ../lib/config_render.sh; configure_storage'
  [ "$status" -eq 0 ]
}
