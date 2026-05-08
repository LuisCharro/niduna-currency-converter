#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/common.sh"

run_flutter build web --pwa-strategy=none "$@"
