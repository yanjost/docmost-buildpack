#!/usr/bin/env bash
set -e
source "../lib/common.sh"

configure_storage() {
  if [[ "$STORAGE_DRIVER" == "s3" ]]; then
    for v in AWS_S3_ACCESS_KEY_ID AWS_S3_SECRET_ACCESS_KEY AWS_S3_REGION AWS_S3_BUCKET; do
      [[ -z "${!v}" ]] && fail "Missing required S3 env: $v"
    done
    step "Storage" "S3 enabled"
  else
    step "Storage" "Using local filesystem storage"
  fi
}

configure_db_and_redis() {
  if [[ -z "$DATABASE_URL" && -n "$SCALINGO_POSTGRESQL_URL" ]]; then
    export DATABASE_URL="$SCALINGO_POSTGRESQL_URL"
    step "DB" "Mapped SCALINGO_POSTGRESQL_URL to DATABASE_URL"
  fi
  if [[ -z "$REDIS_URL" && -n "$SCALINGO_REDIS_URL" ]]; then
    export REDIS_URL="$SCALINGO_REDIS_URL"
    step "Redis" "Mapped SCALINGO_REDIS_URL to REDIS_URL"
  fi
  [[ -z "$DATABASE_URL" ]] && fail "Missing DATABASE_URL"
  [[ -z "$REDIS_URL" ]] && fail "Missing REDIS_URL"
}

write_profile_d() {
  mkdir -p "$BUILD_DIR/.profile.d"
  cat > "$BUILD_DIR/.profile.d/10-docmost.sh" <<EOF
# Docmost computed envs
export DOCMOST_VERSION="$VERSION"
EOF
}
