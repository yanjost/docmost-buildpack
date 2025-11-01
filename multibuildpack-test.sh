#!/usr/bin/env bash
set -e

echo "Init environment"
mkdir -p /tmp/{env,cache}

# Set required environment variables
echo "v0.23.2" > /tmp/env/DOCMOST_VERSION
echo "postgres://user:pass@localhost/db" > /tmp/env/DATABASE_URL
echo "redis://localhost:6379" > /tmp/env/REDIS_URL

# Clone the Node.js buildpack
echo "Cloning Node.js buildpack..."
git clone --depth 1 https://github.com/Scalingo/nodejs-buildpack.git /tmp/nodejs-buildpack

# Run Docmost buildpack first (to download the application)
echo "=== Running Docmost buildpack (buildpack 1/2) ==="
echo "Start buildpack detection"
/buildpack/bin/detect /app
RETCODE=$?
if [ $RETCODE -ne 0 ]; then
  echo "Docmost buildpack not detected, exiting with code $RETCODE"
  exit $RETCODE
fi

echo "Docmost buildpack detected, start build"
/buildpack/bin/compile /app /tmp/cache /tmp/env
RETCODE=$?
if [ $RETCODE -ne 0 ]; then
  echo "Build failed during Docmost compile phase, exiting with code $RETCODE"
  exit $RETCODE
fi

echo "Docmost buildpack build completed"
echo ""

# Run Node.js buildpack second (to build JavaScript assets)
echo "=== Running Node.js buildpack (buildpack 2/2) ==="
echo "Start buildpack detection"
/tmp/nodejs-buildpack/bin/detect /app
RETCODE=$?
if [ $RETCODE -ne 0 ]; then
  echo "Node.js buildpack not detected, exiting with code $RETCODE"
  exit $RETCODE
fi

echo "Node.js buildpack detected, start build"
/tmp/nodejs-buildpack/bin/compile /app /tmp/cache /tmp/env
RETCODE=$?
if [ $RETCODE -ne 0 ]; then
  echo "Build failed during Node.js compile phase, exiting with code $RETCODE"
  exit $RETCODE
fi

echo "Node.js buildpack build completed"
echo ""
echo "=== Analyzing disk usage ==="
echo "Total size (before .slugignore):"
du -sh /app
echo ""
echo "Top 20 largest directories:"
du -h /app | sort -rh | head -20
echo ""
echo "Top 20 largest files:"
find /app -type f -exec du -h {} + | sort -rh | head -20
echo ""

# Check if .slugignore was created
if [[ -f /app/.slugignore ]]; then
  echo "=== .slugignore file was created ==="
  echo "First 30 lines of .slugignore:"
  head -30 /app/.slugignore
  echo ""
  echo "Simulating .slugignore exclusions..."

  # Create a temporary directory to simulate slug
  SLUG_SIM=/tmp/slug-simulation
  rm -rf "$SLUG_SIM"
  mkdir -p "$SLUG_SIM"

  # Copy everything first
  cp -a /app/. "$SLUG_SIM/"

  # Remove files matching .slugignore patterns
  while IFS= read -r pattern; do
    # Skip comments and empty lines
    [[ "$pattern" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$pattern" ]] && continue
    # Skip negation patterns (!) for this simple simulation
    [[ "$pattern" =~ ^! ]] && continue

    # Remove matching files/directories
    find "$SLUG_SIM" -path "$SLUG_SIM/$pattern" -prune -exec rm -rf {} + 2>/dev/null || true
  done < /app/.slugignore

  echo "Estimated slug size (after .slugignore):"
  du -sh "$SLUG_SIM"
  echo ""

  # Calculate savings
  BEFORE_KB=$(du -sk /app | cut -f1)
  AFTER_KB=$(du -sk "$SLUG_SIM" | cut -f1)
  SAVED_KB=$((BEFORE_KB - AFTER_KB))
  SAVED_MB=$((SAVED_KB / 1024))

  echo "Estimated savings: ${SAVED_MB}MB"
  echo ""
else
  echo "WARNING: .slugignore was not created!"
  echo ""
fi

echo "=== Build complete - inspect /app directory ==="
echo "Press Enter to continue to release phase, or Ctrl+C to exit and inspect"
read

echo "Start release phase"
/buildpack/bin/release /app
