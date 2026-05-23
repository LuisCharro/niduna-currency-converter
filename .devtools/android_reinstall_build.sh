#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
android_serial="${ANDROID_SERIAL:-booted}"
package_name="${ANDROID_PACKAGE_NAME:-com.niduna.currency_converter}"
apk_path="${ANDROID_APK_PATH:-build/app/outputs/flutter-apk/app-debug.apk}"
build_first="${BUILD_FIRST:-1}"
grant_permissions="${GRANT_PERMISSIONS:-1}"
uninstall_first="${UNINSTALL_FIRST:-1}"
split_per_abi_on_low_storage="${SPLIT_PER_ABI_ON_LOW_STORAGE:-1}"

normal_apk_path="build/app/outputs/flutter-apk/app-debug.apk"

source "${repo_root}/scripts/common.sh"

list_available_targets() {
  echo "Connected Android devices:" >&2
  run_adb devices | sed '1d' >&2 || true

  if command -v emulator >/dev/null 2>&1; then
    echo >&2
    echo "Available Android AVDs:" >&2
    emulator -list-avds >&2 || true
  fi
}

resolve_android_serial() {
  if [[ "${android_serial}" != "booted" ]]; then
    printf '%s\n' "${android_serial}"
    return
  fi

  local detected_serial
  detected_serial="$({ run_adb devices | awk '$2 == "device" && $1 ~ /^emulator-/ { print $1; exit }'; } || true)"
  if [[ -n "${detected_serial}" ]]; then
    printf '%s\n' "${detected_serial}"
    return
  fi

  detected_serial="$({ run_adb devices | awk '$2 == "device" { print $1; exit }'; } || true)"
  if [[ -n "${detected_serial}" ]]; then
    printf '%s\n' "${detected_serial}"
  fi
}

ensure_device_available() {
  if ! run_adb devices | grep -q "^${android_serial}[[:space:]]\+device$"; then
    echo "Android device not available: ${android_serial}" >&2
    echo "Run with ANDROID_SERIAL=<device_id> or start the target emulator first." >&2
    list_available_targets
    exit 1
  fi
}

resolve_device_abi() {
  local abi
  abi="$(run_adb -s "${android_serial}" shell getprop ro.product.cpu.abi 2>/dev/null | tr -d '\r')"
  if [[ -z "${abi}" ]]; then
    echo "Could not determine Android device ABI for ${android_serial}." >&2
    exit 1
  fi
  printf '%s\n' "${abi}"
}

split_apk_path_for_abi() {
  case "$1" in
    arm64-v8a) printf '%s\n' "build/app/outputs/flutter-apk/app-arm64-v8a-debug.apk" ;;
    armeabi-v7a) printf '%s\n' "build/app/outputs/flutter-apk/app-armeabi-v7a-debug.apk" ;;
    x86_64) printf '%s\n' "build/app/outputs/flutter-apk/app-x86_64-debug.apk" ;;
    *)
      echo "Unsupported Android ABI for split APK fallback: $1" >&2
      exit 1
      ;;
  esac
}

build_split_apk_for_device() {
  local abi split_path
  abi="$(resolve_device_abi)"
  split_path="$(split_apk_path_for_abi "${abi}")"

  echo "Building split debug APK for ABI ${abi}..."
  run_flutter build apk --debug --split-per-abi "${flutter_args[@]}"

  if [[ ! -f "${repo_root}/${split_path}" ]]; then
    echo "Split APK not found at ${repo_root}/${split_path}" >&2
    exit 1
  fi

  apk_path="${split_path}"
}

install_apk() {
  local install_args=(-s "${android_serial}" install -r)
  local install_output
  if [[ "${grant_permissions}" == "1" ]]; then
    install_args+=( -g )
  fi
  install_args+=("${repo_root}/${apk_path}")

  if install_output="$(run_adb "${install_args[@]}" 2>&1)"; then
    printf '%s\n' "${install_output}"
    return
  fi

  printf '%s\n' "${install_output}" >&2

  if [[ "${split_per_abi_on_low_storage}" == "1" ]] && \
    [[ "${apk_path}" == "${normal_apk_path}" ]] && \
    grep -q "INSUFFICIENT_STORAGE\|not enough space" <<<"${install_output}"; then
    echo "Low storage detected. Falling back to split-per-abi APK..."
    build_split_apk_for_device
    install_apk
    return
  fi

  echo "Install failed. Trying a clean reinstall for ${package_name}..."
  run_adb -s "${android_serial}" shell pm trim-caches 2G >/dev/null 2>&1 || true
  run_adb -s "${android_serial}" uninstall "${package_name}" >/dev/null 2>&1 || true
  run_adb "${install_args[@]}"
}

main() {
  local provider_profile="${PROVIDER_PROFILE:-dev_coinpaprika}"
  local app_dev_mode="${APP_DEV_MODE:-true}"
  flutter_args=()
  while IFS= read -r arg; do
    flutter_args+=("${arg}")
  done < <(
    PROVIDER_PROFILE="${provider_profile}" \
      APP_DEV_MODE="${app_dev_mode}" \
      flutter_app_define_args
  )

  android_serial="$(resolve_android_serial)"
  if [[ -z "${android_serial}" ]]; then
    echo "Could not resolve a running Android device/emulator." >&2
    list_available_targets
    exit 1
  fi

  ensure_device_available

  if [[ "${build_first}" == "1" ]]; then
    echo "Building Android debug APK..."
    run_flutter build apk --debug "${flutter_args[@]}"
  fi

  if [[ ! -f "${repo_root}/${apk_path}" ]]; then
    echo "APK not found at ${repo_root}/${apk_path}" >&2
    echo "Set ANDROID_APK_PATH or run with BUILD_FIRST=1." >&2
    exit 1
  fi

  echo "Reinstalling ${package_name} on ${android_serial}..."
  run_adb -s "${android_serial}" shell am force-stop "${package_name}" >/dev/null 2>&1 || true
  if [[ "${uninstall_first}" == "1" ]]; then
    run_adb -s "${android_serial}" uninstall "${package_name}" >/dev/null 2>&1 || true
  fi
  install_apk
  run_adb -s "${android_serial}" shell monkey -p "${package_name}" \
    -c android.intent.category.LAUNCHER 1 >/dev/null

  echo "Done. App built, installed, and launched."
}

main "$@"
