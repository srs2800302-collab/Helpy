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
    \"address_text\": \"Pattaya\",
    \"price\": 1200,
    \"currency\": \"THB\"
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
  -d '{}')
echo "$DEPOSIT_JSON"

echo
echo "== create offer =="
OFFER_JSON=$(curl -s -X POST "$BASE_URL/jobs/$JOB_ID/offers" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $MASTER_ID" \
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
SELECT_JSON=$(curl -s -X POST "$BASE_URL/jobs/$JOB_ID/select-offer" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $CLIENT_ID" \
  -d "{
    \"offer_id\": \"$OFFER_ID\"
  }")
echo "$SELECT_JSON"

echo
echo "== read messages as client =="
MESSAGES_CLIENT_JSON=$(curl -s "$BASE_URL/jobs/$JOB_ID/messages" \
  -H "x-user-id: $CLIENT_ID")
echo "$MESSAGES_CLIENT_JSON"

echo
echo "== send message as client =="
SEND_MESSAGE_JSON=$(curl -s -X POST "$BASE_URL/jobs/$JOB_ID/messages" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $CLIENT_ID" \
  -d "{
    \"text\": \"Smoke test message\"
  }")
echo "$SEND_MESSAGE_JSON"

echo
echo "== read messages as master =="
MESSAGES_MASTER_JSON=$(curl -s "$BASE_URL/jobs/$JOB_ID/messages" \
  -H "x-user-id: $MASTER_ID")
echo "$MESSAGES_MASTER_JSON"

echo
echo "== start work =="
START_WORK_JSON=$(curl -s -X POST "$BASE_URL/jobs/$JOB_ID/start-work" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $MASTER_ID" \
  -d '{}')
echo "$START_WORK_JSON"

echo
echo "== complete job =="
COMPLETE_JSON=$(curl -s -X POST "$BASE_URL/jobs/$JOB_ID/complete" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $CLIENT_ID" \
  -d '{}')
echo "$COMPLETE_JSON"

echo
echo "== create review =="
REVIEW_JSON=$(curl -s -X POST "$BASE_URL/jobs/$JOB_ID/reviews" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $CLIENT_ID" \
  -d "{
    \"master_user_id\": \"$MASTER_ID\",
    \"rating\": 5,
    \"comment\": \"Smoke review\"
  }")
echo "$REVIEW_JSON"

echo
echo "== final job state =="
FINAL_JOB_JSON=$(curl -s "$BASE_URL/jobs/$JOB_ID" \
  -H "x-user-id: $CLIENT_ID")
echo "$FINAL_JOB_JSON"

if ! echo "$FINAL_JOB_JSON" | grep -q '"success":true'; then
  echo "FAILED: final job read is not successful"
  exit 1
fi

if ! echo "$FINAL_JOB_JSON" | grep -q '"status":"completed"'; then
  echo "FAILED: final job status is not completed"
  exit 1
fi

echo
echo "SMOKE OK: $JOB_ID"
