#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

RSVG_CONVERT="${RSVG_CONVERT:-rsvg-convert}"
MAGICK="${MAGICK:-magick}"
DART="${DART:-dart}"

for command_name in "$RSVG_CONVERT" "$MAGICK" "$DART"; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Required command not found: $command_name" >&2
    exit 1
  fi
done

APP_SVG="assets/brand/app_icon.svg"
FOREGROUND_SVG="assets/brand/app_icon_foreground.svg"
SPLASH_SVG="assets/brand/splash_mark.svg"
LEAF_GREEN="#285F3B"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/currency-brand-icons.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

render_svg() {
  local source="$1"
  local size="$2"
  local destination="$3"
  mkdir -p "$(dirname "$destination")"
  "$RSVG_CONVERT" --width "$size" --height "$size" --output "$destination" "$source"
}

resize_rgb() {
  local source="$1"
  local size="$2"
  local destination="$3"
  mkdir -p "$(dirname "$destination")"
  "$MAGICK" "$source" -filter Lanczos -resize "${size}x${size}!" \
    -alpha off -strip -define png:color-type=2 "PNG24:$destination"
}

render_svg "$APP_SVG" 1024 assets/brand/app_icon.png
render_svg "$FOREGROUND_SVG" 1024 assets/brand/app_icon_foreground.png
render_svg "$SPLASH_SVG" 1024 assets/brand/splash_mark.png

# Apple requires an opaque RGB app-icon master. Fill the canonical icon's
# transparent rounded-square corners with the same leaf green as its background.
"$MAGICK" assets/brand/app_icon.png -background "$LEAF_GREEN" -alpha remove \
  -alpha off -strip -define png:color-type=2 PNG24:assets/brand/app_icon_master_1024.png

android_densities=(mdpi hdpi xhdpi xxhdpi xxxhdpi)
legacy_sizes=(48 72 96 144 192)
foreground_sizes=(108 162 216 324 432)
for index in "${!android_densities[@]}"; do
  density="${android_densities[$index]}"
  legacy_size="${legacy_sizes[$index]}"
  foreground_size="${foreground_sizes[$index]}"
  mipmap_dir="android/app/src/main/res/mipmap-$density"

  render_svg "$APP_SVG" "$legacy_size" "$mipmap_dir/ic_launcher.png"
  render_svg "$APP_SVG" "$legacy_size" "$mipmap_dir/ic_launcher_round.png"
  render_svg "$FOREGROUND_SVG" "$foreground_size" "$mipmap_dir/ic_launcher_foreground.png"
done

# flutter_launcher_icons follows Contents.json and generates every required iOS
# slot from the opaque master while preserving the repo's existing configuration.
"$DART" run flutter_launcher_icons

render_svg "$SPLASH_SVG" 150 ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage.png
render_svg "$SPLASH_SVG" 300 ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@2x.png
render_svg "$SPLASH_SVG" 450 ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage@3x.png

render_svg "$APP_SVG" 32 web/favicon.png
render_svg "$APP_SVG" 192 web/icons/Icon-192.png
render_svg "$APP_SVG" 512 web/icons/Icon-512.png
resize_rgb assets/brand/app_icon_master_1024.png 192 web/icons/Icon-maskable-192.png
resize_rgb assets/brand/app_icon_master_1024.png 512 web/icons/Icon-maskable-512.png

for size in 16 32 64 128 256 512 1024; do
  resize_rgb assets/brand/app_icon_master_1024.png "$size" \
    "macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_$size.png"
done

# Build one multi-resolution Windows icon from transparent canonical artwork.
for size in 16 24 32 48 64 96 128 256; do
  render_svg "$APP_SVG" "$size" "$TMP_DIR/app_icon_$size.png"
done
"$MAGICK" \
  "$TMP_DIR/app_icon_16.png" \
  "$TMP_DIR/app_icon_24.png" \
  "$TMP_DIR/app_icon_32.png" \
  "$TMP_DIR/app_icon_48.png" \
  "$TMP_DIR/app_icon_64.png" \
  "$TMP_DIR/app_icon_96.png" \
  "$TMP_DIR/app_icon_128.png" \
  "$TMP_DIR/app_icon_256.png" \
  -strip windows/runner/resources/app_icon.ico

echo "Generated minted-coin icons for Android, iOS, web, macOS, and Windows."
