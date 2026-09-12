#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

source "${repo_root}/scripts/common.sh"
cd "${repo_root}"

android_serial="${ANDROID_SERIAL:-emulator-5554}"
output_root="${PLAY_PREP_OUTPUT_DIR:-${repo_root}/.tmp/play-candidate/$(date +%Y%m%d-%H%M%S)}"
provider_profile="${PROVIDER_PROFILE:-release_safe}"
expected_version_code="${EXPECTED_VERSION_CODE:-}"
require_main="${REQUIRE_MAIN:-1}"
release_admob_use_test_ads="${ADMOB_USE_TEST_ADS:-false}"

fail() {
  echo "prepare_play_candidate: $*" >&2
  exit 1
}

if [[ "${require_main}" == "1" ]]; then
  current_branch="$(git -C "${repo_root}" branch --show-current)"
  [[ "${current_branch}" == "main" ]] || fail "run this after merging on main (current: ${current_branch})"
fi

[[ -z "$(git -C "${repo_root}" status --porcelain)" ]] || \
  fail "working tree is not clean; commit or stash changes before preparing a candidate"

if [[ -n "${expected_version_code}" ]]; then
  version_line="$(sed -n 's/^version: //p' "${repo_root}/pubspec.yaml" | head -n 1)"
  actual_version_code="${version_line##*+}"
  [[ "${actual_version_code}" == "${expected_version_code}" ]] || \
    fail "expected version code ${expected_version_code}, found ${actual_version_code} (${version_line})"
fi

adb_bin="$(resolve_adb_bin)"
"${adb_bin}" -s "${android_serial}" get-state >/dev/null || \
  fail "Android target is not ready: ${android_serial}"

screen_size="$("${adb_bin}" -s "${android_serial}" shell wm size | tr -d '\r')"
[[ "${screen_size}" == *"1080x2400"* ]] || \
  fail "expected the large 1080x2400 emulator, got: ${screen_size}"

mkdir -p "${output_root}/artifacts" "${output_root}/screenshots"

echo "=== Source ==="
git -C "${repo_root}" rev-parse --short HEAD
git -C "${repo_root}" log -1 --format='%s'
echo "=== Target ==="
echo "${android_serial} (${screen_size})"
echo "=== Verification ==="
(cd "${repo_root}" && ./scripts/check.sh)

echo "=== Release APK ==="
PROVIDER_PROFILE="${provider_profile}" \
  APP_DEV_MODE=false \
  ADMOB_USE_TEST_ADS="${release_admob_use_test_ads}" \
  ./scripts/build_apk.sh
cp "${repo_root}/build/app/outputs/flutter-apk/app-release.apk" \
  "${output_root}/artifacts/app-release.apk"

echo "=== Release AAB ==="
PROVIDER_PROFILE="${provider_profile}" \
  APP_DEV_MODE=false \
  ADMOB_USE_TEST_ADS="${release_admob_use_test_ads}" \
  ./scripts/build_appbundle.sh
cp "${repo_root}/build/app/outputs/bundle/release/app-release.aab" \
  "${output_root}/artifacts/app-release.aab"

echo "=== Play screenshots (paid layout, no ads) ==="
ANDROID_SERIAL="${android_serial}" \
  SCREEN_OUTPUT_DIR="${output_root}/screenshots" \
  PROVIDER_PROFILE="${provider_profile}" \
  APP_DEV_MODE=false \
  ADMOB_USE_TEST_ADS=true \
  bash "${script_dir}/capture_store_screens.sh"

echo "=== Candidate files ==="
find "${output_root}" -type f -print | sort
echo "=== SHA-256 ==="
shasum -a 256 \
  "${output_root}/artifacts/app-release.apk" \
  "${output_root}/artifacts/app-release.aab" \
  "${output_root}/screenshots/light/01-convert.png" \
  "${output_root}/screenshots/light/02-chart-btc.png" \
  "${output_root}/screenshots/light/03-favorites.png" \
  "${output_root}/screenshots/dark/01-convert.png" \
  "${output_root}/screenshots/dark/02-chart-btc.png" \
  "${output_root}/screenshots/dark/03-favorites.png"

echo "Prepared candidate in: ${output_root}"
echo "Review the PNGs before manually replacing the Play Console listing assets."
