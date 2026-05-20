#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_DIR="$ROOT_DIR/db"
MIGRATIONS_DIR="$DB_DIR/migrations"

"$ROOT_DIR/scripts/check-db-migrations.sh" >/dev/null

echo "=== D1 MIGRATION PLAN ==="

expected=0

while IFS= read -r file; do
  name="$(basename "$file")"
  number="${name%%_*}"

  actual=$((10#$number))

  if [ "$actual" -ne "$expected" ]; then
    echo "Sequence error at $name"
    exit 1
  fi

  echo "[PENDING/KNOWN] $name"

  expected=$((expected + 1))

done < <(
  find "$MIGRATIONS_DIR" \
    -maxdepth 1 \
    -type f \
    -name "*.sql" \
    | sort
)

echo
echo "Migration plan inspection completed"
