#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="${BASE:-https://fixi-edge-api.srs2800302.workers.dev/api/v1}"
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
  slug=$(echo "$name" | tr ' /()>' '______')

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

assert_status_in() {
  local name="$1"
  shift

  local actual="${LAST_STATUS:-}"
  for expected in "$@"; do
    if [ "$actual" = "$expected" ]; then
      echo "[OK] $name -> $actual"
      return 0
    fi
  done

  fail_step "$name" "one of: $*"
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

extract_json_field() {
  local field="$1"
  sed -n "s/.*\"$field\":\"\([^\"]*\)\".*/\1/p" "$LAST_BODY" | head -n 1
}

echo '=== smoke_payment_status ==='

request "create draft job" "POST" "$BASE/jobs" '{
  "title":"Payment status smoke",
  "category":"plumbing",
  "description":"Check payment status lifecycle",
  "address_text":"Pattaya",
  "budget_type":"fixed",
  "price":1000,
  "currency":"THB"
}' "x-user-id: $CLIENT_ID"
assert_status_in "create draft job" "200" "201"
assert_contains "create draft job" '"success":true'

JOB_ID="$(extract_json_field id)"
if [ -z "${JOB_ID:-}" ]; then
  echo '[FAIL] create draft job -> could not parse JOB_ID'
  cat "$LAST_BODY"
  exit 1
fi
echo "[OK] parsed JOB_ID=$JOB_ID"

request "draft payment status owner" "GET" "$BASE/jobs/$JOB_ID/payment-status" "" \
  "x-user-id: $CLIENT_ID"
assert_status "draft payment status owner" "200"
assert_contains "draft payment status owner" '"success":true'
assert_contains "draft payment status owner" '"job_status":"draft"'

request "draft payment status other" "GET" "$BASE/jobs/$JOB_ID/payment-status" "" \
  "x-user-id: $OTHER_ID"
assert_status "draft payment status other" "403"
assert_contains "draft payment status other" 'Only job participants can view payment status'

request "pay deposit" "POST" "$BASE/jobs/$JOB_ID/deposit" '{"amount":300}' \
  "x-user-id: $CLIENT_ID"
assert_status "pay deposit" "200"
assert_contains "pay deposit" '"status":"paid"'
assert_contains "pay deposit" '"job_status":"open"'

request "paid payment status owner" "GET" "$BASE/jobs/$JOB_ID/payment-status" "" \
  "x-user-id: $CLIENT_ID"
assert_status "paid payment status owner" "200"
assert_contains "paid payment status owner" '"success":true'
assert_contains "paid payment status owner" '"job_status":"open"'
assert_contains "paid payment status owner" '"payment_status":"paid"'

request "paid payment status other" "GET" "$BASE/jobs/$JOB_ID/payment-status" "" \
  "x-user-id: $OTHER_ID"
assert_status "paid payment status other" "403"
assert_contains "paid payment status other" 'Only job participants can view payment status'

request "missing payment status" "GET" "$BASE/jobs/00000000-0000-0000-0000-000000000000/payment-status" "" \
  "x-user-id: $CLIENT_ID"
assert_status "missing payment status" "404"
assert_contains "missing payment status" 'Job not found'

echo
echo '[DONE] smoke_payment_status passed'
