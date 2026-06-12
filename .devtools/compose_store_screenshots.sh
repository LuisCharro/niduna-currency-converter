#!/usr/bin/env bash
# Compose Google Play store screenshots (1080x1920) from raw app captures.
#
# Input: raw 1080x2400 captures from the visual audit pipeline, e.g.
#   CAPTURE_TARGET_PATH=integration_test/visual_audit_test.dart \
#     SCREEN_OUTPUT_DIR=.tmp/screens/audit .devtools/capture_android_screens.sh
# Output: store/screenshots/NN-name.png with brand background + caption.
#
# Requires ImageMagick 7 (magick). Override with MAGICK_BIN.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/.." && pwd)"
captures="${CAPTURES_DIR:-${repo_root}/.tmp/screens/audit-final}"
out="${repo_root}/store/screenshots"
magick_bin="${MAGICK_BIN:-magick}"
if ! command -v "${magick_bin}" >/dev/null 2>&1; then
  magick_bin="/c/Program Files/ImageMagick-7.1.2-Q16-HDRI/magick.exe"
fi

serif="${repo_root}/fonts/fraunces/Fraunces-ExtraBold.ttf"
light_bg="#EFEDE4"
light_ink="#1C1F18"
dark_bg="#0D120B"
dark_ink="#E8ECE2"

mkdir -p "${out}"

compose() {
  local src="$1" dest="$2" caption="$3" bg="$4" ink="$5"
  # Scale capture to fit, round its corners, drop onto branded canvas
  # with the caption set in Fraunces at the top.
  "${magick_bin}" "${captures}/${src}" -resize x1500 \
    \( +clone -alpha extract \
       -draw 'fill black polygon 0,0 0,36 36,0 fill white circle 36,36 36,0' \
       \( +clone -flip \) -compose Multiply -composite \
       \( +clone -flop \) -compose Multiply -composite \
    \) -alpha off -compose CopyOpacity -composite \
    /tmp/_shot.png
  "${magick_bin}" -size 1080x1920 "xc:${bg}" \
    \( /tmp/_shot.png \) -gravity center -geometry +0+115 -composite \
    -font "${serif}" -pointsize 64 -fill "${ink}" -gravity north \
    -annotate +0+110 "${caption}" \
    "${out}/${dest}"
  echo "  ${dest}"
}

echo "Composing store screenshots from ${captures}..."
compose light-01-convert.png  01-convert.png   "Every currency,\none glance"      "${light_bg}" "${light_ink}"
compose light-04-chart.png    02-chart.png     "Two years\nof history"            "${light_bg}" "${light_ink}"
compose light-02-picker.png   03-picker.png    "40 currencies\n+ 11 crypto"       "${light_bg}" "${light_ink}"
compose light-03-favorites.png 04-favorites.png "Pin the pairs\nyou live in"      "${light_bg}" "${light_ink}"
compose dark-01-convert.png   05-dark.png      "Beautiful\nin dark mode"          "${dark_bg}"  "${dark_ink}"
compose dark-04-chart.png     06-dark-chart.png "Charts,\nday or night"           "${dark_bg}"  "${dark_ink}"
rm -f /tmp/_shot.png
echo "Done -> ${out}"
