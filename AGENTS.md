# AGENTS.md

This repo uses repo-local copied shared skills under `./.agent-local/skills`,
plus repo-specific skills under `./.agent/skills`.

If the copied shared skills are missing, restore them before substantial work:

```bash
./agent/sync-shared-skills.sh
```

If auto-detect fails on this machine, pass the shared skills repo path once:

```bash
./agent/sync-shared-skills.sh /path/to/skills
```

This repo syncs whole shared skill bundles. When the shared skills repo
improves, rerun `./agent/sync-shared-skills.sh` to pick up new or improved
skills without changing this repo again.

## Current state (2026-06-13)

- **Branch:** `main` is the canonical branch. `release-prep`,
  `feature/widget-restore`, `feature/ios-widget-target` are kept
  around as references; all their useful code is already on `main`.
- **Build:** `flutter build appbundle --release` works, AAB is
  signed (v2, 50 MB). `flutter build apk --release` works (58 MB).
  `flutter build ios --simulator --debug` works, app installs and
  runs on iPhone 17 Pro sim (iOS 26.5).
- **Tests:** 192/192 pass. `flutter analyze` is clean.
- **Home-screen widgets:**
  - **Android:** code complete, receiver enabled on `main`, and the
    Dart bridge already pushes widget data after rates load. Remaining
    work is launcher/runtime verification, not manifest wiring.
  - **iOS:** code complete, Xcode project target wired up, currently
    **disabled by default** (Embed App Extensions phase removed so
    iOS sim install works). Restore via
    `GEM_HOME=/opt/homebrew/Cellar/cocoapods/1.16.2_2/libexec ruby
    ios/scripts/add_widget_target.rb` (idempotent) when testing on
    real iPhone. Blocked on iOS 26 sim install bug.
  - See `docs/release-prep/README.md` for full state + restoration.
- **Release status:** see `RELEASE_CHECKLIST.md` for the full
  Blocker Summary. Code path complete. 3 P1 items remaining
  (AdMob IDs, keystore password, privacy policy URL) are all
  external or one-line config swaps.
- **Review report:** `docs/REVIEW-2026-06-01.md` — full audit done
  2026-06-01/02. Read it before starting substantial new work.

## Product identity

This repo is a privacy-first Flutter currency converter for the Niduna portfolio.

Non-goals for normal feature work:

- no backend (Phase 1)
- no accounts
- no tracking / analytics
- no cloud sync
- no complex food database

Primary app shell order:

- `Convert` — multi-currency conversion view
- `Favorites` — saved currency pairs
- `Charts` — historical exchange rate charts
- `Settings` — app config, Remove Ads IAP

For the current truth on Favorites nav visibility, widgets, trend arrows,
and chart-comparison status, see
`docs/superpowers/plans/2026-06-13-local-feature-status-harmonization.md`.

## Versioning policy (pre-MVP)

Until this app reaches a validated MVP milestone, keep the app version in
`0.x.x` (never `1.x.x`).

Rules for this phase:

- `pubspec.yaml` version must stay `0.x.x+build`
- Firebase deploy script version labels must match the same `0.x.x` line
- Move to `1.0.0` only when MVP scope is explicitly confirmed

Current baseline:

- App version: `0.1.0+1`
- Firebase version label: `0.1.0`

## Read first

Before substantial work, read:

- `DEFINITIONS.md`
- `ROADMAP.md`
- `PLAN.md`
- `agent/README.md`

Then read only the relevant shared skill and repo-local guide for the task.

## Available skills

### Repo-specific (`.agent/skills/`)
- `small-screen-ui-review/SKILL.md` — small phone layout review
- `flutter-verification/SKILL.md` — Flutter code verification
- `emulator-runbook/SKILL.md` — emulator launch and testing
- `product-scope-check/SKILL.md` — scope creep prevention
- `store-release-check/SKILL.md` — store compliance and release
- `icon-generation/SKILL.md` — currency-flag icon generation with mmx CLI; general mmx reference is the shared skill `mobile/minimax-cli.SKILL.md`

### Knowledge base (`.agent/`)
- `ICON_GENERATION_KNOWLEDGE.md` — live findings from icon gen work: audit scores, winning prompts, per-currency tips, vision tool comparison, quota tracking

### Shared (`.agent-local/skills/`)

**_shared:**
- `repo-bootstrap-check.SKILL.md` — first-time repo assessment
- `app-architecture-bootstrap.SKILL.md` — architecture framing
- `repo-rules-layering.SKILL.md` — instruction layering guidance
- `repo-devtools-layout.SKILL.md` — script/tooling placement
- `changed-code-review.SKILL.md` — code review from diff/PR
- `commit-message-quality.SKILL.md` — commit message conventions
- `ai-code-review.SKILL.md` — AI-generated code review
- `problem-shaping.SKILL.md` — problem framing before implementation

**Mobile/Flutter:**
- `flutter/flutter-verification.SKILL.md` — Flutter verification workflow
- `flutter/flutter-feature-architecture-bootstrap.SKILL.md` — feature structure
- `flutter/flutter-architecture-boundaries.SKILL.md` — architecture boundaries
- `flutter/flutter-small-screen-ui.SKILL.md` — small screen layout
- `flutter/flutter-android-emulator-startup-playbook.SKILL.md` — Android emulator setup
- `flutter/flutter-integration-test-ui-automation.SKILL.md` — integration test automation

**Mobile (general):**
- `mobile/mobile-ui-review.SKILL.md` — mobile UI layout review
- `mobile/mobile-qa-handoff.SKILL.md` — QA handoff
- `mobile/mobile-architecture-boundaries.SKILL.md` — mobile architecture
- `mobile/chart-ux-review.SKILL.md` — chart UX review

**Frontend:**
- `frontend/frontend-design-layer.SKILL.md` — entry point for visual/UI work
- `frontend/frontend-design-direction.SKILL.md` — design direction
- `frontend/design-system-consistency.SKILL.md` — design token consistency
- `frontend/frontend-implementation-baseline.SKILL.md` — frontend standards

**Frontend (Stitch Design):**
- `publish/google-stitch-workflow/google-stitch-workflow.SKILL.md` — Stitch-assisted UI design

**Release:**
- `store-release-check.SKILL.md` — store release checklist
- `store-metadata-review.SKILL.md` — store metadata review
- `privacy-surface-check.SKILL.md` — privacy surface review
- `mobile-release-qa.SKILL.md` — mobile release QA

### Starter
- `./.agent-local/skills/_shared/repo-bootstrap-check.SKILL.md`

If repo-local rules conflict with a shared skill, prefer the repo-local rules.

## Design Workflow

For UI work, follow this loop:

```
1. Read DESIGN.md for tokens and component specs
2. Read .agent/DESIGN_GUIDELINES.md (when created) for design philosophy
3. Implement changes in Flutter code
4. Run ./scripts/check.sh (analyze + test)
5. Hot restart running emulator app
6. Capture screenshots with devtools scripts
7. Compare rendered result against design intent
8. Repeat until verified
```

Preferred order for interface work:

```
frontend-design-layer
→ .agent/DESIGN_GUIDELINES.md (when created)
→ frontend-design-direction
→ small-screen-ui-review
→ flutter-verification
```

## Modularity rules

**Critical: keep files small. Every screen/widget file must be under ~200 lines.**

### File size budget

| File type | Max lines | Rationale |
|-----------|----------|-----------|
| Screen (ConvertScreen, etc.) | **80 lines** | One screen = one focused responsibility |
| Shared widget (card, row, tile) | **60 lines** | One widget = one reusable piece |
| Theme / constants | **50 lines** | Pure data, no logic |
| App shell (AppShell) | **80 lines** | Navigation only, no business logic |
| State management / provider | **100 lines** | If needed, keep tiny |

### Split triggers

Split a file **immediately** when any of these is true:

- File exceeds **200 lines**
- A widget has more than **3 nested levels** of Column/Row/Expanded
- A build() method has more than **30 lines**
- You find yourself scrolling to understand what a widget does
- A file does **more than one thing** (e.g., "AmountCard + ResultCard + Settings")

### Import structure

```
lib/
├── main.dart                    # Entry point (5 lines)
├── src/
│   ├── app.dart                 # MaterialApp config + entry point (~48 lines)
│   ├── app_shell.dart           # AppShell navigation + async init (~204 lines)
│   ├── core/
│   │   ├── localization/
│   │   │   ├── ui_copy.dart     # UiCopy class facade (part files below)
│   │   │   ├── ui_copy_general.dart    # General labels (part)
│   │   │   ├── ui_copy_convert.dart    # Convert strings (part)
│   │   │   ├── ui_copy_charts.dart     # Charts strings (part)
│   │   │   ├── ui_copy_locked_pairs.dart # Locked pair strings (part)
│   │   │   └── ui_copy_settings.dart   # Settings strings (part)
│   │   ├── monetization/
│   │   │   ├── monetization_controller.dart # Main controller (~177 lines)
│   │   │   └── monetization_entitlements.dart # Entitlement logic (~132 lines)
│   │   ├── rates/
│   │   │   ├── rates_service.dart         # Cache+network orchestrator (~144 lines)
│   │   │   └── rates_service_helpers.dart # Validation/helpers (~219 lines)
│   │   ├── theme/
│   │   │   ├── app_theme.dart       # ThemeData construction (~192 lines)
│   │   │   ├── app_text_styles.dart # All text styles (~200 lines)
│   │   │   └── app_decorations.dart # Shadows/padding helpers (~51 lines)
│   │   └── widget/
│   │       └── home_widget_provider.dart # Home widget data push
│   ├── features/
│   │   ├── convert/
│   │   │   ├── presentation/
│   │   │   │   ├── convert_controller.dart      # Main controller (~176 lines)
│   │   │   │   ├── convert_controller_loading.dart # Load/refresh logic
│   │   │   │   └── convert_state_helpers.dart   # State transforms (~72 lines)
│   │   │   ├── data/
│   │   │   │   ├── frankfurter_latest_rates_client.dart (+yesterday fetch)
│   │   │   │   ├── latest_rates_client.dart (abstract, +fetchYesterdayRates)
│   │   │   │   ├── latest_rates_repository.dart (+fetchYesterdayRates)
│   │   │   │   └── multi_provider_latest_rates_repository.dart
│   │   │   ├── domain/
│   │   │   │   ├── latest_rates_snapshot.dart (has previousRates field)
│   │   │   │   └── rate_freshness.dart (~168 lines)
│   │   │   └── widgets/
│   │   │       ├── amount_keypad.dart          # Keypad shell (~48 lines)
│   │   │       ├── amount_input_header.dart    # Header orchestrator (~67 lines)
│   │   │       ├── amount_input_sheet.dart     # Bottom sheet (~122 lines)
│   │   │       ├── conversion_lens_sheet.dart  # Lens dialog (~166 lines)
│   │   │       ├── currency_picker_sheet.dart  # Convert picker (~94 lines)
│   │   │       ├── currency_row_swipe_actions.dart # Swipe actions (~114 lines)
│   │   │       ├── quote_identity.dart         # Currency identity row
│   │   │       ├── quote_value.dart            # Converted value display (~50 lines)
│   │   │       ├── visible_rates_list.dart     # Scrollable rates list
│   │   │       ├── amount_display_text.dart    # Adaptive text (~61 lines)
│   │   │       ├── amount_done_button.dart     # Done button (~30 lines)
│   │   │       ├── amount_expression_state.dart# Expression mixin (~35 lines)
│   │   │       ├── amount_key.dart             # Digit key widget (~47 lines)
│   │   │       ├── amount_op_key.dart          # Operator key (~60 lines)
│   │   │       ├── digit_grid.dart             # 3x4 grid (~42 lines)
│   │   │       ├── trend_badge.dart            # Arrow+% badge (~53 lines)
│   │   │       ├── currency_chip.dart          # Currency pill (~37 lines)
│   │   │       ├── amount_sheet_handle.dart    # Drag handle (~21 lines)
│   │   │       ├── conversion_lens_positioner.dart # Position math (~162 lines)
│   │   │       ├── conversion_lens_quick_values.dart # Preset amounts (~122 lines)
│   │   │       ├── conversion_lens_reverse_target.dart # Reverse target (~71 lines)
│   │   │       ├── swipe_action_widgets.dart   # Action rail (~196 lines)
│   │   │       └── swipe_draggable_card.dart   # Drag card (~236 lines)
│   │   ├── favorites/
│   │   │   ├── favorites_screen.dart
│   │   │   ├── data/
│   │   │   │   ├── favorites_store.dart        # Store logic (~80 lines)
│   │   │   │   └── favorite_usage_tracker.dart # Usage tracking mixin (~38 lines)
│   │   │   └── widgets/
│   │   │       ├── favorites_tab_body.dart     # Tab content with pull-to-refresh
│   │   │       └── favorites_rewarded_ad_player.dart (~187 lines)
│   │   ├── charts/
│   │   │   ├── presentation/
│   │   │   │   ├── charts_controller.dart      # Controller (~174 lines)
│   │   │   │   └── chart_state.dart            # Chart state (~77 lines)
│   │   │   ├── data/
│   │   │   │   └── rates_service_chart_repository.dart # Chart repo adapter
│   │   │   ├── domain/
│   │   │   │   └── chart_repository.dart       # Abstract interface
│   │   │   └── widgets/
│   │   │       ├── charts_screen.dart / charts_tab_body.dart
│   │   │       ├── chart_currency_picker_sheet.dart (~176 lines)
│   │   │       ├── chart_currency_tile.dart    # Tile widget (~184 lines)
│   │   │       ├── chart_pair_pill.dart        # Pair selector pill
│   │   │       ├── chart_temp_badge.dart       # 24h temp badge (~37 lines)
│   │   │       ├── rewarded_ad_player.dart     # Ad player (~186 lines)
│   │   │       ├── rate_chart.dart             # Chart widget (~193 lines)
│   │   │       └── chart_line_plot.dart        # Plot rendering (~190 lines)
│   │   └── settings/
│   │       ├── settings_screen.dart
│   │       └── widgets/
│   │           ├── iap_purchase_player.dart    # Purchase UI (~193 lines)
│   │           └── upgrade_shelf.dart          # Upgrade CTA (~168 lines)
│   └── shared/
│       └── widgets/
│           ├── floating_pill_nav.dart          # 4-tab nav
│           ├── settings_tile.dart              # SettingsTile etc.
│           ├── currency_flag_icon.dart         # Flag icon
│           ├── currency_flags.dart             # Flag map
│           ├── currency_colors.dart            # Color utils
│           ├── currency_section_header.dart    # Section header (moved from convert)
│           ├── sectioned_currency_picker.dart  # Sectioned picker (shared, ~149 lines)
│           └── animated_progress_bar.dart     # Progress bar (shared, reused by 3 players)
```

### Anti-patterns to avoid

- One giant 600-line main.dart with all widgets as private classes
- Copy-pasting widget code instead of extracting shared widgets
- Business logic inside UI widget files
- Screens that import things they don't need
- "God Object" pattern (one StatefulWidget holding ALL state)
- Card inside card inside card
- Full-width low-priority buttons
- Repeated explanatory copy above obvious controls
- File does more than one thing

### When adding a new feature

1. Create a new file under `src/features/<feature_name>/`
2. Keep the screen under 80 lines — if it grows, extract sub-widgets
3. Add imports to `app_shell.dart` only for the new screen
4. Run `flutter analyze` — if it passes, the structure is good

## Verification rule

Do not call app work complete until the relevant verification has passed.

Default verification:

```bash
./scripts/check.sh
```

If Flutter is not on `PATH`:

```bash
FLUTTER_BIN=/path/to/flutter ./scripts/check.sh
```

For UI work, hot restart or rebuild the running emulator app after successful checks.

## Provider Profiles

Provider selection is build-time controlled.

- Default safe profile: `PROVIDER_PROFILE=release_safe`
- Dev-only full crypto profile: `PROVIDER_PROFILE=dev_coinpaprika`
- Hidden developer UI flag: `APP_DEV_MODE=true|false`

Rules:

- Normal release-style builds must stay on `release_safe`
- Dev/emulator/screenshot flows may use `dev_coinpaprika`
- Do not add a normal user-facing Settings toggle that can switch providers in production
- Release builds must not ship the CoinPaprika dev profile

Current behavior:

- iOS/Android emulator and screenshot helper scripts default to:
  - `PROVIDER_PROFILE=dev_coinpaprika`
  - `APP_DEV_MODE=true`
- `scripts/build_apk.sh` and `scripts/build_appbundle.sh` default to:
  - `PROVIDER_PROFILE=release_safe`
  - `APP_DEV_MODE=false`

## Hidden Developer UI

The developer section in Settings is hidden in normal builds unless one of these is true:

- build sets `APP_DEV_MODE=true`
- user unlocks it from the `Version` row in Settings

Current secret gestures on the `Version` row:

- tap 7 times quickly
- or press and hold for 10 seconds

This toggles developer mode on or off.

## Common Commands

```bash
# iOS simulator launch (non-blocking, preferred for agent workflows)
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/run_ios_simulator_app.sh

# Build + reinstall + launch updated app (preferred after UI/code changes)
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} \
  BUNDLE_ID=com.niduna.currencyConverter \
  ./.devtools/sim_reinstall_build.sh

# Android emulator build + reinstall + launch updated app
ANDROID_SERIAL=${ANDROID_SERIAL:-booted} \
  ANDROID_PACKAGE_NAME=com.niduna.currency_converter \
  ./.devtools/android_reinstall_build.sh

# Override emulator to safe release-style providers if needed
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} \
  PROVIDER_PROFILE=release_safe \
  APP_DEV_MODE=false \
  ./.devtools/run_ios_simulator_app.sh

# Stop running app (fallback)
xcrun simctl terminate <simulator_id> com.niduna.currencyConverter

# Smoke test
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/run_ios_minimal_smoke.sh

# Screenshots via integration test
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} SCREEN_OUTPUT_DIR=.tmp/screens/ios \
  ./.devtools/capture_ios_screens.sh

# Manual screenshot (any time)
./.devtools/sim_screenshot.sh [name]

# Tap simulator at coordinates (UNRELIABLE — uses real mouse, misses target)
# For UI interaction verification, use integration tests (capture_ios_screens.sh, run_ios_minimal_smoke.sh) instead
./.devtools/sim_tap.sh <x> <y> [delay]

# Wait for app to be ready on simulator
./.devtools/sim_wait_ready.sh

# Fresh install (uninstall + run)
./.devtools/sim_fresh_install.sh

# Uninstall app from simulator
./.devtools/sim_uninstall.sh

# Capture all tabs
./.devtools/capture_tabs.sh

# Seed + launch iOS app with realistic sample data
./.devtools/run_seeded_ios_app.sh

# Android release-style build (safe profile by default)
./scripts/build_apk.sh

# Android App Bundle release-style build (safe profile by default)
./scripts/build_appbundle.sh

# Seed iOS simulator only (app already installed)
SEED_DAYS=90 ./.devtools/seed_ios_simulator_sample_data.sh

# Capture reference screenshots (all surfaces in one bundle)
./.devtools/capture_ios_ui_review_bundle.sh
```

**Important:** Always use `run_ios_simulator_app.sh` in agent workflows. Raw `flutter run` blocks the terminal until the app terminates. The script uses `setsid` to launch the Flutter process in the background, allowing the agent to continue executing other commands.

For build/reinstall workflows after code changes, prefer `sim_reinstall_build.sh` instead of long `xcrun simctl terminate/uninstall/install/launch` chains.

For Android device/emulator discovery before install:

```bash
./.devtools/list_android_emulators.sh
```

## Devtools Scripts Inventory

### Simulator Interaction

| Script | Purpose | Key Env Vars |
|--------|---------|-------------|
| `run_ios_simulator_app.sh` | Launch app non-blocking | `IOS_SIMULATOR_ID`, `BUNDLE_ID` |
| `run_ios_minimal_smoke.sh` | Run smoke test | `IOS_SIMULATOR_ID` |
| `capture_ios_screens.sh` | Integration-test screenshots | `IOS_SIMULATOR_ID`, `SCREEN_OUTPUT_DIR`, `IOS_BUNDLE_ID` |
| `sim_screenshot.sh` | Manual screenshot | `IOS_SIMULATOR_ID` |
| `sim_tap.sh` | Tap coordinates (UNRELIABLE — uses real mouse) | `IOS_SIMULATOR_ID` |
| `sim_wait_ready.sh` | Poll app ready state | `IOS_SIMULATOR_ID` |
| `sim_reinstall_build.sh` | Build + reinstall + launch updated app | `IOS_SIMULATOR_ID`, `BUNDLE_ID`, `IOS_APP_PATH`, `BUILD_FIRST` |
| `android_reinstall_build.sh` | Build + reinstall + launch updated app on Android | `ANDROID_SERIAL` (or auto-detect), `ANDROID_PACKAGE_NAME`, `ANDROID_APK_PATH`, `BUILD_FIRST` |
| `list_android_emulators.sh` | List connected devices + available AVDs | (none) |
| `sim_uninstall.sh` | Uninstall from simulator | `IOS_SIMULATOR_ID`, `BUNDLE_ID` |
| `sim_fresh_install.sh` | Uninstall + fresh run | `IOS_SIMULATOR_ID`, `BUNDLE_ID` |
| `capture_tabs.sh` | Auto-capture all tabs | `IOS_SIMULATOR_ID` |

### Seeded Testing

| Script | Purpose | Key Env Vars |
|--------|---------|-------------|
| `run_seeded_ios_app.sh` | Build + seed + launch iOS | `IOS_SIMULATOR_ID`, `SEED_DAYS`, `FLUTTER_BIN` |
| `seed_ios_simulator_sample_data.sh` | Seed iOS simulator prefs | `IOS_SIMULATOR_ID`, `SEED_DAYS` |
| `seed_emulator_sample_data.sh` | Seed Android shared prefs | `ANDROID_SERIAL`, `SEED_DAYS` |
| `generate_sample_prefs.dart` | Generate prefs from seed data | `--days`, `--format`, `--today` |
| `sample_seed_data.dart` | Seed data structure definition | (app-specific — customize per app) |

### Reference Capture

| Script | Purpose | Output Dir |
|--------|---------|------------|
| `capture_ios_onboarding_reference_screens.sh` | Onboarding flow | `onboarding-reference/` |
| `capture_ios_seeded_reference_screens.sh` | Main screens with data | `seeded-reference/` |
| `capture_ios_add_entry_reference_screens.sh` | Add-entry flow | `add-entry-reference/` |
| `capture_ios_settings_reference_screens.sh` | Settings deep dive | `settings-reference/` |
| `capture_ios_post_onboarding_reference_screens.sh` | Empty post-onboarding | `post-onboarding-reference/` |
| `capture_ios_ui_review_bundle.sh` | ALL captures + manifest | `ui-review-bundle/` |
| `capture_android_screens.sh` | Android emulator capture | `.tmp/screens/android/` |

All scripts use `IOS_SIMULATOR_ID` (UUID or "booted"). Scripts that target a specific app use `BUNDLE_ID` or `IOS_BUNDLE_ID`.

See `.devtools/README.md` for full documentation.

## Shared Widgets

Ready-to-use shared widgets:

- `lib/src/shared/widgets/floating_pill_nav.dart` — 4-tab floating nav (Today/Progress/History/Settings pattern; adapt to Convert/Favorites/Charts/Settings)
- `lib/src/shared/widgets/settings_tile.dart` — SettingsTile, SettingsSectionHeader, SettingsDivider
- `lib/src/shared/widgets/currency_flag_icon.dart` — Currency flag icon widget
- `lib/src/shared/widgets/currency_flags.dart` — Flag icon map
- `lib/src/shared/widgets/currency_colors.dart` — Currency color utilities
- `lib/src/shared/widgets/currency_section_header.dart` — Section header for grouped lists (moved from convert)
- `lib/src/shared/widgets/sectioned_currency_picker.dart` — Sectioned picker with geographic groups (Europe/Americas/AsiaPacific/MiddleEastAfrica/Crypto), used by both Convert and Charts pickers
- `lib/src/shared/widgets/animated_progress_bar.dart` — Animated progress bar, reused by iap_purchase_player, favorites_rewarded_ad_player, and rewarded_ad_player

## Google Stitch (design exploration)

Stitch is available via `mcporter`. Use it for design exploration only — never copy generated code directly.

Existing Stitch projects:
- `1489849311730997446` — Reference Driven Redesign (67 screens)
- `17704915596211555909` — Full App Redesign
- `1688116472298796651` — Today (Redesign)

Shared Stitch skill: `./.agent-local/skills/publish/google-stitch-workflow/SKILL.md`

For major UI polish or redesign work, prefer this reference loop:

1. inspect `.tmp/screens/ios/` or capture fresh screenshots
2. gather 3-8 external references or Stitch concepts
3. extract the specific composition ideas worth reusing
4. implement in Flutter
5. compare the rendered result against the screenshot, not just the code diff

## Repo-local guides

Use these when the task is specifically about this repo:

- `DEFINITIONS.md`
- `ROADMAP.md`
- `PLAN.md`
- `ARCHITECTURE.md`
- `agent/README.md`

Preferred order for broad interface work in this repo:

```text
frontend-design-layer
→ .agent/DESIGN_GUIDELINES.md (when created)
→ frontend-design-direction
→ small-screen-ui-review
→ flutter-verification
```

## Documentation rule

If you add a recurring workflow, strong UI rule, or new agent-facing convention,
update this file or create a new skill under `.agent/skills`.
