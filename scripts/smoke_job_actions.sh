#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="${BASE:-https://fixi-edge-api.srs2800302.workers.dev/api/v1}"
CLIENT_ID="${CLIENT_ID:-b1eef160-749d-4482-942b-92636cbd6a2f}"
MASTER_ID="${MASTER_ID:-2cb75bef-d020-4b33-ad76-8573346f6f82}"
OTHER_ID="${OTHER_ID:-11111111-1111-1111-1111-111111111111}"

echo '=== 1) CREATE DRAFT JOB ==='
JOB=$(curl -s -X POST "$BASE/jobs" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $CLIENT_ID" \
  -d '{
    "title":"Actions lifecycle smoke",
    "category":"plumbing",
    "description":"Full actions lifecycle smoke",
    "address_text":"Pattaya",
    "budget_type":"fixed",
    "price":1000,
    "currency":"THB"
  }')
echo "$JOB"
echo

JOB_ID=$(echo "$JOB" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')

if [ -z "${JOB_ID:-}" ]; then
  echo 'FAILED: could not parse JOB_ID'
  exit 1
fi

echo "JOB_ID=$JOB_ID"
echo

echo '=== 2) DRAFT ACTIONS ==='
curl -i -s "$BASE/jobs/$JOB_ID/actions" \
  -H "x-user-id: $CLIENT_ID"
echo
echo

echo '=== 3) PAY DEPOSIT -> OPEN ==='
curl -s -X POST "$BASE/jobs/$JOB_ID/deposit" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $CLIENT_ID" \
  -d '{"amount":300}'
echo
echo

echo '=== 4) OPEN ACTIONS ==='
curl -i -s "$BASE/jobs/$JOB_ID/actions" \
  -H "x-user-id: $CLIENT_ID"
echo
echo

echo '=== 5) MASTER SENDS OFFER ==='
OFFER=$(curl -s -X POST "$BASE/jobs/$JOB_ID/offers" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $MASTER_ID" \
  -d '{"master_name":"Alex","price":1000}')
echo "$OFFER"
echo

OFFER_ID=$(echo "$OFFER" | sed -n 's/.*"id":"\([^"]*\)".*/\1/p')

if [ -z "${OFFER_ID:-}" ]; then
  echo 'FAILED: could not parse OFFER_ID'
  exit 1
fi

echo "OFFER_ID=$OFFER_ID"
echo

echo '=== 6) SELECT OFFER -> MASTER_SELECTED ==='
curl -s -X POST "$BASE/jobs/$JOB_ID/select-offer" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $CLIENT_ID" \
  -d "{\"offer_id\":\"$OFFER_ID\"}"
echo
echo

echo '=== 7) MASTER_SELECTED ACTIONS ==='
curl -i -s "$BASE/jobs/$JOB_ID/actions" \
  -H "x-user-id: $CLIENT_ID"
echo
echo

echo '=== 8) START WORK -> IN_PROGRESS ==='
curl -s -X POST "$BASE/jobs/$JOB_ID/start-work" \
  -H "x-user-id: $MASTER_ID"
echo
echo

echo '=== 9) IN_PROGRESS ACTIONS ==='
curl -i -s "$BASE/jobs/$JOB_ID/actions" \
  -H "x-user-id: $CLIENT_ID"
echo
echo

echo '=== 10) COMPLETE JOB ==='
curl -s -X POST "$BASE/jobs/$JOB_ID/complete" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $CLIENT_ID" \
  -d '{}'
echo
echo

echo '=== 11) COMPLETED ACTIONS ==='
curl -i -s "$BASE/jobs/$JOB_ID/actions" \
  -H "x-user-id: $CLIENT_ID"
echo
echo

echo '=== 12) CREATE REVIEW ==='
curl -s -X POST "$BASE/jobs/$JOB_ID/reviews" \
  -H "Content-Type: application/json" \
  -H "x-user-id: $CLIENT_ID" \
  -d "{\"master_user_id\":\"$MASTER_ID\",\"rating\":5,\"comment\":\"good\"}"
echo
echo

echo '=== 13) REVIEWED ACTIONS ==='
curl -i -s "$BASE/jobs/$JOB_ID/actions" \
  -H "x-user-id: $CLIENT_ID"
echo
echo

echo '=== 14) OTHER USER MUST FAIL ==='
curl -i -s "$BASE/jobs/$JOB_ID/actions" \
  -H "x-user-id: $OTHER_ID"
echo
echo

echo '=== 15) MISSING JOB MUST FAIL ==='
curl -i -s "$BASE/jobs/00000000-0000-0000-0000-000000000000/actions" \
  -H "x-user-id: $CLIENT_ID"
echo
