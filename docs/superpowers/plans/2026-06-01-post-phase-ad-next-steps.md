# Post Phase A-D — Next Steps Plan

> **Created:** 2026-06-01
> **Based on:** Commit `5d627f9` (Phase A-D complete + docs updated)
> **Branch:** `main`
> **Simulator:** iOS 26.5 — `87FB7A6A-58E4-4F45-A44E-EC071B06BC04`

---

## What Was Done This Session

| Phase | Scope | Result |
|-------|-------|--------|
| A | T1.1–T1.6 Critical fixes | JSON parser, SettingsController lifecycle, layout fix, chart repo interface, trend arrows pipeline, home widget data push |
| B | T2.1–T2.5 Test gaps | 37 new tests → **172 total passing** (+50 from baseline) |
| C | T3.1–T3.4 UX polish | Lens sheet split (471→4 files), picker dedup (-101 lines), input header split, pull-to-refresh on Favorites + Charts |
| D | T4.1–T4.8 File hygiene | All `lib/` files now under 200 lines; 11 oversized files split into ~30 focused files |
| Docs | AGENTS/ARCHITECTURE/PLAN | Updated import structures, file counts, feature tables, architecture diagrams |

**Commits:**
- `38c2998` — `refactor(app): deliver phase A-D stability and modularization` (79 files, +4254 -3395)
- `5d627f9` — `docs: update AGENTS, ARCHITECTURE, PLAN to reflect Phase A-D modularization`

**Test baseline:** 172 pass / 10 fail (all pre-existing `Binding has not yet been initialized`)
**Analyzer baseline:** 0 errors / 3 pre-existing info/warning

---

## Recommended Next Steps (Agreed Execution Order — 2026-06-01)

> **Decision:** Backend work (Phase 2/3) is deferred until post-publish and only resumes if there are users. Work below is code-only. Branch: `release-prep` (created from this commit).

| # | Item | Effort | Notes |
|---|---|---|---|
| 1 | Fix 10 pre-existing test failures | ~30m | `Binding has not yet been initialized` → add `TestWidgetsFlutterBinding.ensureInitialized()` in `setUp()` |
| 2 | Visual verify Phase A-D | ~1.5h | Capture all 4 tabs in light + dark mode, check trend arrows / sectioned picker / lens / pull-to-refresh |
| 3 | Dark mode audit | ~45m | Verify new widget splits use `Theme.of(context)` / `AppColors.dark` tokens |
| 4 | B1–B3: release keystore trio | ~25m | `keytool` to create `.jks`, write `key.properties` (gitignored), update `build.gradle.kts` signingConfigs.release |
| 5 | Phase 1.x chart tests | ~1.5h | Cross-provider formula tests (Frankfurter × fawazahmed0) for crypto/crypto + fiat/crypto charts |
| 6 | B5: privacy policy link in Settings | ~30m | New row in Settings widget that opens hosted URL (needs C1 hosted first — placeholder OK) |
| 7 | B6: build signed AAB | ~5m | `./scripts/build_appbundle.sh` smoke test with real keystore |
| 8 | UI Polish cycle (Phase 6) | open | Screenshot review + iterative refinement; never modify `AppColors.dark` |

The body sections below give the detailed "how" for each item. Items 5 and 8 are new and have their own sub-sections at the end of this file.

### Step 1: Visual Verification — Capture & Review Screenshots

**Why:** Trend arrows, pull-to-refresh, sectioned pickers, and the split widgets were all wired this session but never visually confirmed on device.

**Commands:**
```bash
IOS_SIMULATOR_ID=87FB7A6A-58E4-4F45-A44E-EC071B06BC04 \
  SCREEN_OUTPUT_DIR=.tmp/screens/ios/post-phase-ad \
  ./.devtools/capture_ios_screens.sh
```

Or individual tab screenshots:
```bash
IOS_SIMULATOR_ID=87FB7A6A-58E4-4F45-A44E-EC071B06BC04 \
  ./.devtools/sim_screenshot.sh convert
IOS_SIMULATOR_ID=87FB7A6A-58E4-4F45-A44E-EC071B06BC04 \
  ./.devtools/sim_screenshot.sh favorites
IOS_SIMULATOR_ID=87FB7A6A-58E4-4F45-A44E-EC071B06BC04 \
  ./.devtools/sim_screenshot.sh charts
IOS_SIMULATOR_ID=87FB7A6A-58E4-4F45-A44E-EC071B06BC04 \
  ./.devtools/sim_screenshot.sh settings
```

**What to check per tab:**
- [ ] **Convert**: Trend arrows visible on each currency row (small arrow + % badge); sectioned picker shows geographic groups; lens dialog opens and renders quick values
- [ ] **Favorites**: Pull-to-refresh triggers rate refresh; list renders correctly after split
- [ ] **Charts**: Pull-to-refresh reloads historical data; picker uses shared sectioned component; temp badge renders
- [ ] **Settings**: No regressions from controller lifecycle change; IAP buttons still work
- [ ] **Dark mode**: Toggle dark mode and repeat all checks above (we only touched light mode)

**If issues found:** Fix, rebuild (`sim_reinstall_build.sh`), re-capture.

**Estimated effort:** 30 min capture + 15 min review per tab

---

### Step 2: Fix Pre-Existing Test Failures (10 tests)

**Why:** 10 tests fail with `Binding has not yet been initialized`. These are all integration-test init issues that are straightforward to fix.

**Failing test pattern:**
```
Binding has not yet been initialized.
You must call TestWidgetsFlutterBinding.ensureInitialized() before using ...
```

**Fix approach:** Add `TestWidgetsFlutterBinding.ensureInitialized()` at the top of each failing test's `setUp()` or main test body.

**Files likely needing fixes:**
```bash
flutter test --reporter=expanded 2>&1 | grep "FAIL\|ERROR" | head -20
```

**Target:** Get from 172/182 passing to **180+ / 182** (all non-integration tests green).

**Estimated effort:** 20–30 min

---

### Step 3: Release Blockers (from RELEASE_CHECKLIST.md)

These are the remaining items before App Store / Play Store submission.

#### P6 — Release Keystore Signing
- Move from debug signing to proper release keystore
- See `RELEASE_CHECKLIST.md` items B1–B3
- Android only (iOS uses automatic signing)
- **Effort:** 30 min + key management setup

#### P8 — Privacy Policy URL
- Required by both stores before submission
- Host a privacy policy page (GitHub Pages, or Niduna site)
- Update `Info.plist` (iOS) and `AndroidManifest.xml` (Android) with URL
- See `RELEASE_CHECKLIST.md` items C1, B5
- **Effort:** 1–2 hours (writing + hosting + config)

#### P11 — Store Listing Assets
- Screenshots for both stores (use Step 1 captures as base)
- App descriptions, keywords, promotional text
- See `RELEASE_CHECKLIST.md` items C2–C11
- **Effort:** 2–3 hours

---

### Step 4: Dark Mode Audit

**Why:** All Phase A-D changes were brightness-gated or light-mode-only per project rules (`AppColors.dark` is untouchable). However:
- New widget splits may have hardcoded light-mode colors that don't adapt
- New extracted widgets should use `Theme.of(context)` but may have missed spots
- `app_text_styles.dart` and `app_decorations.dart` need dark-mode verification

**Approach:**
1. In running simulator: Settings → toggle Dark Mode
2. Capture all 4 tabs in dark mode
3. Compare against light-mode captures
4. Fix any color/contrast issues (use `AppColors.dark` tokens, never modify them)

**Estimated effort:** 45 min

---

### Step 5 (new): Phase 1.x — Chart tests for crypto/crypto and fiat/crypto formulas

**Why:** The only remaining Phase 1.x item. Multi-provider chart routing shipped in Phase A-D, but no test coverage for the cross-provider math.

**Where:** Add under `test/` in the charts feature. Likely `test/features/charts/data/multi_provider_chart_formula_test.dart` (verify exact path with `find test -name '*chart*' -name '*test*'`).

**Cases to cover:**
- BTC → ETH via USD bridge (fawazahmed0 only)
- BTC → USD direct (fawazahmed0)
- EUR → BTC via USD (Frankfurter × fawazahmed0)
- BTC → JPY via USD (Frankfurter × fawazahmed0)
- Edge: same-source vs cross-source
- Edge: stale cache + missing series

**Approach:** TDD — write failing tests, watch them fail (cross-provider math isn't tested today), implement minimum helper if needed, watch pass, refactor. Use the `_shared/test-driven-development.SKILL.md` in `.agent-local/skills/`.

**Estimated effort:** ~1.5h

### Step 6 (new): UI Polish cycle (Phase 6 of UI Redesign)

**Why:** Phases 1–5 of the UI redesign are done on `turbo/ui-redesign`. Phase 6 is the iterative polish loop: capture screens, compare to design intent, fix gaps, repeat.

**Per project rules (AGENTS.md):**
- Never modify `AppColors.dark` — use existing tokens
- Respect file-size caps (screen ≤ 80, widget ≤ 60, theme ≤ 50, app shell ≤ 80, controller ≤ 100)
- Use `Theme.of(context)` for theme-aware colors
- Run `./scripts/check.sh` after changes

**Loop:**
1. Capture screens with `.devtools/capture_ios_screens.sh` (light + dark, all 4 tabs)
2. Diff against design intent (`DESIGN.md` tokens, `.agent/DESIGN_GUIDELINES.md`)
3. File small targeted fix issues
4. Repeat

**Estimated effort:** open-ended. Do after steps 1–7 complete and external release work is unblocked. Can run in parallel with B6 / C1–C11 work.

## Quick-Start Commands for Next Session

When resuming work:

```bash
cd /Users/luis/Niduna/apps/currency-converter

# 1. Check current state
git status
git log --oneline -5
./scripts/check.sh

# 2. Boot simulator (if not already running)
xcrun simctl boot 87FB7A6A-58E4-4F45-A44E-EC071B06BC04
open -a Simulator

# 3. Build + reinstall after code changes
IOS_SIMULATOR_ID=87FB7A6A-58E4-4F45-A44E-EC071B06BC04 \
  BUNDLE_ID=com.niduna.currencyConverter \
  ./.devtools/sim_reinstall_build.sh

# 4. Run tests
flutter test --reporter=expanded

# 5. Capture screenshots
IOS_SIMULATOR_ID=87FB7A6A-58E4-4F45-A44E-EC071B06BC04 \
  ./.devtools/capture_tabs.sh
```

## Session Context (for AI agent resume)

- **Working directory:** `/Users/luis/Niduna/apps/currency-converter`
- **Branch:** `main`
- **Simulator ID:** `87FB7A6A-58E4-4F45-A44E-EC071B06BC04` (iOS 26.5, iPhone 17 Pro)
- **Bundle ID:** `com.niduna.currencyConverter`
- **Version:** `0.1.0+1`
- **Provider profile (dev):** `PROVIDER_PROFILE=dev_coinpaprika APP_DEV_MODE=true`
- **Provider profile (release):** `PROVIDER_PROFILE=release_safe APP_DEV_MODE=false`
- **Improvement spec:** `docs/superpowers/specs/2026-05-31-end-to-end-improvement-plan-design.md` (all 23 tasks done)
