#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
bundle_root="${SCREEN_OUTPUT_DIR:-${repo_root}/.tmp/screens/ios/ui-review-bundle}"
include_onboarding="${INCLUDE_ONBOARDING:-0}"
manifest_path="${bundle_root}/MANIFEST.md"

mkdir -p "${bundle_root}"

run_capture() {
  local name="$1"
  local command_path="$2"
  local output_dir="${bundle_root}/${name}"

  echo
  echo "=== Capturing ${name} into ${output_dir} ==="
  SCREEN_OUTPUT_DIR="${output_dir}" "${command_path}"
}

write_manifest() {
  {
    printf '# iOS UI Review Bundle\n\n'
    printf 'Generated on: %s\n\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
    printf 'Root: `%s`\n\n' "${bundle_root}"
    printf '## Directories\n\n'

    find "${bundle_root}" -mindepth 1 -maxdepth 1 -type d | sort | while read -r dir; do
      local name
      name="$(basename "${dir}")"
      printf '### %s\n\n' "${name}"
      find "${dir}" -maxdepth 1 -type f -name '*.png' | sort | while read -r file; do
        printf -- '- `%s`\n' "$(basename "${file}")"
      done
      printf '\n'
    done
  } > "${manifest_path}"
}

main() {
  if [[ "${include_onboarding}" == "1" ]]; then
    run_capture "onboarding-reference" \
      "${repo_root}/.devtools/capture_ios_onboarding_reference_screens.sh"
  fi

  run_capture "seeded-reference" \
    "${repo_root}/.devtools/capture_ios_seeded_reference_screens.sh"
  run_capture "add-entry-reference" \
    "${repo_root}/.devtools/capture_ios_add_entry_reference_screens.sh"
  run_capture "post-onboarding-reference" \
    "${repo_root}/.devtools/capture_ios_post_onboarding_reference_screens.sh"
  run_capture "settings-reference" \
    "${repo_root}/.devtools/capture_ios_settings_reference_screens.sh"

  write_manifest

  echo
  echo "UI review bundle saved to ${bundle_root}"
  echo "Manifest: ${manifest_path}"
}

main "$@"
