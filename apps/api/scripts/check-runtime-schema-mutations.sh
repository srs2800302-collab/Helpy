#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

allowed_files='^(src/(chat|disputes|job-photos|jobs|offers|payments|payment-methods|reviews|stripe-setup|stripe-webhook|translation)\.ts)$'

violations="$(
  cd "$ROOT_DIR"
  { grep -RInE "CREATE TABLE|ALTER TABLE|CREATE INDEX|DROP TABLE|DROP INDEX" src --include="*.ts" || true; } \
    | while IFS= read -r line; do
        file="${line%%:*}"
        if ! printf '%s\n' "$file" | grep -Eq "$allowed_files"; then
          printf '%s\n' "$line"
        fi
      done
)"

if [ -n "$violations" ]; then
  echo "Runtime schema mutations are forbidden outside the legacy allowlist."
  echo
  echo "$violations"
  exit 1
fi

echo "Runtime schema mutation guard passed"
