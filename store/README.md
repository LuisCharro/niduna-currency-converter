# Google Play store assets

Everything needed for the Play Console listing, generated locally.

## Contents

- `listing/<lang>.md` — title, short description, full description for
  en, de, es, fr, it. Character limits noted inside each file.
- `graphics/feature_graphic.png` — 1024x500 feature graphic.
  Background source: `graphics/feature_graphic_bg.svg`; text is composited
  with the repo fonts via ImageMagick (command in git history / below).
- `screenshots/` — 6 framed phone screenshots, 1080x1920
  (4 light + 2 dark, captioned, ad-free).

## Regenerating screenshots

1. Capture raw ad-free screens on the emulator (sets the Remove Ads
   entitlement and forces light mode for deterministic order):

   ```bash
   CAPTURE_TARGET_PATH=integration_test/store_screenshots_test.dart \
     SCREEN_OUTPUT_DIR=.tmp/screens/store-raw \
     .devtools/capture_android_screens.sh
   ```

2. Compose the framed store images:

   ```bash
   CAPTURES_DIR="$PWD/.tmp/screens/store-raw" \
     .devtools/compose_store_screenshots.sh
   ```

## Regenerating the feature graphic

Render `graphics/feature_graphic_bg.svg` to PNG (ImageMagick), then
annotate with Fraunces-ExtraBold (title), Manrope-SemiBold (tagline) and
Manrope-ExtraBold (NIDUNA overline) — see the compose command in the
repo history (commit introducing this file) or rebuild via the same
pattern as `.devtools/compose_store_screenshots.sh`.

## Still needed from Play Console (not generatable locally)

- Content rating questionnaire, Data Safety form
- Real AdMob app + unit IDs (replace test IDs)
- App signing / upload key flow (see RELEASE_CHECKLIST.md)
