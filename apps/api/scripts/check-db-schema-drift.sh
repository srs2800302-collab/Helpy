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

sqlite3 "$tmpdb" < "$MIGRATIONS_DIR/0000_migration_registry.sql"
sqlite3 "$tmpdb" < "$MIGRATIONS_DIR/0001_initial_schema.sql"

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
