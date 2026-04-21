#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

PROJECT_DIR="/data/data/com.termux/files/home/projects/helpy"
LOG_DIR="$PROJECT_DIR/.tmp_diag"
TS="$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$LOG_DIR/run_$TS.log"

mkdir -p "$LOG_DIR"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== HELPY RESET + SCAN ==="
echo "time: $(date)"
echo "project: $PROJECT_DIR"
echo

if [ ! -d "$PROJECT_DIR" ]; then
  echo "ERROR: project dir not found: $PROJECT_DIR"
  exit 1
fi

cd "$PROJECT_DIR"

echo "=== 1. BASIC INFO ==="
pwd
echo
git rev-parse --is-inside-work-tree >/dev/null 2>&1 && {
  echo "--- git branch ---"
  git branch --show-current || true
  echo
  echo "--- git status short ---"
  git status --short || true
  echo
  echo "--- last commit ---"
  git log -1 --oneline || true
  echo
} || echo "git repo: no"
echo

echo "=== 2. TOOLCHECK ==="
for cmd in bash grep sed awk find xargs; do
  command -v "$cmd" >/dev/null 2>&1 && echo "OK: $cmd" || echo "MISS: $cmd"
done
command -v rg >/dev/null 2>&1 && echo "OK: rg" || echo "MISS: rg"
command -v flutter >/dev/null 2>&1 && echo "OK: flutter" || echo "MISS: flutter"
command -v dart >/dev/null 2>&1 && echo "OK: dart" || echo "MISS: dart"
command -v adb >/dev/null 2>&1 && echo "OK: adb" || echo "MISS: adb"
echo

echo "=== 3. DETECT PACKAGE ID ==="
PKG_ID=""

# build.gradle.kts
if [ -f android/app/build.gradle.kts ]; then
  PKG_ID="$(sed -nE 's/^[[:space:]]*applicationId[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' android/app/build.gradle.kts | head -n1 || true)"
fi

# build.gradle
if [ -z "$PKG_ID" ] && [ -f android/app/build.gradle ]; then
  PKG_ID="$(sed -nE "s/^[[:space:]]*applicationId[[:space:]]+['\"]([^'\"]+)['\"].*/\1/p" android/app/build.gradle | head -n1 || true)"
fi

# AndroidManifest fallback
if [ -z "$PKG_ID" ] && [ -f android/app/src/main/AndroidManifest.xml ]; then
  PKG_ID="$(sed -nE 's/.*package="([^"]+)".*/\1/p' android/app/src/main/AndroidManifest.xml | head -n1 || true)"
fi

echo "PACKAGE_ID=${PKG_ID:-NOT_FOUND}"
echo

echo "=== 4. FLUTTER / DART CLEAN ==="
if command -v flutter >/dev/null 2>&1; then
  echo "--- flutter clean ---"
  flutter clean || true
  echo
  echo "--- pub cache-ish local cleanup ---"
  rm -rf .dart_tool build || true
  find . -type d -name ".dart_tool" -prune -print || true
  echo
  echo "--- flutter pub get ---"
  flutter pub get || true
  echo
else
  echo "flutter not found, skipping flutter clean/pub get"
  echo
fi

echo "=== 5. LOCAL REPO JUNK CLEANUP (SAFE) ==="
rm -rf "$PROJECT_DIR/.tmp_diag/cache_scan" || true
mkdir -p "$PROJECT_DIR/.tmp_diag/cache_scan"
find "$PROJECT_DIR" -maxdepth 4 \
  \( -name "build" -o -name ".dart_tool" -o -name ".flutter-plugins-dependencies" \) \
  -print 2>/dev/null || true
echo

echo "=== 6. ADB DEVICES ==="
if command -v adb >/dev/null 2>&1; then
  adb start-server >/dev/null 2>&1 || true
  adb devices -l || true
else
  echo "adb not found"
fi
echo

echo "=== 7. CLEAR APP DATA ON ALL ATTACHED DEVICES ==="
if command -v adb >/dev/null 2>&1 && [ -n "${PKG_ID:-}" ]; then
  mapfile -t DEVICES < <(adb devices | awk 'NR>1 && $2=="device" {print $1}')
  if [ "${#DEVICES[@]}" -eq 0 ]; then
    echo "No attached adb devices"
  else
    for dev in "${DEVICES[@]}"; do
      echo "--- device: $dev ---"
      adb -s "$dev" shell pm clear "$PKG_ID" || true
      echo
    done
  fi
else
  echo "Skip pm clear (adb or package id missing)"
fi
echo

echo "=== 8. FIND CONFLICTING UI / STATUS STRINGS ==="
PATTERNS=(
  "Master already has an offer for this job"
  "Client has not selected you yet"
  "Открыт"
  "отклик"
  "selected"
  "offer"
  "response"
  "job.status"
  "offer.status"
  "selectedMaster"
  "assignedMaster"
  "canSubmitOffer"
  "canCreateOffer"
  "createOffer"
  "submitOffer"
  "myOffer"
  "marketplace"
)

if command -v rg >/dev/null 2>&1; then
  for p in "${PATTERNS[@]}"; do
    echo "--- rg: $p ---"
    rg -n --hidden -S "$p" lib android test . || true
    echo
  done
else
  for p in "${PATTERNS[@]}"; do
    echo "--- grep: $p ---"
    grep -RIn --exclude-dir=.git --exclude-dir=build --exclude-dir=.dart_tool -- "$p" lib android test . 2>/dev/null || true
    echo
  done
fi

echo "=== 9. FIND LIKELY FILES ==="
if command -v rg >/dev/null 2>&1; then
  echo "--- screens/widgets/state files ---"
  rg -n --hidden -S "(Marketplace|Offer|Response|JobDetails|JobCard|Master|Client)" lib || true
  echo
  echo "--- enums / statuses ---"
  rg -n --hidden -S "(enum .*Status|JobStatus|OfferStatus|ResponseStatus|selectedMaster|assignedMaster)" lib || true
  echo
  echo "--- routes / navigation to offer screens ---"
  rg -n --hidden -S "(Navigator|goNamed|pushNamed|context\.push|context\.go).*(offer|response|job)" lib || true
  echo
fi

echo "=== 10. TRY DART ANALYZE ==="
if command -v flutter >/dev/null 2>&1; then
  flutter analyze || true
elif command -v dart >/dev/null 2>&1; then
  dart analyze || true
else
  echo "dart/flutter not found, skipping analyze"
fi
echo

echo "=== 11. SUMMARY ==="
echo "LOG_FILE=$LOG_FILE"
echo
echo "NEXT:"
echo "1) send me the full terminal output"
echo "2) if output is huge, send at least:"
echo "   - PACKAGE_ID line"
echo "   - ADB CLEAR block"
echo "   - FIND CONFLICTING UI / STATUS STRINGS block"
echo "   - FIND LIKELY FILES block"
echo "   - flutter analyze tail"
echo
echo "DONE"
