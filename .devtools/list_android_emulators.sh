#!/bin/bash
set -euo pipefail

# list_android_emulators.sh — List available Android AVDs and connected devices.
#
# Usage:
#   ./.devtools/list_android_emulators.sh
#
# Shows:
#   1. Connected devices/emulators (with serial, model, screen size)
#   2. Available (but not running) AVDs from emulator -list-avds
#
# Useful when you need to pick a target before running android_reinstall_build.sh.

ADB_BIN="${ADB_BIN:-$(command -v adb 2>/dev/null || echo /Users/luis/Library/Android/sdk/platform-tools/adb)}"
EMULATOR="${EMULATOR:-/Users/luis/Library/Android/sdk/emulator/emulator}"

echo "--- Connected devices ---"
"$ADB_BIN" devices -l 2>/dev/null || true

echo ""
echo "--- Available AVDs ---"
"$EMULATOR" -list-avds 2>/dev/null || true

echo ""
echo "--- Tip ---"
echo "  Start an AVD:  $EMULATOR -avd <name> &"
echo "  Then use:    ANDROID_SERIAL=<serial> ./.devtools/android_reinstall_build.sh"
