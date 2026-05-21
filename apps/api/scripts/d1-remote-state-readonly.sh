#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_NAME="${D1_DATABASE_NAME:-fixi-db}"

"$ROOT_DIR/scripts/check-db-migrations.sh" >/dev/null

if ! command -v wrangler >/dev/null 2>&1; then
  echo "WRANGLER_NOT_AVAILABLE"
  echo "Remote D1 state can be checked only in an environment with Wrangler installed."
  exit 2
fi

echo "=== D1 REMOTE STATE READ-ONLY ==="
echo "Database: $DB_NAME"

table_check_output="$(mktemp)"
applied_output="$(mktemp)"
trap 'rm -f "$table_check_output" "$applied_output"' EXIT

echo
echo "=== schema_migrations table check ==="

schema_table_query="SELECT 'schema_migrations_exists' AS marker FROM sqlite_master"
schema_table_query="$schema_table_query WHERE type = 'table' AND name = 'schema_migrations';"

if ! wrangler d1 execute "$DB_NAME" --remote --command "$schema_table_query" \
  >"$table_check_output" 2>&1; then
  cat "$table_check_output"
  echo "Remote D1 access check failed"
  exit 1
fi

cat "$table_check_output"

if ! grep -q "schema_migrations_exists" "$table_check_output"; then
  echo "schema_migrations table is missing; treating remote state as empty"
  exit 0
fi

echo
echo "=== applied migrations ==="

if ! wrangler d1 execute "$DB_NAME" --remote --command \
  "SELECT id, applied_at FROM schema_migrations ORDER BY id;" \
  >"$applied_output" 2>&1; then
  cat "$applied_output"
  echo "Remote D1 applied migrations read failed"
  exit 1
fi

cat "$applied_output"
echo "Remote migration state read completed"
