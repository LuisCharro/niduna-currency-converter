#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"

CAPTURE_TARGET_PATH="integration_test/add_entry_reference_gallery_test.dart" \
SCREEN_OUTPUT_DIR="${SCREEN_OUTPUT_DIR:-${repo_root}/.tmp/screens/ios/add-entry-reference}" \
SEED_BEFORE_CAPTURE=0 \
"${repo_root}/.devtools/capture_ios_screens.sh"
