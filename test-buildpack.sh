#!/usr/bin/env bash
set -e
docker run --pull always --rm --interactive --tty \
--env STACK=scalingo-22 \
--env DOCMOST_VERSION=v0.23.2 \
--env DATABASE_URL=postgresql://user:password@localhost:5432/dbname \
--env REDIS_URL=redis://localhost:6379 \
--volume .:/buildpack \
--volume ../docmost-on-scalingo:/build \
scalingo/scalingo-22:latest bash -c "/buildpack/builpack-test.sh || bash"
