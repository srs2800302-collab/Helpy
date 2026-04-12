#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE_URL="https://fixi-edge-api.srs2800302.workers.dev/api/v1"
CLIENT_ID="b1eef160-749d-4482-942b-92636cbd6a2f"
MASTER_ID="2cb75bef-d020-4b33-ad76-8573346f6f82"
MASTER_NAME="Alex"

echo "== create job =="
JOB_JSON=$(curl -s -X POST "$BASE_URL/jobs" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $CLIENT_ID" \
  -d "{
    \"title\": \"Smoke lifecycle job\",
    \"category\": \"plumbing\",
    \"description\": \"Smoke test from Termux\",
    \"address_text\": \"Pattaya\"
  }")
echo "$JOB_JSON"
JOB_ID=$(echo "$JOB_JSON" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')

if [ -z "${JOB_ID:-}" ]; then
  echo "FAILED: job_id not found"
  exit 1
fi

echo
echo "== pay deposit =="
DEPOSIT_JSON=$(curl -s -X POST "$BASE_URL/jobs/$JOB_ID/deposit" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $CLIENT_ID" \
  -d "{
    \"amount\": 500,
    \"currency\": \"THB\"
  }")
echo "$DEPOSIT_JSON"

echo
echo "== create offer =="
OFFER_JSON=$(curl -s -X POST "$BASE_URL/jobs/$JOB_ID/offers" \
  -H "Content-Type: application/json" \
  -d "{
    \"master_user_id\": \"$MASTER_ID\",
    \"master_name\": \"$MASTER_NAME\",
    \"price\": 1200
  }")
echo "$OFFER_JSON"
OFFER_ID=$(echo "$OFFER_JSON" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')

if [ -z "${OFFER_ID:-}" ]; then
  echo "FAILED: offer_id not found"
  exit 1
fi

echo
echo "== select offer =="
curl -s -X POST "$BASE_URL/jobs/$JOB_ID/select-offer" \
  -H "Content-Type: application/json" \
  -d "{
    \"offer_id\": \"$OFFER_ID\"
  }"
echo

echo
echo "== read messages as client =="
curl -s "$BASE_URL/jobs/$JOB_ID/messages" \
  -H "x-user-id: $CLIENT_ID"
echo

echo
echo "== send message as client =="
curl -s -X POST "$BASE_URL/jobs/$JOB_ID/messages" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $CLIENT_ID" \
  -d "{
    \"text\": \"Smoke test message\"
  }"
echo

echo
echo "== read messages as master =="
curl -s "$BASE_URL/jobs/$JOB_ID/messages" \
  -H "x-user-id: $MASTER_ID"
echo

echo
echo "== start work =="
curl -s -X POST "$BASE_URL/jobs/$JOB_ID/start-work" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $MASTER_ID" \
  -d '{}'
echo

echo
echo "== complete job =="
curl -s -X POST "$BASE_URL/jobs/$JOB_ID/complete" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $CLIENT_ID" \
  -d '{}'
echo

echo
echo "== create review =="
curl -s -X POST "$BASE_URL/jobs/$JOB_ID/reviews" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $CLIENT_ID" \
  -d "{
    \"master_user_id\": \"$MASTER_ID\",
    \"rating\": 5,
    \"comment\": \"Smoke review\"
  }"
echo

echo
echo "== final job state =="
curl -s "$BASE_URL/jobs/$JOB_ID"
echo

echo
echo "SMOKE OK: $JOB_ID"
