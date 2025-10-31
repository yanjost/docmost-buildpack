#!/usr/bin/env bash
set -e

echo "Init environment"
mkdir -p /tmp/{env,cache}

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

echo "Node.js buildpack build completed, start release phase"
/buildpack/bin/release /app
