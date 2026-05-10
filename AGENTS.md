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

**Publish:**
- `publish/google-stitch-workflow/SKILL.md` — Stitch-assisted UI design

**Release:**
- `store-release-check.SKILL.md` — store release checklist
- `store-metadata-review.SKILL.md` — store metadata review
- `privacy-surface-check.SKILL.md` — privacy surface review
- `mobile-release-qa.SKILL.md` — mobile release QA

### Starter
- `./.agent-local/skills/_shared/repo-bootstrap-check.SKILL.md`

If repo-local rules conflict with a shared skill, prefer the repo-local rules.

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
# Launch app in background (non-blocking) — preferred for agent workflows
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/run_ios_simulator_app.sh

# The above does NOT block. App runs detached. To stop it:
# xcrun simctl terminate <simulator_id> com.niduna.currencyConverter

# Raw flutter run (BLOCKS terminal — avoid in agent workflows)
flutter run -d <simulator_id>

# Smoke test
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/run_ios_minimal_smoke.sh
```

**Important:** Always use `run_ios_simulator_app.sh` in agent workflows. Raw `flutter run` blocks the terminal until the app terminates. The script uses `setsid` to launch the Flutter process in the background, allowing the agent to continue executing other commands.

### Screenshot capture

```bash
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} SCREEN_OUTPUT_DIR=.tmp/screens/ios \
  ./.devtools/capture_ios_screens.sh
```

Screenshot locations:
- `.tmp/screens/ios/` — main capture output

### Google Stitch (design exploration)

Stitch is available via `mcporter`. Use it for design exploration only — never copy generated code directly.

For mcporter + Stitch setup and detailed workflow, see daily-calorie's `.agent/STITCH.md`.

Shared Stitch skill: `./.agent-local/skills/publish/google-stitch-workflow/SKILL.md`

For major UI polish or redesign work, prefer this reference loop:

1. inspect `.tmp/screens/ios/` or capture fresh screenshots
2. gather 3-8 external references or Stitch concepts
3. extract the specific composition ideas worth reusing
4. implement in Flutter
5. compare the rendered result against the screenshot, not just the code diff

## Documentation rule

If you add a recurring workflow, strong UI rule, or new agent-facing convention,
update the relevant file under `.agent/`.
