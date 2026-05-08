#!/usr/bin/env bash

set -euo pipefail

source "$(dirname "$0")/common.sh"

run_flutter pub get
run_flutter analyze
run_flutter test --concurrency=1
