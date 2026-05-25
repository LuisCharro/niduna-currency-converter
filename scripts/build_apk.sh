#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/common.sh"

require_android_release_admob_config

flutter_args=()
while IFS= read -r arg; do
  flutter_args+=("${arg}")
done < <(
  PROVIDER_PROFILE="${PROVIDER_PROFILE:-release_safe}" \
    APP_DEV_MODE="${APP_DEV_MODE:-false}" \
    flutter_app_define_args
)

run_flutter build apk --release "${flutter_args[@]}" "$@"
