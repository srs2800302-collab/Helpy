#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCHEMA_MUTATION_PATTERN="CREATE TABLE|ALTER TABLE|CREATE INDEX|DROP TABLE|DROP INDEX"

violations="$(
  cd "$ROOT_DIR"
  find . \
    \( -path './dist' -o -path './node_modules' -o -path './db' \) -prune \
    -o \( -name '*.ts' -o -name '*.js' \) -type f -print0 \
    | xargs -0 grep -InE "$SCHEMA_MUTATION_PATTERN" || true
)"

if [ -n "$violations" ]; then
  echo "Runtime schema mutations are forbidden."
  echo "Use versioned D1 migrations instead."
  echo
  echo "$violations"
  exit 1
fi

echo "Runtime schema mutation guard passed"
