#!/usr/bin/env bats

@test "postdeploy migration command is correct" {
  grep -q "pnpm nx run server:migration:latest" "../../../../example/scripts/run_migrations.sh"
}
