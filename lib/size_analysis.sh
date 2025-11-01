#!/usr/bin/env bash
set -e
trap 'echo "[ERROR] $0 failed at line $LINENO: $BASH_COMMAND" >&2' ERR
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# NOTE: This size analysis runs BEFORE the nodejs-buildpack builds the application.
# At this point, we only see the source code that was downloaded by this buildpack.
#
# To analyze the FINAL slug size (after build and before .slugignore processing),
# you would need to add this buildpack TWICE in .buildpacks:
#   1. https://github.com/yanjost/docmost-buildpack  (downloads source, configures)
#   2. https://github.com/Scalingo/nodejs-buildpack   (builds with pnpm)
#   3. https://github.com/yanjost/docmost-buildpack  (analyzes final size)
#
# However, the current approach still works for verifying what was downloaded.

analyze_slug_size() {
  local build_dir="${1:-$BUILD_DIR}"

  # Only run if DOCMOST_DEBUG_SIZE is set
  if [[ "${DOCMOST_DEBUG_SIZE:-}" != "true" ]]; then
    return 0
  fi

  step "Size Analysis" "Starting detailed size analysis (DOCMOST_DEBUG_SIZE=true)"
  step "Size Analysis" "NOTE: Running before nodejs-buildpack build - showing source size only"

  echo ""
  echo "========================================"
  echo "SLUG SIZE ANALYSIS"
  echo "========================================"
  echo ""

  # Overall size
  echo ">>> Total build directory size:"
  du -sh "$build_dir" 2>/dev/null || echo "Could not calculate total size"
  echo ""

  # Top 20 largest directories
  echo ">>> Top 20 largest directories:"
  du -h "$build_dir" 2>/dev/null | sort -hr | head -20
  echo ""

  # node_modules breakdown
  if [[ -d "$build_dir/node_modules" ]]; then
    echo ">>> node_modules total size:"
    du -sh "$build_dir/node_modules" 2>/dev/null || echo "Could not calculate"
    echo ""

    echo ">>> Top 20 largest packages in node_modules:"
    find "$build_dir/node_modules" -maxdepth 2 -type d -exec du -sh {} \; 2>/dev/null | sort -hr | head -20
    echo ""

    if [[ -d "$build_dir/node_modules/.pnpm" ]]; then
      echo ">>> .pnpm virtual store size:"
      du -sh "$build_dir/node_modules/.pnpm" 2>/dev/null || echo "Could not calculate"
      echo ""

      echo ">>> Top 20 largest packages in .pnpm:"
      find "$build_dir/node_modules/.pnpm" -maxdepth 1 -type d -exec du -sh {} \; 2>/dev/null | sort -hr | head -20
      echo ""
    fi

    echo ">>> @types packages (should be removed in production):"
    du -sh "$build_dir/node_modules/@types" 2>/dev/null || echo "Not found (good!)"
    du -sh "$build_dir/node_modules/.pnpm/@types+"* 2>/dev/null | head -10 || echo "Not found in .pnpm (good!)"
    echo ""

    echo ">>> Dev tool packages (should be removed):"
    for pkg in "nx" "vite" "typescript" "eslint" "prettier" "@nestjs/cli" "@nestjs/testing" "jest" "webpack" "rollup" "esbuild" "@swc" "tsx"; do
      local size=$(du -sh "$build_dir/node_modules/$pkg" 2>/dev/null | cut -f1 || echo "")
      if [[ -n "$size" ]]; then
        echo "  - $pkg: $size"
      fi
    done
    echo ""
  fi

  # apps/ breakdown
  if [[ -d "$build_dir/apps" ]]; then
    echo ">>> apps/ directory breakdown:"
    find "$build_dir/apps" -maxdepth 2 -type d -exec du -sh {} \; 2>/dev/null | sort -hr | head -10
    echo ""

    if [[ -d "$build_dir/apps/client/dist" ]]; then
      echo ">>> Client dist size:"
      du -sh "$build_dir/apps/client/dist" 2>/dev/null || echo "Not found"
      echo ""

      echo ">>> Client dist assets (locale files):"
      du -sh "$build_dir/apps/client/dist/assets" 2>/dev/null || echo "Not found"
      ls -lh "$build_dir/apps/client/dist/assets/"*-*.js 2>/dev/null | head -20 || echo "No locale files found"
      echo ""
    fi

    if [[ -d "$build_dir/apps/server/dist" ]]; then
      echo ">>> Server dist size:"
      du -sh "$build_dir/apps/server/dist" 2>/dev/null || echo "Not found"
      echo ""
    fi

    # Check if src directories still exist (they shouldn't)
    echo ">>> Source directories (should NOT exist):"
    for src_dir in "$build_dir/apps/client/src" "$build_dir/apps/server/src"; do
      if [[ -d "$src_dir" ]]; then
        echo "  ⚠️  FOUND: $src_dir ($(du -sh "$src_dir" 2>/dev/null | cut -f1))"
      fi
    done
    echo ""
  fi

  # packages/ breakdown
  if [[ -d "$build_dir/packages" ]]; then
    echo ">>> packages/ directory breakdown:"
    find "$build_dir/packages" -maxdepth 2 -type d -exec du -sh {} \; 2>/dev/null | sort -hr | head -10
    echo ""
  fi

  # Check for files that should be removed
  echo ">>> Files that should be in .slugignore:"
  local should_not_exist=(
    ".git"
    ".nx"
    ".cache"
    "pnpm-lock.yaml"
    "nx.json"
    "patches"
    "node_modules/.modules.yaml"
  )
  for item in "${should_not_exist[@]}"; do
    if [[ -e "$build_dir/$item" ]]; then
      local size=$(du -sh "$build_dir/$item" 2>/dev/null | cut -f1 || echo "?")
      echo "  ⚠️  FOUND: $item ($size)"
    fi
  done
  echo ""

  # Count TypeScript files (should be minimal)
  echo ">>> TypeScript source files (should be minimal):"
  local ts_count=$(find "$build_dir" -name "*.ts" -o -name "*.tsx" 2>/dev/null | wc -l | tr -d ' ')
  local ts_size=$(find "$build_dir" -name "*.ts" -o -name "*.tsx" -exec du -ch {} \; 2>/dev/null | tail -1 | cut -f1 || echo "0")
  echo "  Found $ts_count TypeScript files, total size: $ts_size"
  if [[ $ts_count -gt 100 ]]; then
    echo "  ⚠️  Warning: Many TS files found. Showing first 20:"
    find "$build_dir" -name "*.ts" -o -name "*.tsx" 2>/dev/null | head -20
  fi
  echo ""

  # Source maps
  echo ">>> Source map files (.map):"
  local map_count=$(find "$build_dir" -name "*.map" 2>/dev/null | wc -l | tr -d ' ')
  local map_size=$(find "$build_dir" -name "*.map" -exec du -ch {} \; 2>/dev/null | tail -1 | cut -f1 || echo "0")
  echo "  Found $map_count source maps, total size: $map_size"
  echo ""

  # Summary of what will be in .slugignore
  if [[ -f "$build_dir/.slugignore" ]]; then
    echo ">>> .slugignore file content:"
    cat "$build_dir/.slugignore"
    echo ""
  fi

  echo "========================================"
  echo "END SIZE ANALYSIS"
  echo "========================================"
  echo ""
}
