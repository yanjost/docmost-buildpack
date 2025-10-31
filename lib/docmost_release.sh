#!/usr/bin/env bash
set -e
source "../lib/common.sh"

resolve_docmost_version() {
  if [[ -n "$DOCMOST_VERSION" ]]; then
    VERSION="$DOCMOST_VERSION"
    step "Version" "Using DOCMOST_VERSION=$VERSION"
  else
    VERSION=$(curl -s https://api.github.com/repos/docmost/docmost/releases | jq -r '.[] | select(.prerelease==false) | .tag_name' | sort -Vr | head -n1)
    step "Version" "Resolved latest stable: $VERSION"
  fi
  export VERSION
}

fetch_and_unpack_docmost() {
  TARBALL_URL="https://github.com/docmost/docmost/releases/download/$VERSION/docmost-$VERSION.tar.gz"
  step "Download" "Fetching $TARBALL_URL"
  mkdir -p "$TMP_DIR"
  curl -sSL "$TARBALL_URL" -o "$TMP_DIR/docmost.tar.gz"
  # TODO: Checksum/signature verification if available
  tar -xzf "$TMP_DIR/docmost.tar.gz" -C "$BUILD_DIR/app"
}

infer_entrypoint() {
  # Search for main.js in plausible locations
  local candidates=(
    "$BUILD_DIR/app/apps/server/dist/main.js"
    "$BUILD_DIR/app/packages/server/dist/main.js"
  )
  candidates+=( $(find "$BUILD_DIR/app" -type f -path "*/server/*/dist/main.js" -o -path "*/api/*/dist/main.js") )
  local entrypoint=""
  for f in "${candidates[@]}"; do
    if [[ -f "$f" ]]; then
      entrypoint="node ${f#$BUILD_DIR/app/}"
      break
    fi
  done
  if [[ -z "$entrypoint" ]]; then
    # Try package.json start script
    if [[ -f "$BUILD_DIR/app/package.json" ]]; then
      entrypoint=$(jq -r '.scripts.start' "$BUILD_DIR/app/package.json")
    fi
  fi
  if [[ -z "$entrypoint" && -n "$DOCMOST_WEB_CMD" ]]; then
    entrypoint="$DOCMOST_WEB_CMD"
    step "Entrypoint" "Using DOCMOST_WEB_CMD override"
  fi
  if [[ -z "$entrypoint" ]]; then
    fail "Could not infer entrypoint. Candidates: ${candidates[*]}"
  fi
  echo "$entrypoint" > "$BUILD_DIR/.docmost_web_cmd"
  step "Entrypoint" "Resolved: $entrypoint"
}
