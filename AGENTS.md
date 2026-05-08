# AGENTS.md

This repo uses repo-local copied shared skills under `./.agent-local/skills`,
plus repo-specific skills under `./agent/skills`.

If the copied shared skills are missing, restore them before substantial work:

```bash
./agent/sync-shared-skills.sh
```

If auto-detect fails on this machine, pass the shared skills repo path once:

```bash
./agent/sync-shared-skills.sh /path/to/skills
```

This repo syncs whole shared skill bundles. When `/Users/luis/Repos/skills`
improves, rerun `./agent/sync-shared-skills.sh` to pick up new or improved
skills without changing this repo again.

## Product identity

This repo is a privacy-first Flutter currency converter for the Niduna portfolio.

Non-goals for normal feature work:

- no backend (Phase 1)
- no accounts
- no tracking / analytics
- no cloud sync

Primary app shell order:

- `Convert` — multi-currency conversion view
- `Favorites` — saved currency pairs
- `Charts` — historical exchange rate charts
- `Settings` — app config, Remove Ads IAP

## Read first

Before substantial work, read:

- `DEFINITIONS.md`
- `PLAN.md`
- `agent/README.md`

Then read only the relevant shared skill and repo-local guide for the task.

## Shared skills to use when relevant

Start with:

- `./.agent-local/skills/_shared/repo-bootstrap-check.SKILL.md`

Use these bundle folders when the task matches:

- `./.agent-local/skills/_shared/`
  Use for scope-shaping, research, planning, architecture framing, debugging, and review.
- `./.agent-local/skills/frontend/`
  Use for broad visual direction and design-system work that affects the app shell or shared UI language.
- `./.agent-local/skills/mobile/`
  Use for Flutter/mobile layout, architecture, emulator, verification, and QA workflows.
- `./.agent-local/skills/release/`
  Use for store, privacy, and release-readiness checks.
- `./.agent-local/skills/publish/google-stitch-workflow/`
  Use when generating or iterating UI concepts through Stitch-backed flows.

New or improved skills added inside those bundles become available in this repo
after rerunning `./agent/sync-shared-skills.sh`.

If repo-local rules conflict with a shared skill, prefer the repo-local rules.

## Repo-local skills and guides

Use these when the task is specifically about this repo:

- [`small-screen-ui-review`](/agent/skills/small-screen-ui-review/SKILL.md)
- Flutter code changes, model changes, persistence changes, refactors:
  [`flutter-verification`](/agent/skills/flutter-verification/SKILL.md)
- Emulator launch, rebuild, relaunch, demo/testing setup:
  [`emulator-runbook`](/agent/skills/emulator-runbook/SKILL.md)
- Broad feature requests, new tabs, anything that may expand scope:
  [`product-scope-check`](/agent/skills/product-scope-check/SKILL.md)
- Store compliance, privacy, ads, IAP, release preparation:
  [`store-release-check`](/agent/skills/store-release-check/SKILL.md)

Use the smallest useful set.

Preferred order for broad interface work in this repo:

```text
frontend-design-layer
→ agent/DESIGN_GUIDELINES.md (when created)
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
│       └── widgets/
│           └── ...              # Reusable widgets (each < 60 lines)
```

### Anti-patterns to avoid

- ❌ One giant 600-line main.dart with all widgets as private classes
- ❌ Copy-pasting widget code instead of extracting shared widgets
- ❌ Business logic inside UI widget files
- ❌ Screens that import things they don't need

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

## Quick reference for agents

### Repo structure at a glance

```
lib/
  main.dart                     — Entry point (5 lines)
  src/
    app.dart                  — MaterialApp + AppShell + BottomNav (80 lines)
    core/theme/
      app_theme.dart          — Colors, tokens, ThemeData (40 lines)
    features/
      convert/convert_screen.dart   — Convert tab
      favorites/favorites_screen.dart — Favorites tab
      charts/charts_screen.dart     — Charts tab
      settings/settings_screen.dart  — Settings tab
    shared/widgets/               — Reusable widgets (add as needed)
integration_test/
  minimal_smoke_test.dart      — Basic smoke test
  currency_smoke_test.dart     — Currency-specific smoke test
test_driver/
  screenshots_driver.dart      — Screenshot capture driver
scripts/
  check.sh                     — Verification (analyze + test)
  analyze.sh                   — Static analysis only
  test.sh                      — Unit tests
.devtools/
  run_ios_minimal_smoke.sh     — iOS smoke test runner
  capture_ios_screens.sh       — Screenshot capture
```

### Running the app

```bash
# iOS simulator (preferred for UI review)
flutter devices                                    # find booted simulator ID
flutter run -d <simulator_id>                      # build + run

# Smoke test
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/run_ios_minimal_smoke.sh
```

### Screenshot capture

```bash
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} SCREEN_OUTPUT_DIR=.tmp/screens/ios \
  ./.devtools/capture_ios_screens.sh
```

Screenshot locations:
- `.tmp/screens/ios/` — main capture output

### Google Stitch (design exploration)

Stitch is available via `mcporter`. Use it for design exploration only — never copy generated code directly.

For mcporter + Stitch setup and detailed workflow, see daily-calorie's `agent/STITCH.md`.

Shared Stitch skill: `./.agent-local/skills/publish/google-stitch-workflow/SKILL.md`

For major UI polish or redesign work, prefer this reference loop:

1. inspect `.tmp/screens/ios/` or capture fresh screenshots
2. gather 3-8 external references or Stitch concepts
3. extract the specific composition ideas worth reusing
4. implement in Flutter
5. compare the rendered result against the screenshot, not just the code diff

## Documentation rule

If you add a recurring workflow, strong UI rule, or new agent-facing convention,
update the relevant file under `agent/`.
