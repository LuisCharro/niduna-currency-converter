#!/usr/bin/env bash
# Collect evidence without dismissing dialogs, clearing data or killing processes.
set -euo pipefail
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
source "${repo_root}/scripts/common.sh"
serial="$(resolve_android_serial)"
[[ -n "${serial}" ]] || { echo "No Android device available" >&2; exit 1; }
output="${ANDROID_DIAGNOSTIC_DIR:-${repo_root}/.tmp/android-diagnostics/$(date +%Y%m%d-%H%M%S)}"
mkdir -p "${output}"
run_adb -s "${serial}" shell dumpsys activity lastanr > "${output}/lastanr.txt"
run_adb -s "${serial}" shell dumpsys window > "${output}/window.txt"
run_adb -s "${serial}" logcat -d -b events -v threadtime -s am_anr am_crash > "${output}/events.txt"
run_adb -s "${serial}" shell dumpsys meminfo > "${output}/memory.txt"
run_adb -s "${serial}" shell dumpsys cpuinfo > "${output}/cpu.txt"
run_adb -s "${serial}" shell 'for resource in /proc/pressure/memory /proc/pressure/cpu /proc/pressure/io; do if test -r "$resource"; then cat "$resource"; else echo "$resource unavailable to shell"; fi; done; df -k /data' > "${output}/resources.txt"
run_adb -s "${serial}" exec-out screencap -p > "${output}/screen.png"
head -n 4 "${output}/lastanr.txt"
grep -E 'mCurrentFocus|mFocusedApp' "${output}/window.txt" || true
echo "Evidence saved to ${output} (last ANR may be historical; check its timestamp)."
