#!/usr/bin/env bash
set -e
trap 'echo "[ERROR] $0 failed at line $LINENO: $BASH_COMMAND" >&2' ERR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

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
  TARBALL_URL="https://github.com/docmost/docmost/archive/refs/tags/$VERSION.tar.gz"
  step "Download" "Fetching $TARBALL_URL"
  mkdir -p "$TMP_DIR"
  curl -sSL "$TARBALL_URL" -o "$TMP_DIR/docmost.tar.gz"
  # TODO: Checksum/signature verification if available
  tar -xzf "$TMP_DIR/docmost.tar.gz" -C "$BUILD_DIR" --strip-components=1
}

infer_entrypoint() {
  # Search for main.js in plausible locations
  local candidates=(
    "$BUILD_DIR/apps/server/dist/main.js"
    "$BUILD_DIR/packages/server/dist/main.js"
  )
  candidates+=( $(find "$BUILD_DIR" -type f -path "*/server/*/dist/main.js" -o -path "*/api/*/dist/main.js") )
  local entrypoint=""
  for f in "${candidates[@]}"; do
    if [[ -f "$f" ]]; then
      entrypoint="node ${f#$BUILD_DIR/}"
      break
    fi
  done
  if [[ -z "$entrypoint" ]]; then
    # Try package.json start script
    if [[ -f "$BUILD_DIR/package.json" ]]; then
      entrypoint=$(jq -r '.scripts.start' "$BUILD_DIR/package.json")
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
