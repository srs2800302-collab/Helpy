#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_NAME="${D1_DATABASE_NAME:-fixi-db}"
MIGRATION_FILE="$ROOT_DIR/db/migrations/0000_migration_registry.sql"

"$ROOT_DIR/scripts/check-db-migrations.sh" >/dev/null

if ! command -v wrangler >/dev/null 2>&1; then
  echo "WRANGLER_NOT_AVAILABLE"
  exit 2
fi

echo "=== D1 BOOTSTRAP REGISTRY ==="
echo "Database: $DB_NAME"
echo "Migration: $MIGRATION_FILE"

wrangler d1 execute "$DB_NAME" --remote --file "$MIGRATION_FILE"

echo
echo "=== VERIFY REGISTRY TABLE ==="
registry_check_query="SELECT name FROM sqlite_master"
registry_check_query="$registry_check_query WHERE type = 'table' AND name = 'schema_migrations';"

wrangler d1 execute "$DB_NAME" --remote --command "$registry_check_query"

echo "D1 registry bootstrap completed"
