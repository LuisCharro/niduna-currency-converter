#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Capturing all 3 tabs ==="

osascript -e 'tell application "Simulator" to activate' 2>/dev/null || true
sleep 1

"${script_dir}/sim_screenshot.sh" 01-convert
sleep 0.5

echo "--- Tapping Chart tab ---"
cliclick c:345,890
sleep 1.5

"${script_dir}/sim_screenshot.sh" 02-charts
sleep 0.5

echo "--- Tapping Settings tab ---"
cliclick c:495,890
sleep 1.5

"${script_dir}/sim_screenshot.sh" 03-settings
sleep 0.5

echo "--- Tapping Convert tab (back) ---"
cliclick c:195,890
sleep 0.5

echo "=== Done. Screenshots in .tmp/screens/ios/ ==="
ls -lt "$(cd "${script_dir}/../.."/.tmp/screens/ios && pwd)"/*.png 2>/dev/null | head -6
