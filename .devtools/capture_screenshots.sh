#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
simulator_id="${IOS_SIMULATOR_ID:-booted}"
output_dir="${SCREEN_OUTPUT_DIR:-${repo_root}/.tmp/screens/ios}"
driver_path="test_driver/screenshots_driver.dart"
target_path="${CAPTURE_TARGET_PATH:-integration_test/screenshot_gallery_test.dart}"
bundle_id="${IOS_BUNDLE_ID:-${BUNDLE_ID:-com.niduna.currencyConverter}}"

source "${repo_root}/scripts/common.sh"

mkdir -p "${output_dir}"

main() {
  echo "Capturing screenshots from app on ${simulator_id}..."
  export SCREEN_OUTPUT_DIR="${output_dir}"
  run_flutter drive \
    --driver="${driver_path}" \
    --target="${target_path}" \
    -d "${simulator_id}"
  echo "Screenshots saved to ${output_dir}"
}

main "$@"
