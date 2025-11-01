#!/usr/bin/env bash
set -e
trap 'echo "[ERROR] $0 failed at line $LINENO: $BASH_COMMAND" >&2' ERR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

write_slugignore() {
  local SLUGIGNORE_FILE="$BUILD_DIR/.slugignore"

  step "Slugignore" "Configuring .slugignore for optimal slug size"

  # Check if .slugignore already exists
  if [[ -f "$SLUGIGNORE_FILE" ]]; then
    step "Slugignore" "Appending to existing .slugignore"
  else
    step "Slugignore" "Creating .slugignore"
  fi

  # Append our optimizations (use a marker to avoid duplicates)
  # Note: .slugignore doesn't support comments or negation (!) patterns
  if ! grep -q "DOCMOST_BUILDPACK_OPTIMIZATIONS" "$SLUGIGNORE_FILE" 2>/dev/null; then
    cat >> "$SLUGIGNORE_FILE" <<'SLUGIGNORE_EOF'

.gitignore
.env.example
docker-compose*.yml
Dockerfile*
.dockerignore
LICENSE*
apps/client/src/
apps/server/src/
packages/*/src/
node_modules/.pnpm/nx@*/
node_modules/.pnpm/@nx+*/
node_modules/@nx/
node_modules/nx/
node_modules/.pnpm/vite@*/
node_modules/vite/
node_modules/.pnpm/typescript@*/
node_modules/typescript/
node_modules/.pnpm/jest@*/
node_modules/jest/
node_modules/.pnpm/concurrently@*/
node_modules/concurrently/
node_modules/.pnpm/@nestjs+cli@*/
node_modules/@nestjs/cli/
node_modules/.pnpm/@nestjs+schematics@*/
node_modules/@nestjs/schematics/
node_modules/.pnpm/@nestjs+testing@*/
node_modules/@nestjs/testing/
node_modules/.pnpm/@types+*/
node_modules/@types/
node_modules/.pnpm/@eslint+*/
node_modules/@eslint/
node_modules/.pnpm/eslint@*/
node_modules/eslint/
node_modules/.pnpm/prettier@*/
node_modules/prettier/
node_modules/.pnpm/@swc+*/
node_modules/@swc/
node_modules/.pnpm/esbuild@*/
node_modules/esbuild/
node_modules/.pnpm/@vitejs+*/
node_modules/@vitejs/
node_modules/.pnpm/rollup@*/
node_modules/rollup/
node_modules/.pnpm/@rollup+*/
node_modules/@rollup/
node_modules/.pnpm/webpack@*/
node_modules/webpack/
node_modules/.pnpm/@babel+*/
node_modules/@babel/
node_modules/.pnpm/@parcel+*/
node_modules/@parcel/
node_modules/.pnpm/terser@*/
node_modules/terser/
node_modules/.pnpm/webpack-cli@*/
node_modules/webpack-cli/
node_modules/.pnpm/@typescript-eslint+*/
node_modules/@typescript-eslint/
node_modules/.pnpm/ts-node@*/
node_modules/ts-node/
node_modules/.pnpm/tsx@*/
node_modules/tsx/
node_modules/.modules.yaml
.nx/
.cache/
*.md
pnpm-lock.yaml
nx.json
crowdin.yml
patches/
apps/client/dist/assets/*-ar-*.js
apps/client/dist/assets/*-de-*.js
apps/client/dist/assets/*-es-*.js
apps/client/dist/assets/*-fr-*.js
apps/client/dist/assets/*-it-*.js
apps/client/dist/assets/*-ja-*.js
apps/client/dist/assets/*-ko-*.js
apps/client/dist/assets/*-pl-*.js
apps/client/dist/assets/*-pt-*.js
apps/client/dist/assets/*-ru-*.js
apps/client/dist/assets/*-zh-*.js
apps/client/dist/assets/*-nl-*.js
apps/client/dist/assets/*-sv-*.js
apps/client/dist/assets/*-tr-*.js
apps/client/dist/assets/*-cs-*.js
apps/client/dist/assets/*-da-*.js
apps/client/dist/assets/*-fi-*.js
apps/client/dist/assets/*-nb-*.js
apps/client/dist/assets/*-uk-*.js
DOCMOST_BUILDPACK_OPTIMIZATIONS
SLUGIGNORE_EOF
    step "Slugignore" "Added Docmost-specific optimizations"
  else
    step "Slugignore" "Optimizations already present, skipping"
  fi
}
