#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="${BASE:-https://fixi-edge-api.srs2800302.workers.dev/api/v1}"
CLIENT_ID="${CLIENT_ID:-b1eef160-749d-4482-942b-92636cbd6a2f}"
MASTER_ID="${MASTER_ID:-2cb75bef-d020-4b33-ad76-8573346f6f82}"
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

echo '=== smoke_job_actions ==='

request "create awaiting payment job" "POST" "$BASE/jobs" '{
  "title":"Actions lifecycle smoke",
  "category":"plumbing",
  "description":"Full actions lifecycle smoke",
  "address_text":"Pattaya",
  "budget_type":"fixed",
  "price":1000,
  "currency":"THB"
}' "x-user-id: $CLIENT_ID"
assert_status_in "create awaiting payment job" "200" "201"
assert_contains "create awaiting payment job" '"success":true'
assert_contains "create awaiting payment job" '"status":"awaiting_payment"'

JOB_ID="$(extract_json_field id)"
if [ -z "${JOB_ID:-}" ]; then
  echo '[FAIL] create awaiting payment job -> could not parse JOB_ID'
  cat "$LAST_BODY"
  exit 1
fi
echo "[OK] parsed JOB_ID=$JOB_ID"

request "awaiting payment actions" "GET" "$BASE/jobs/$JOB_ID/actions" "" \
  "x-user-id: $CLIENT_ID"
assert_status "awaiting payment actions" "200"
assert_contains "awaiting payment actions" '"status":"awaiting_payment"'
assert_contains "awaiting payment actions" '"actions":[]'

request "pay deposit" "POST" "$BASE/jobs/$JOB_ID/deposit" '{}' \
  "x-user-id: $CLIENT_ID"
assert_status "pay deposit" "200"
assert_contains "pay deposit" '"job_status":"open"'

request "open actions" "GET" "$BASE/jobs/$JOB_ID/actions" "" \
  "x-user-id: $CLIENT_ID"
assert_status "open actions" "200"
assert_contains "open actions" '"status":"open"'
assert_contains "open actions" '"view_offers"'
assert_contains "open actions" '"cancel_job"'

request "create offer" "POST" "$BASE/jobs/$JOB_ID/offers" "{\"master_user_id\":\"$MASTER_ID\",\"master_name\":\"Alex\",\"price\":1000}" \
  "x-user-id: $MASTER_ID"
assert_status_in "create offer" "200" "201"
assert_contains "create offer" '"success":true'

OFFER_ID="$(extract_json_field id)"
if [ -z "${OFFER_ID:-}" ]; then
  echo '[FAIL] create offer -> could not parse OFFER_ID'
  cat "$LAST_BODY"
  exit 1
fi
echo "[OK] parsed OFFER_ID=$OFFER_ID"

request "select offer" "POST" "$BASE/jobs/$JOB_ID/select-offer" "{\"offer_id\":\"$OFFER_ID\"}" \
  "x-user-id: $CLIENT_ID"
assert_status "select offer" "200"
assert_contains "select offer" '"status":"master_selected"'

request "master selected actions" "GET" "$BASE/jobs/$JOB_ID/actions" "" \
  "x-user-id: $CLIENT_ID"
assert_status "master selected actions" "200"
assert_contains "master selected actions" '"status":"master_selected"'
assert_contains "master selected actions" '"view_selected_master"'
assert_contains "master selected actions" '"open_chat"'
assert_contains "master selected actions" '"cancel_job"'
assert_contains "master selected actions" '"complete_job"'

request "start work" "POST" "$BASE/jobs/$JOB_ID/start-work" "" \
  "x-user-id: $MASTER_ID"
assert_status "start work" "200"
assert_contains "start work" '"status":"in_progress"'

request "in progress actions" "GET" "$BASE/jobs/$JOB_ID/actions" "" \
  "x-user-id: $CLIENT_ID"
assert_status "in progress actions" "200"
assert_contains "in progress actions" '"status":"in_progress"'
assert_contains "in progress actions" '"view_selected_master"'
assert_contains "in progress actions" '"open_chat"'
assert_contains "in progress actions" '"create_dispute"'
assert_contains "in progress actions" '"cancel_job"'
assert_contains "in progress actions" '"complete_job"'

request "complete job" "POST" "$BASE/jobs/$JOB_ID/complete" '{}' \
  "x-user-id: $CLIENT_ID"
assert_status "complete job" "200"
assert_contains "complete job" '"status":"completed"'

request "completed actions" "GET" "$BASE/jobs/$JOB_ID/actions" "" \
  "x-user-id: $CLIENT_ID"
assert_status "completed actions" "200"
assert_contains "completed actions" '"status":"completed"'
assert_contains "completed actions" '"leave_review"'

request "create review" "POST" "$BASE/jobs/$JOB_ID/reviews" "{\"master_user_id\":\"$MASTER_ID\",\"rating\":5,\"comment\":\"good\"}" \
  "x-user-id: $CLIENT_ID"
assert_status_in "create review" "200" "201"
assert_contains "create review" '"success":true'

request "reviewed actions" "GET" "$BASE/jobs/$JOB_ID/actions" "" \
  "x-user-id: $CLIENT_ID"
assert_status "reviewed actions" "200"
assert_contains "reviewed actions" '"status":"completed"'
assert_contains "reviewed actions" '"view_review"'

request "other user actions" "GET" "$BASE/jobs/$JOB_ID/actions" "" \
  "x-user-id: $OTHER_ID"
assert_status "other user actions" "403"
assert_contains "other user actions" 'User has no access to this job actions'

request "missing job actions" "GET" "$BASE/jobs/00000000-0000-0000-0000-000000000000/actions" "" \
  "x-user-id: $CLIENT_ID"
assert_status "missing job actions" "404"
assert_contains "missing job actions" 'Job not found'

echo
echo '[DONE] smoke_job_actions passed'
