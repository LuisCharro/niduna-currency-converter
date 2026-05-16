# Devtools

This folder contains local development helpers for loading realistic sample data
into Android emulators and iOS simulators without changing app code.

## iOS seed script

```bash
./.devtools/seed_ios_simulator_sample_data.sh
```

What it does:

- generates a sample profile and rolling app data for the requested range
- writes them into the app's iOS simulator preferences plist
- terminates and relaunches the app on the selected simulator

## Android seed script

```bash
./.devtools/seed_emulator_sample_data.sh
```

What it does:

- generates a sample profile and rolling app data for the requested range
- writes them into the app's Android `SharedPreferences` XML
- force-stops and relaunches the app on the selected emulator

## Seeded iOS app run

```bash
./.devtools/run_seeded_ios_app.sh
```

What it does:

- installs the current debug build onto the selected iOS simulator
- seeds the sample dataset
- launches the app without a follow-up `flutter run`

Use this when you want to review seeded app state on iOS and avoid the common
workflow mistake where a later reinstall drops the sample data and sends the
app back to onboarding.

## Seed data customization

The seed data definition lives in `.devtools/sample_seed_data.dart`.

**This file is app-specific.** The template provides a skeleton showing the
expected structure. Each app must implement its own domain-specific data:

- Profile fields (age, settings, preferences, etc.)
- Log/day entries with realistic variation across phases
- Saved templates or favorites
- Weight or other tracked metrics

To customize for your app, copy the skeleton and fill in:
1. Storage key constants (match your SharedPreferences keys)
2. Profile JSON shape (match your user profile model)
3. Day log JSON structure (match your daily entry model)
4. Template/saved-item definitions (match your saved item model)

## iOS screenshot capture

```bash
./.devtools/capture_ios_screens.sh
```

What it does:

- optionally reseeds the simulator with sample data first
- runs an `integration_test` flow against the selected iOS simulator
- navigates key app views and captures screenshots into `.tmp/screens/ios/`
- doubles as a basic end-to-end smoke pass for those flows

Useful environment variables:

- `IOS_SIMULATOR_ID`
- `FLUTTER_BIN`
- `SCREEN_OUTPUT_DIR`
- `SEED_BEFORE_CAPTURE`
- `CAPTURE_TARGET_PATH`

## Reference capture scripts

Focused screenshot capture flows for specific app surfaces:

```bash
./.devtools/capture_ios_onboarding_reference_screens.sh    # Onboarding flow
./.devtools/capture_ios_seeded_reference_screens.sh        # Main screens with data
./.devtools/capture_ios_add_entry_reference_screens.sh     # Add-entry / editing flow
./.devtools/capture_ios_settings_reference_screens.sh      # Settings deep dive
./.devtools/capture_ios_post_onboarding_reference_screens.sh  # Empty post-onboarding state
./.devtools/capture_ios_ui_review_bundle.sh                # ALL captures in one run + manifest
```

Each script writes to its own subdirectory under `.tmp/screens/ios/`.

## Android screenshot capture

```bash
./.devtools/capture_android_screens.sh
```

Seeds data in-process and captures screenshots on Android emulator.

## iOS minimal smoke test

```bash
./.devtools/run_ios_minimal_smoke.sh
```

Fast sanity check after code changes.

## iOS build + reinstall + launch

```bash
./.devtools/sim_reinstall_build.sh
```

What it does:

- builds the current iOS simulator app bundle
- terminates/uninstalls the old app from the target simulator
- installs the new bundle and launches it

Useful environment variables:

- `IOS_SIMULATOR_ID`
- `IOS_BUNDLE_ID` or `BUNDLE_ID`
- `IOS_APP_PATH` (default: `build/ios/iphonesimulator/Runner.app`)
- `BUILD_FIRST` (`1` default, set `0` to skip build)

Important:

- run only one iOS `flutter drive` smoke or screenshot script at a time
- do not start multiple scripts in parallel on the same simulator
- if another session is active, stop it first
- after a broken `flutter drive` run, restore normal state with:

```bash
IOS_SIMULATOR_ID=<ios_simulator_id> BUNDLE_ID={{BUNDLE_ID}} \
  ./.devtools/sim_reinstall_build.sh
```

## Environment variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `IOS_SIMULATOR_ID` | Target iOS simulator UUID | `booted` |
| `IOS_BUNDLE_ID` | iOS bundle identifier | `{{BUNDLE_ID}}` |
| `BUNDLE_ID` | Alias for IOS_BUNDLE_ID | `{{BUNDLE_ID}}` |
| `ANDROID_SERIAL` | Target Android device/emulator | `emulator-5554` |
| `ANDROID_PACKAGE_NAME` | Android package name | `{{ANDROID_PACKAGE_NAME}}` |
| `ADB_BIN` | Explicit path to adb | auto-detected |
| `FLUTTER_BIN` | Explicit path to flutter | auto-detected |
| `SEED_DAYS` | Days of seed data to generate | `90` |
| `SCREEN_OUTPUT_DIR` | Screenshot output directory | `.tmp/screens/ios/` |
| `SEED_BEFORE_CAPTURE` | Reseed before capture | `0` |
| `CAPTURE_TARGET_PATH` | Integration test target path | default gallery |

## Notes

- Dates are not hardcoded. Generators use the current local date and fill backward.
- Sample data should be deterministic enough to be visually useful for testing charts, history, search states, and realistic month-to-month progression.
- For seeded iOS review, prefer `run_seeded_ios_app.sh` over running `flutter run` after seeding.
- `.tmp/` is intended for temporary local artifacts like captured screenshots (gitignored).
- When you need more coverage, extend your integration_test screenshot gallery or add a new focused reference-gallery test.
- For nested menus and long sections, prefer a focused reference-gallery test over one generic capture.
