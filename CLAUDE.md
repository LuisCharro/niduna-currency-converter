# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Privacy-first Flutter currency converter (Niduna portfolio). Phase 1 MVP: no backend, no accounts, no tracking, no cloud sync. Fiat rates come from Frankfurter (`api.frankfurter.dev`, no API key); everything is cached locally in SharedPreferences. Four tabs: Convert, Favorites, Charts, Settings.

**AGENTS.md is the canonical agent instruction file for this repo — read it before substantial work.** It covers skills, devtools script inventory, provider profiles, hidden dev UI, and current project state. Other key docs: `ARCHITECTURE.md` (data/cache/network layers — read before touching those), `CODE_PATTERNS.md` (reference implementations), `DEFINITIONS.md` / `ROADMAP.md` / `PLAN.md` (product scope and delivery order), `RELEASE_CHECKLIST.md` (release master order + per-step implementation notes).

**Session continuity:** PLAN.md's header block ends with a dated **Resume point** link to `docs/superpowers/plans/<date>-session-summary-and-next.md` — read the latest one when picking up work. **Sibling repo:** `/Users/luis/Niduna/niduna-site` (static HTML/CSS on Vercel, auto-deploys on push to main) hosts the privacy policy, the app's marketing page, and `RELEASE_PLAN.md` for the site-side release steps; the app's store screenshots feed its `assets/`.

## Commands

```bash
./scripts/check.sh              # pub get + analyze + test (the required verification gate)
./scripts/analyze.sh            # static analysis only
./scripts/test.sh               # all tests
flutter test test/path/to/some_test.dart          # single test file
flutter test --plain-name "test name substring"   # single test by name
./scripts/build_apk.sh          # Android release-style APK (release_safe profile)
./scripts/build_appbundle.sh    # Android AAB (release_safe profile)
```

If Flutter is not on `PATH`: `FLUTTER_BIN=/path/to/flutter ./scripts/check.sh`.

**Verification rule: never call work complete until `./scripts/check.sh` passes.** For UI work, additionally rebuild/hot-restart on emulator and verify visually with screenshots.

### Emulator / simulator workflows

Use the `.devtools/` scripts, never raw `flutter run` (it blocks the terminal) and never coordinate taps (`sim_tap.sh` is unreliable — use integration tests instead). Full inventory in AGENTS.md; the most common:

```bash
IOS_SIMULATOR_ID=$IOS_SIMULATOR_ID ./.devtools/run_ios_simulator_app.sh   # non-blocking launch
IOS_SIMULATOR_ID=$IOS_SIMULATOR_ID BUNDLE_ID=com.niduna.currencyConverter \
  ./.devtools/sim_reinstall_build.sh                                      # build + reinstall + launch after changes
ANDROID_PACKAGE_NAME=com.niduna.currency_converter \
  ./.devtools/android_reinstall_build.sh                                  # Android equivalent
./.devtools/sim_screenshot.sh [name]                                      # manual iOS screenshot
IOS_SIMULATOR_ID=$IOS_SIMULATOR_ID ./.devtools/run_ios_minimal_smoke.sh   # smoke test
```

## Architecture

MVVM with strict layering (details in `ARCHITECTURE.md`):

- **Widgets** (`features/*/widgets/`) render only — no repository calls, no business logic. Callbacks passed top-down; children never receive the controller itself.
- **Controllers** (`features/*/presentation/`, `ChangeNotifier`) connect services to UI state — no cache/network logic. Immutable state classes with `copyWith`.
- **Services** (`lib/src/core/`) hold pure business logic — zero Flutter widget imports.
- **No cross-feature imports.** Features share via `core/` (rates, theme, localization, monetization, home-widget push) and `shared/widgets/`.
- Interfaces are abstract (`RatesClient`, `RatesCache`, `ChartRepository`); concrete implementations injected — this is what makes the planned Phase 2 backend swap a no-UI-change operation.

Data flow: `RatesService` orchestrates cache-first + TTL (latest rates: 1h TTL per base; historical: no TTL, keyed by base+quote+range) and deduplicates concurrent requests. Favorites reuses Convert's snapshot (0 extra API calls). Note: `features/convert/data/` is a legacy layer mid-migration to `core/rates/` — check `ARCHITECTURE.md` "Planned Refactor" before touching it.

UI strings live in `lib/src/core/localization/ui_copy*.dart` (facade + part files per tab).

## Hard rules

- **File size budgets** (from AGENTS.md): screens ≤80 lines, shared widgets ≤60, controllers ≤100; split any file immediately at 200 lines, >3 nested Column/Row/Expanded levels, or a >30-line `build()`.
- **Version stays `0.x.x`** until MVP is explicitly confirmed (pubspec + Firebase deploy labels must match).
- **Provider profiles are build-time flags:** release builds stay `PROVIDER_PROFILE=release_safe` / `APP_DEV_MODE=false`; emulator/screenshot scripts default to `dev_coinpaprika` + dev mode. Never add a user-facing production provider toggle, never ship the CoinPaprika profile.
- **Monetization:** entitlement checks always go through `MonetizationController` (`core/monetization/`) — never duplicate them.
- Dark mode is free; do not gate it behind IAP.
- Test mocks live in the test file, not in `lib/`.

## Design work

Tokens and component specs are in `DESIGN.md`; theme lives in `lib/src/core/theme/` (`app_theme.dart`, `app_text_styles.dart`, `app_decorations.dart`). The loop for UI work: implement → `./scripts/check.sh` → rebuild on emulator → screenshot via devtools scripts → compare rendered result against design intent (not just the code diff).
