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

parse_remote_json() {
  node -e '
let input = "";
process.stdin.on("data", chunk => input += chunk);
process.stdin.on("end", () => {
  if (!input.trim()) {
    console.error("Remote D1 response is empty");
    process.exit(1);
  }

  let payload;
  try {
    payload = JSON.parse(input);
  } catch (error) {
    console.error("Remote D1 response is not valid JSON");
    console.error(error.message);
    process.exit(1);
  }

  if (!Array.isArray(payload)) {
    console.error("Remote D1 response must be a JSON array");
    process.exit(1);
  }

  const rows = payload.flatMap(item => Array.isArray(item.results) ? item.results : []);
  console.log(JSON.stringify(rows));
});
'
}

echo "=== D1 REMOTE STATE READ-ONLY ==="
echo "Database: $DB_NAME"

echo
echo "=== schema_migrations table check ==="
registry_json="$(wrangler d1 execute "$DB_NAME" --remote --json --command \
  "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'schema_migrations';")"
registry_rows="$(printf '%s' "$registry_json" | parse_remote_json)"

if [ "$registry_rows" = "[]" ]; then
  echo "schema_migrations table is missing; treating remote state as empty"
  exit 0
fi

echo "$registry_rows"

echo
echo "=== applied migrations ==="
applied_json="$(wrangler d1 execute "$DB_NAME" --remote --json --command \
  "SELECT id, applied_at FROM schema_migrations ORDER BY id;")"
applied_rows="$(printf '%s' "$applied_json" | parse_remote_json)"
echo "$applied_rows"

echo "Remote migration state read completed"
