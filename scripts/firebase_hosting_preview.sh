#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

TARGET="${1:-openclaw}"
CHANNEL="${2:-${TARGET}}"
APP_VERSION="0.1.0"

require_openclaw_target

echo "=== Building Flutter web (release) ==="
run_flutter build web --release --dart-define=FLAVOR=production

echo ""
echo "=== Deploying to Firebase Hosting ==="
echo "Target: ${TARGET}"
echo "Channel: ${CHANNEL}"

run_firebase deploy \
  --only hosting:${TARGET} \
  --project currency-converter-by-niduna \
  --message "preview: ${CHANNEL} v${APP_VERSION} ($(date '+%Y-%m-%d %H:%M'))"

echo ""
echo "=== Preview URL ==="
case "${TARGET}" in
  openclaw) echo "https://currency-converter-openclaw.web.app?v=${APP_VERSION}" ;;
  luis)     echo "https://currency-converter-luis.web.app?v=${APP_VERSION}" ;;
  alina)    echo "https://currency-converter-alina.web.app" ;;
esac
