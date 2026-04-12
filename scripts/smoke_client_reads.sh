#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="${BASE:-https://fixi-edge-api.srs2800302.workers.dev/api/v1}"
ROOT="${ROOT:-https://fixi-edge-api.srs2800302.workers.dev}"
CLIENT_ID="${CLIENT_ID:-b1eef160-749d-4482-942b-92636cbd6a2f}"
OTHER_ID="${OTHER_ID:-11111111-1111-1111-1111-111111111111}"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

LAST_STATUS=""
LAST_HEADERS=""
LAST_BODY=""

request() {
  local name="$1"
  local method="$2"
  local url="$3"
  local body="${4:-}"
  shift 4 || true

  local slug
  slug=$(echo "$name" | tr ' /' '__')

  local headers_file="$TMP_DIR/${slug}.headers"
  local body_file="$TMP_DIR/${slug}.body"

  local -a curl_args
  curl_args=(-sS -D "$headers_file" -o "$body_file" -X "$method" "$url")

  if [ -n "$body" ]; then
    curl_args+=(-H "Content-Type: application/json" --data "$body")
  fi

  while [ "$#" -gt 0 ]; do
    curl_args+=(-H "$1")
    shift
  done

  curl "${curl_args[@]}" >/dev/null

  LAST_HEADERS="$headers_file"
  LAST_BODY="$body_file"
  LAST_STATUS="$(awk 'toupper($1) ~ /^HTTP\// {code=$2} END {print code}' "$headers_file")"
}

fail_step() {
  local name="$1"
  local expected="$2"

  echo "[FAIL] $name -> expected $expected, got ${LAST_STATUS:-unknown}"
  echo '--- headers ---'
  cat "$LAST_HEADERS"
  echo
  echo '--- body ---'
  cat "$LAST_BODY"
  echo
  exit 1
}

assert_status() {
  local name="$1"
  local expected="$2"

  if [ "${LAST_STATUS:-}" != "$expected" ]; then
    fail_step "$name" "$expected"
  fi

  echo "[OK] $name -> $expected"
}

assert_contains() {
  local name="$1"
  local needle="$2"

  if ! grep -Fq "$needle" "$LAST_BODY"; then
    echo "[FAIL] $name -> response missing: $needle"
    echo '--- headers ---'
    cat "$LAST_HEADERS"
    echo
    echo '--- body ---'
    cat "$LAST_BODY"
    echo
    exit 1
  fi

  echo "[OK] $name contains $needle"
}

echo '=== smoke_client_reads ==='

request "health" "GET" "$ROOT/health" ""
assert_status "health" "200"
assert_contains "health" '"success":true'

request "dashboard owner" "GET" "$BASE/users/$CLIENT_ID/dashboard" "" \
  "x-user-id: $CLIENT_ID"
assert_status "dashboard owner" "200"
assert_contains "dashboard owner" '"total_jobs":'
assert_contains "dashboard owner" '"pending_review_jobs":'

request "dashboard other" "GET" "$BASE/users/$CLIENT_ID/dashboard" "" \
  "x-user-id: $OTHER_ID"
assert_status "dashboard other" "403"
assert_contains "dashboard other" 'User has no access to this dashboard'

request "home owner" "GET" "$BASE/users/$CLIENT_ID/home" "" \
  "x-user-id: $CLIENT_ID"
assert_status "home owner" "200"
assert_contains "home owner" '"dashboard":'
assert_contains "home owner" '"recent_jobs":'
assert_contains "home owner" '"action_required_jobs":'

request "home other" "GET" "$BASE/users/$CLIENT_ID/home" "" \
  "x-user-id: $OTHER_ID"
assert_status "home other" "403"
assert_contains "home other" 'User has no access to this home data'

request "jobs-by-status owner" "GET" "$BASE/users/$CLIENT_ID/jobs-by-status" "" \
  "x-user-id: $CLIENT_ID"
assert_status "jobs-by-status owner" "200"
assert_contains "jobs-by-status owner" '"draft":'
assert_contains "jobs-by-status owner" '"open":'
assert_contains "jobs-by-status owner" '"completed":'

request "jobs-by-status other" "GET" "$BASE/users/$CLIENT_ID/jobs-by-status" "" \
  "x-user-id: $OTHER_ID"
assert_status "jobs-by-status other" "403"
assert_contains "jobs-by-status other" 'User has no access to these jobs'

echo
echo '[DONE] smoke_client_reads passed'
