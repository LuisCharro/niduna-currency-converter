#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

TARGET="${1:-openclaw}"
CHANNEL="${2:-${TARGET}}"

require_openclaw_target

echo "=== Building Flutter web (release) ==="
run_flutter build web --release --dart-define=FLAVOR=production

echo ""
echo "=== Deploying to Firebase Hosting ==="
echo "Target: ${TARGET}"
echo "Channel: ${CHANNEL}"

run_firebase hosting deploy \
  --only hosting:${TARGET} \
  --project currency-converter-by-niduna \
  --message "preview: ${CHANNEL} ($(date '+%Y-%m-%d %H:%M'))"

echo ""
echo "=== Preview URL ==="
case "${TARGET}" in
  openclaw) echo "https://currency-converter-openclaw.web.app" ;;
  luis)     echo "https://currency-converter-luis.web.app" ;;
  alina)    echo "https://currency-converter-alina.web.app" ;;
esac
