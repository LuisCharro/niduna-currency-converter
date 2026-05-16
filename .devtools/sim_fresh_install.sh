#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Fresh install: build + reinstall + launch ==="
"${script_dir}/sim_reinstall_build.sh"
