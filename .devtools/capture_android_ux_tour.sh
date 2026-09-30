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
#          UX_TOUR_KEEP_EMULATORS (default: false) — by default each AVD this
#                           script booted is shut down after its run, so only
#                           one emulator uses RAM at a time. AVDs that were
#                           already running are left alone.
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

running_before="$(run_adb devices | awk '$1 ~ /^emulator-/ { print $1 }')"

for avd in "${avds[@]}"; do
  serial="$("${script_dir}/android_boot_emulator.sh" "${avd}")"
  booted_here=true
  grep -qx "${serial}" <<<"${running_before}" && booted_here=false
  for theme in ${themes}; do
    dark=false
    [[ "${theme}" == "dark" ]] && dark=true
    out_dir="${out_root}/${avd}/${theme}"
    mkdir -p "${out_dir}"
    rm -f "${out_dir}"/*.png
    # Fresh install each run: the tour starts as a new user anyway, and
    # replacing a large debug APK in place can hit INSUFFICIENT_STORAGE on
    # small AVDs.
    run_adb -s "${serial}" uninstall "${package_name}" >/dev/null 2>&1 || true
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
  if [[ "${booted_here}" == "true" && "${UX_TOUR_KEEP_EMULATORS:-false}" != "true" ]]; then
    echo "Shutting down ${avd} (${serial})"
    run_adb -s "${serial}" emu kill >/dev/null 2>&1 || true
    sleep 3
  fi
done

echo "Done. Screens under ${out_root}"
