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
  # Note: .slugignore doesn't support comments like .gitignore does
  if ! grep -q "DOCMOST_BUILDPACK_OPTIMIZATIONS" "$SLUGIGNORE_FILE" 2>/dev/null; then
    cat >> "$SLUGIGNORE_FILE" <<'SLUGIGNORE_EOF'

.git/
.gitignore
.github/
.vscode/
.idea/
.editorconfig
docs/
*.md
README*
CHANGELOG*
LICENSE*
test/
tests/
__tests__/
**/*.test.js
**/*.test.ts
**/*.spec.js
**/*.spec.ts
coverage/
.nyc_output/
jest.config.*
vitest.config.*
.env.example
.env.local
.env.development
docker-compose*.yml
Dockerfile*
.dockerignore
.prettierrc*
.eslintrc*
.eslintignore
tsconfig.json
tsconfig.*.json
apps/client/src/
apps/server/src/
packages/*/src/
*.ts
*.tsx
!*.d.ts
node_modules/.pnpm/nx@*/
node_modules/.pnpm/@nx+*/
node_modules/@nx/
node_modules/nx/
node_modules/.pnpm/vite@*/
node_modules/vite/
node_modules/.pnpm/typescript@*/
node_modules/typescript/
node_modules/.pnpm/vitest@*/
node_modules/.pnpm/jest@*/
node_modules/vitest/
node_modules/jest/
node_modules/.pnpm/concurrently@*/
node_modules/concurrently/
node_modules/.cache/
node_modules/.vite/
.pnpm-store/
.nx/
dist/.nx/
.cache/
tmp/
temp/
*.tmp
.DS_Store
*.log
dist/**/*.map
apps/client/dist/**/*.map
apps/client/dist/assets/*-[A-Z][A-Z]-*.js
!apps/client/dist/assets/en-*.js
DOCMOST_BUILDPACK_OPTIMIZATIONS
SLUGIGNORE_EOF
    step "Slugignore" "Added Docmost-specific optimizations"
  else
    step "Slugignore" "Optimizations already present, skipping"
  fi
}
