#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DB_DIR="$ROOT_DIR/db"
MIGRATIONS_DIR="$DB_DIR/migrations"

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "sqlite3 is required for DB schema drift check"
  exit 2
fi

schema_db="$(mktemp)"
migrated_db="$(mktemp)"
schema_out="$(mktemp)"
migrated_out="$(mktemp)"

cleanup() {
  rm -f \
    "$schema_db" \
    "$migrated_db" \
    "$schema_out" \
    "$migrated_out"
}
trap cleanup EXIT

sqlite3 "$schema_db" < "$DB_DIR/schema.sql"

for file in "$MIGRATIONS_DIR"/*.sql; do
  sqlite3 "$migrated_db" < "$file"
done

dump_schema() {
  local db="$1"
  sqlite3 "$db" \
    "SELECT type || ' ' || name || ' ' || tbl_name || ' ' ||
            replace(replace(sql, char(10), ' '), char(13), ' ')
     FROM sqlite_schema
     WHERE sql IS NOT NULL
       AND name NOT LIKE 'sqlite_%'
     ORDER BY type, name;" \
    | python3 -c 'import re, sys; print("\n".join(re.sub(r"CREATE TABLE \"([^\"]+)\"", r"CREATE TABLE \1", re.sub(r"\s+", " ", line).replace(" ,", ",").replace(" )", ")")).strip() for line in sys.stdin if line.strip()))'
}

dump_schema "$schema_db" > "$schema_out"
dump_schema "$migrated_db" > "$migrated_out"

if ! diff -u "$schema_out" "$migrated_out"; then
  echo "DB schema drift detected:"
  echo "db/schema.sql differs from applied migrations result"
  exit 1
fi

echo "DB schema drift check passed"
