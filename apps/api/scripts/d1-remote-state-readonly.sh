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

echo
echo "=== schema_migrations table check ==="
if wrangler d1 execute "$DB_NAME" --remote --command \
  "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'schema_migrations';"; then
  echo "schema_migrations table check completed"
else
  echo "Unable to verify schema_migrations table"
fi

echo
echo "=== applied migrations ==="
if wrangler d1 execute "$DB_NAME" --remote --command \
  "SELECT id, applied_at FROM schema_migrations ORDER BY id;"; then
  echo "Remote migration state read completed"
else
  echo "schema_migrations is missing or unreadable; treating remote state as empty"
fi
