#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

BASE="${BASE:-https://fixi-edge-api.srs2800302.workers.dev/api/v1}"
CLIENT_ID="${CLIENT_ID:-b1eef160-749d-4482-942b-92636cbd6a2f}"
OTHER_ID="${OTHER_ID:-11111111-1111-1111-1111-111111111111}"

echo '=== HEALTH ==='
curl -i -s "https://fixi-edge-api.srs2800302.workers.dev/health"
echo
echo

echo '=== DASHBOARD OWNER ==='
curl -i -s "$BASE/users/$CLIENT_ID/dashboard" \
  -H "x-user-id: $CLIENT_ID"
echo
echo

echo '=== DASHBOARD OTHER MUST FAIL ==='
curl -i -s "$BASE/users/$CLIENT_ID/dashboard" \
  -H "x-user-id: $OTHER_ID"
echo
echo

echo '=== HOME OWNER ==='
curl -i -s "$BASE/users/$CLIENT_ID/home" \
  -H "x-user-id: $CLIENT_ID"
echo
echo

echo '=== HOME OTHER MUST FAIL ==='
curl -i -s "$BASE/users/$CLIENT_ID/home" \
  -H "x-user-id: $OTHER_ID"
echo
echo

echo '=== JOBS-BY-STATUS OWNER ==='
curl -i -s "$BASE/users/$CLIENT_ID/jobs-by-status" \
  -H "x-user-id: $CLIENT_ID"
echo
echo

echo '=== JOBS-BY-STATUS OTHER MUST FAIL ==='
curl -i -s "$BASE/users/$CLIENT_ID/jobs-by-status" \
  -H "x-user-id: $OTHER_ID"
echo
