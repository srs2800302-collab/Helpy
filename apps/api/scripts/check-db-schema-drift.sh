#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
MIGRATIONS_DIR="$ROOT_DIR/db/migrations"

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "sqlite3 is required for canonical DB replay check"
  exit 2
fi

tmpdb="$(mktemp)"

cleanup() {
  rm -f "$tmpdb"
}
trap cleanup EXIT

while IFS= read -r migration; do
  sqlite3 "$tmpdb" < "$migration"
done < <(find "$MIGRATIONS_DIR" -maxdepth 1 -type f -name "*.sql" | sort)

fk_errors="$(sqlite3 "$tmpdb" "PRAGMA foreign_key_check;")"
if [ -n "$fk_errors" ]; then
  echo "Foreign key check failed:"
  echo "$fk_errors"
  exit 1
fi

legacy_refs="$(sqlite3 "$tmpdb" ".schema" | grep -Ei "archive|archived" || true)"
if [ -n "$legacy_refs" ]; then
  echo "Unexpected legacy references in canonical schema:"
  echo "$legacy_refs"
  exit 1
fi

echo "Canonical DB replay check passed"
