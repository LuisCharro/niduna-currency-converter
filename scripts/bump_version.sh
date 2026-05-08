#!/usr/bin/env bash
# Bumps version + buildNumber in pubspec.yaml and lib/src/app_info.dart.
# Run before deploying to update the version shown in Settings > About.
#
# Usage:
#   ./scripts/bump_version.sh          # bump build number (1.0.0+1 → 1.0.0+2)
#   ./scripts/bump_version.sh minor   # bump minor (1.0.0+1 → 1.1.0+1)
#   ./scripts/bump_version.sh major   # bump major (1.0.0+1 → 2.0.0+1)

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

mode="${1:-build}"   # build | minor | major

# --- parse current version from pubspec ---
pubspec="pubspec.yaml"
current=$(grep -E "^version:" "$pubspec" | sed 's/version: *//' | tr -d ' ')
IFS='+' read -r ver_str build_str <<< "$current"
IFS='.' read -r major minor patch <<< "$ver_str"

echo "Current: ${major}.${minor}.${patch}+${build_str}"

case "$mode" in
  major)
    major=$((major + 1)); minor=0; patch=0; build_str=1
    ;;
  minor)
    minor=$((minor + 1)); patch=0; build_str=1
    ;;
  build|*)
    build_str=$((build_str + 1))
    ;;
esac

new="${major}.${minor}.${patch}"
echo "New: ${new}+${build_str}"

# --- update pubspec.yaml ---
sed -i "s/^version: .*/version: ${new}+${build_str}/" "$pubspec"
echo "Updated pubspec.yaml → version: ${new}+${build_str}"

# --- update app_info.dart ---
app_info="lib/src/app_info.dart"
cat > "$app_info" << EOF
/// Build-time version info injected by the CI / build system.
/// Keep in sync with pubspec.yaml version.
class AppInfo {
  static const String version = '$new';
  static const int buildNumber = $build_str;
}
EOF
echo "Updated lib/src/app_info.dart → AppInfo.version = '$new', buildNumber = $build_str"

# --- commit ---
git add pubspec.yaml lib/src/app_info.dart
git commit -m "chore(release): bump version to ${new}+${build_str}"
echo "Committed as: ${new}+${build_str}"