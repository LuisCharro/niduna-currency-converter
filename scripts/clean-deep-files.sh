#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

echo "Deep cleaning $repo_root"
rm -rf build .dart_tool .tmp .turbo .cache
rm -rf ios/Pods ios/.symlinks android/.gradle
find . -maxdepth 3 -type f \( -name 'flutter_*.log' -o -name '*.tmp' \) -delete

echo "Done. Run pub get / pod install before next full build."
