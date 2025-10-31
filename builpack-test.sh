#!/usr/bin/env bash
echo "Init environment"
mkdir /tmp/{env,cache}
echo "Start buildpack detection"
/buildpack/bin/detect /app
RETCODE=$?
if [ $RETCODE -ne 0 ]; then
  echo "Buildpack not detected, exiting with code $RETCODE"
  exit $RETCODE
fi
echo "Buildpack detected, start build"
/buildpack/bin/compile /app /tmp/cache /tmp/env
RETCODE=$?
if [ $RETCODE -ne 0 ]; then
  echo "Build failed during compile phase, exiting with code $RETCODE"
  exit $RETCODE
fi
echo "Build completed, start release phase"
/buildpack/bin/release /app