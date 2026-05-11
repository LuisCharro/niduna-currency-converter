#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
simulator_id="${IOS_SIMULATOR_ID:-booted}"
max_wait="${1:-30}"
interval="${2:-2}"

resolve_sim_id() {
  if [[ "${simulator_id}" != "booted" ]]; then
    printf '%s\n' "${simulator_id}"
    return
  fi
  xcrun simctl list devices booted | grep -Eo '[A-F0-9-]{36}' | head -n 1
}

resolved="$(resolve_sim_id)"
if [[ -z "${resolved}" ]]; then
  echo "ERROR: No booted simulator found" >&2
  exit 1
fi

tmp_file="/tmp/sim-wait-check.png"
elapsed=0

while [[ ${elapsed} -lt ${max_wait} ]]; do
  xcrun simctl io "${resolved}" screenshot "${tmp_file}" 2>/dev/null || true
  
  file_size=$(stat -f%z "${tmp_file}" 2>/dev/null || echo "0")
  
  if [[ "${file_size}" -gt 50000 ]]; then
    pixels=$(sips -g all "${tmp_file}" 2>/dev/null | grep pixel | head -1 || echo "")
    
    non_white=$(sips -g pixelWidth -g pixelHeight "${tmp_file}" 2>/dev/null \
      | awk '/pixelWidth/{w=$2} /pixelHeight/{h=$2} END{print w*h}')
    
    if [[ -n "${non_white}" && "${non_white}" -gt 1000 ]]; then
      rm -f "${tmp_file}"
      echo "App ready after ${elapsed}s"
      exit 0
    fi
  fi
  
  sleep "${interval}"
  elapsed=$((elapsed + interval))
done

rm -f "${tmp_file}"
echo "WARNING: App may not be ready after ${max_wait}s" >&2
exit 1
