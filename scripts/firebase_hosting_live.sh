#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

APP_VERSION="0.1.0"

require_openclaw_target

echo "=== Building Flutter web (release) ==="
run_flutter build web --release --dart-define=FLAVOR=production

echo ""
echo "=== Deploying to Firebase Hosting (LIVE) ==="

run_firebase deploy \
  --only hosting:luis \
  --project currency-converter-by-niduna \
  --message "live: v${APP_VERSION} $(date '+%Y-%m-%d %H:%M')"

echo ""
echo "=== Live URL ==="
echo "https://currency-converter-luis-8aaa7.web.app?v=${APP_VERSION}"
