#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MIGRATIONS_DIR="$ROOT_DIR/db/migrations"
APPLIED_FILE="${1:-}"

"$ROOT_DIR/scripts/check-db-migrations.sh" >/dev/null

if [ "${APPLIED_FILE:-}" = "--help" ] || [ "${APPLIED_FILE:-}" = "-h" ]; then
  echo "Usage: $0 <applied-migrations-file>"
  echo
  echo "File format:"
  echo "  one migration id per line"
  echo
  echo "Examples:"
  echo "  npm run db:diff -- ./applied-migrations.txt"
  echo "  ./scripts/d1-migration-diff.sh ./applied-migrations.txt"
  exit 0
fi

if [ -z "$APPLIED_FILE" ] || [ ! -f "$APPLIED_FILE" ]; then
  echo "Usage: $0 <applied-migrations-file>"
  echo "Run with --help for examples."
  exit 2
fi

echo "=== D1 MIGRATION DIFF ==="

unknown_remote=0
applied_count=0
pending_count=0
unknown_remote_count=0

while IFS= read -r file; do
  name="$(basename "$file")"

  if grep -Fxq "$name" "$APPLIED_FILE"; then
    echo "[APPLIED] $name"
    applied_count=$((applied_count + 1))
  else
    echo "[PENDING] $name"
    pending_count=$((pending_count + 1))
  fi
done < <(find "$MIGRATIONS_DIR" -maxdepth 1 -type f -name "*.sql" | sort)

while IFS= read -r applied; do
  [ -z "$applied" ] && continue

  if [ ! -f "$MIGRATIONS_DIR/$applied" ]; then
    echo "[UNKNOWN_REMOTE] $applied"
    unknown_remote=1
    unknown_remote_count=$((unknown_remote_count + 1))
  fi
done < "$APPLIED_FILE"

echo
echo "applied_count=$applied_count"
echo "pending_count=$pending_count"
echo "unknown_remote_count=$unknown_remote_count"

if [ "$unknown_remote" -ne 0 ]; then
  echo "Remote migration drift detected"
  exit 1
fi
