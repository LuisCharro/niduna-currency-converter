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
- `flutter-verification.SKILL.md` — Flutter verification workflow
- `flutter-feature-architecture-bootstrap.SKILL.md` — feature structure
- `flutter-architecture-boundaries.SKILL.md` — architecture boundaries
- `flutter-small-screen-ui.SKILL.md` — small screen layout
- `flutter-android-emulator-startup-playbook.SKILL.md` — Android emulator setup
- `flutter-integration-test-ui-automation.SKILL.md` — integration test automation

**Mobile (general):**
- `mobile-ui-review.SKILL.md` — mobile UI layout review
- `mobile-qa-handoff.SKILL.md` — QA handoff
- `mobile-architecture-boundaries.SKILL.md` — mobile architecture
- `chart-ux-review.SKILL.md` — chart UX review

**Frontend:**
- `frontend-design-layer.SKILL.md` — entry point for visual/UI work
- `frontend-design-direction.SKILL.md` — design direction
- `design-system-consistency.SKILL.md` — design token consistency
- `frontend-implementation-baseline.SKILL.md` — frontend standards

**Frontend (Stitch Design):**
- `publish/google-stitch-workflow/SKILL.md` — Stitch-assisted UI design

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
│   ├── app.dart                 # MaterialApp + AppShell navigation (80 lines)
│   ├── core/
│   │   └── theme/
│   │       └── app_theme.dart    # Colors, tokens (40 lines)
│   ├── features/
│   │   ├── convert/
│   │   │   └── convert_screen.dart   # Convert tab content
│   │   ├── favorites/
│   │   │   └── favorites_screen.dart # Favorites tab content
│   │   ├── charts/
│   │   │   └── charts_screen.dart     # Charts tab content
│   │   └── settings/
│   │       └── settings_screen.dart  # Settings tab content
│   └── shared/
│       └── widgets/               # Reusable widgets (each < 60 lines)
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
3. Add imports to `app.dart` only for the new screen
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

## Common Commands

```bash
# iOS simulator launch (non-blocking, preferred for agent workflows)
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/run_ios_simulator_app.sh

# Stop running app
xcrun simctl terminate <simulator_id> com.niduna.currencyConverter

# Smoke test
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/run_ios_minimal_smoke.sh

# Screenshots via integration test
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} SCREEN_OUTPUT_DIR=.tmp/screens/ios \
  ./.devtools/capture_ios_screens.sh

# Manual screenshot (any time)
./.devtools/sim_screenshot.sh [name]

# Tap simulator at coordinates
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

# Seed iOS simulator only (app already installed)
SEED_DAYS=90 ./.devtools/seed_ios_simulator_sample_data.sh

# Capture reference screenshots (all surfaces in one bundle)
./.devtools/capture_ios_ui_review_bundle.sh
```

**Important:** Always use `run_ios_simulator_app.sh` in agent workflows. Raw `flutter run` blocks the terminal until the app terminates. The script uses `setsid` to launch the Flutter process in the background, allowing the agent to continue executing other commands.

## Devtools Scripts Inventory

### Simulator Interaction

| Script | Purpose | Key Env Vars |
|--------|---------|-------------|
| `run_ios_simulator_app.sh` | Launch app non-blocking | `IOS_SIMULATOR_ID`, `BUNDLE_ID` |
| `run_ios_minimal_smoke.sh` | Run smoke test | `IOS_SIMULATOR_ID` |
| `capture_ios_screens.sh` | Integration-test screenshots | `IOS_SIMULATOR_ID`, `SCREEN_OUTPUT_DIR`, `IOS_BUNDLE_ID` |
| `sim_screenshot.sh` | Manual screenshot | `IOS_SIMULATOR_ID` |
| `sim_tap.sh` | Tap coordinates | `IOS_SIMULATOR_ID` |
| `sim_wait_ready.sh` | Poll app ready state | `IOS_SIMULATOR_ID` |
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
