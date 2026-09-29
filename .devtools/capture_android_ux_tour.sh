#!/usr/bin/env bash

# UX review tour: boots each requested AVD, runs
# integration_test/ux_review_tour_test.dart in light and dark, and writes
# screenshots to .tmp/screens/android/ux-tour/<avd>/<theme>/.
#
# Unlike the store/screenshot scripts, this defaults to what a real user sees:
# PROVIDER_PROFILE=release_safe and APP_DEV_MODE=false (no dev UI).
#
# Usage:   ./.devtools/capture_android_ux_tour.sh [avd ...]
#          (default AVDs: Small_Screen_API_36 exp_night_36 Pixel7_EN)
# Env:     UX_TOUR_THEMES   (default: "light dark")
#          UX_TOUR_PAID     (default: false; true simulates all entitlements)
#          UX_TOUR_OUT      (default: .tmp/screens/android/ux-tour)
#          PROVIDER_PROFILE / APP_DEV_MODE to override the defaults above.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
source "${repo_root}/scripts/common.sh"

avds=("$@")
if [[ ${#avds[@]} -eq 0 ]]; then
  avds=(Small_Screen_API_36 exp_night_36 Pixel7_EN)
fi
themes="${UX_TOUR_THEMES:-light dark}"
paid="${UX_TOUR_PAID:-false}"
out_root="${UX_TOUR_OUT:-${repo_root}/.tmp/screens/android/ux-tour}"
package_name="${ANDROID_PACKAGE_NAME:-com.honestfern.currency_converter}"

define_args=()
while IFS= read -r arg; do
  define_args+=("${arg}")
done < <(
  PROVIDER_PROFILE="${PROVIDER_PROFILE:-release_safe}" \
    APP_DEV_MODE="${APP_DEV_MODE:-false}" \
    flutter_app_define_args
)

for avd in "${avds[@]}"; do
  serial="$("${script_dir}/android_boot_emulator.sh" "${avd}")"
  for theme in ${themes}; do
    dark=false
    [[ "${theme}" == "dark" ]] && dark=true
    out_dir="${out_root}/${avd}/${theme}"
    mkdir -p "${out_dir}"
    rm -f "${out_dir}"/*.png
    run_adb -s "${serial}" shell am force-stop "${package_name}" >/dev/null 2>&1 || true
    echo "== ${avd} (${serial}) ${theme} -> ${out_dir}"
    SCREEN_OUTPUT_DIR="${out_dir}" run_flutter drive \
      --driver=test_driver/screenshots_driver.dart \
      --target=integration_test/ux_review_tour_test.dart \
      -d "${serial}" \
      "${define_args[@]}" \
      --dart-define=SCREENSHOT_DARK="${dark}" \
      --dart-define=SCREENSHOT_PAID="${paid}" \
      2>&1 | tee "${out_dir}/run.log" | grep -E "UX_TOUR|All tests|Some tests|Error|FAILED" || true
  done
done

echo "Done. Screens under ${out_root}"
