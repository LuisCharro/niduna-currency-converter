#!/usr/bin/env bash

# Launch (or relaunch) the already-installed app on the Android
# emulator/device. Resolves the launcher activity explicitly via
# `cmd package resolve-activity`, which is more reliable than `monkey`
# (monkey exits -5 when it cannot match a launcher category).
#
# Usage:   ./.devtools/android_launch.sh
# Env:     ANDROID_SERIAL (default: booted -> auto-detect, prefers emulator)
#          ANDROID_PACKAGE_NAME (default: com.niduna.currency_converter)

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
source "${repo_root}/scripts/common.sh"

package_name="${ANDROID_PACKAGE_NAME:-com.niduna.currency_converter}"

serial="$(resolve_android_serial)"
if [[ -z "${serial}" ]]; then
  echo "ERROR: No Android device found. Start an emulator first." >&2
  exit 1
fi

activity="$(run_adb -s "${serial}" shell cmd package resolve-activity --brief "${package_name}" | tail -1 | tr -d '\r')"
if [[ -z "${activity}" || "${activity}" != *"/"* ]]; then
  echo "ERROR: Could not resolve a launcher activity for ${package_name}." >&2
  echo "Is the app installed? Try ./.devtools/android_reinstall_build.sh" >&2
  exit 1
fi

run_adb -s "${serial}" shell am start -n "${activity}" >/dev/null
echo "Launched ${activity} on ${serial}"
