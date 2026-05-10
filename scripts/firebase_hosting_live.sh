#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/common.sh"

require_openclaw_target

echo "=== Building Flutter web (release) ==="
run_flutter build web --release --dart-define=FLAVOR=production

echo ""
echo "=== Deploying to Firebase Hosting (LIVE) ==="

run_firebase hosting deploy \
  --only hosting:luis \
  --project currency-converter-by-niduna \
  --message "live: $(date '+%Y-%m-%d %H:%M')"

echo ""
echo "=== Live URL ==="
echo "https://currency-converter-luis.web.app"
