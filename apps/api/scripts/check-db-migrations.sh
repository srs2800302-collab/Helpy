#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_DIR="$ROOT_DIR/db"
MIGRATIONS_DIR="$DB_DIR/migrations"

test -f "$DB_DIR/schema.sql"
test -d "$MIGRATIONS_DIR"
test -f "$MIGRATIONS_DIR/0000_migration_registry.sql"
test -f "$MIGRATIONS_DIR/0001_initial_schema.sql"
test -f "$MIGRATIONS_DIR/MANIFEST.sha256"

# schema.sql is the canonical current end-state.
# 0001_initial_schema.sql is an immutable historical baseline.
# They are allowed to diverge after later migrations are added.

(
  cd "$MIGRATIONS_DIR"
  sha256sum -c MANIFEST.sha256
)

expected=0
while IFS= read -r file; do
  name="$(basename "$file")"
  number="${name%%_*}"

  if ! [[ "$number" =~ ^[0-9]{4}$ ]]; then
    echo "Invalid migration prefix: $name"
    exit 1
  fi

  actual=$((10#$number))
  if [ "$actual" -ne "$expected" ]; then
    echo "Migration sequence gap: expected $(printf "%04d" "$expected"), got $number"
    exit 1
  fi

  expected=$((expected + 1))
done < <(find "$MIGRATIONS_DIR" -maxdepth 1 -type f -name "*.sql" | sort)

"$ROOT_DIR/scripts/check-runtime-schema-mutations.sh"

echo "DB migrations check passed"
