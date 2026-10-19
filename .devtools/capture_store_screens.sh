#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

source "${repo_root}/scripts/common.sh"

output_base="${SCREEN_OUTPUT_DIR:-${repo_root}/.tmp/screens/store}"
provider_profile="${PROVIDER_PROFILE:-release_safe}"
app_dev_mode="${APP_DEV_MODE:-false}"

android_serial="$(resolve_android_serial)"

if [[ -z "${android_serial}" ]]; then
  echo "No Android device available. Set ANDROID_SERIAL or start an emulator." >&2
  exit 1
fi

light_dir="${output_base}/light"
dark_dir="${output_base}/dark"

# The gallery seeds the app's own dark-mode preference via SCREENSHOT_DARK.
# Changing Android's global night mode is redundant and relaunches system UI.
echo "=== Capturing LIGHT mode into ${light_dir} ==="
ANDROID_SERIAL="${android_serial}" \
SCREEN_OUTPUT_DIR="${light_dir}" \
  SCREENSHOT_DARK= \
  PROVIDER_PROFILE="${provider_profile}" \
  APP_DEV_MODE="${app_dev_mode}" \
  bash "${script_dir}/capture_android_screens.sh"

echo "=== Capturing DARK mode into ${dark_dir} ==="
ANDROID_SERIAL="${android_serial}" \
SCREEN_OUTPUT_DIR="${dark_dir}" \
  SCREENSHOT_DARK=true \
  PROVIDER_PROFILE="${provider_profile}" \
  APP_DEV_MODE="${app_dev_mode}" \
  bash "${script_dir}/capture_android_screens.sh"

echo "Done."
echo "  Light: ${light_dir}/"
echo "  Dark:  ${dark_dir}/"
