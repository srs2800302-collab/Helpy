#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIGRATIONS_DIR="$ROOT_DIR/db/migrations"
DB_NAME="${D1_DATABASE_NAME:-fixi-db}"

"$ROOT_DIR/scripts/check-db-migrations.sh" >/dev/null

if ! command -v wrangler >/dev/null 2>&1; then
  echo "WRANGLER_NOT_AVAILABLE"
  exit 2
fi

applied_file="$(mktemp)"
trap 'rm -f "$applied_file"' EXIT

"$ROOT_DIR/scripts/d1-remote-applied-ids.sh" > "$applied_file"

"$ROOT_DIR/scripts/d1-migration-diff.sh" "$applied_file"

echo
echo "=== D1 MIGRATION APPLY ==="
echo "Database: $DB_NAME"

while IFS= read -r file; do
  name="$(basename "$file")"

  if grep -Fxq "$name" "$applied_file"; then
    echo "[SKIP] $name"
    continue
  fi

  echo "[APPLY] $name"
  wrangler d1 execute "$DB_NAME" --remote --file "$file"

  echo "[REGISTER] $name"
  wrangler d1 execute "$DB_NAME" --remote --command \
    "INSERT OR IGNORE INTO schema_migrations (id, applied_at) VALUES ('$name', datetime('now'));"

  echo "[DONE] $name"
done < <(find "$MIGRATIONS_DIR" -maxdepth 1 -type f -name "*.sql" | sort)

echo
echo "D1 migration apply completed"
