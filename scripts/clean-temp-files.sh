#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

echo "Cleaning temporary/build artifacts in $repo_root"

rm -rf build .dart_tool .turbo .cache
find . -maxdepth 2 -type f -name 'flutter_*.log' -delete
find . -maxdepth 2 -type f -name '*.tmp' -delete

echo "Done."
