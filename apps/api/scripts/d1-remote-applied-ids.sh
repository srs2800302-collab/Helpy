#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_NAME="${D1_DATABASE_NAME:-fixi-db}"

"$ROOT_DIR/scripts/check-db-migrations.sh" >/dev/null

if ! command -v wrangler >/dev/null 2>&1; then
  echo "WRANGLER_NOT_AVAILABLE" >&2
  exit 2
fi

wrangler d1 execute "$DB_NAME" --remote --json --command \
  "SELECT id FROM schema_migrations ORDER BY id;" \
  | node -e '
let input = "";
process.stdin.on("data", chunk => input += chunk);
process.stdin.on("end", () => {
  const payload = JSON.parse(input);
  const rows = payload.flatMap(item => item.results || []);
  for (const row of rows) {
    if (typeof row.id === "string") {
      console.log(row.id);
    }
  }
});
'
