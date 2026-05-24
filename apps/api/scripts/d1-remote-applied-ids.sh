#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DB_NAME="${D1_DATABASE_NAME:-fixi-db}"

"$ROOT_DIR/scripts/check-db-migrations.sh" >/dev/null

if ! command -v wrangler >/dev/null 2>&1; then
  echo "WRANGLER_NOT_AVAILABLE" >&2
  exit 2
fi

remote_json="$(wrangler d1 execute "$DB_NAME" --remote --json --command \
  "SELECT id FROM schema_migrations ORDER BY id;")"

printf '%s' "$remote_json" | node -e '
let input = "";
process.stdin.on("data", chunk => input += chunk);
process.stdin.on("end", () => {
  if (!input.trim()) {
    console.error("Remote applied migrations response is empty");
    process.exit(1);
  }

  let payload;
  try {
    payload = JSON.parse(input);
  } catch (error) {
    console.error("Remote applied migrations response is not valid JSON");
    console.error(error.message);
    process.exit(1);
  }

  if (!Array.isArray(payload)) {
    console.error("Remote applied migrations response must be a JSON array");
    process.exit(1);
  }

  const rows = payload.flatMap(item => Array.isArray(item.results) ? item.results : []);
  for (const row of rows) {
    if (row && typeof row.id === "string" && row.id.length > 0) {
      console.log(row.id);
    }
  }
});
'
