# Currency Converter

Privacy-first Flutter currency converter for the Honest Fern portfolio.

**Android MVP release** | Android first, iOS later | No account, no first-party analytics, no backend.

## What's in the Android launch scope

- 45 currencies total — 34 fiat + 11 crypto (USD, EUR, GBP, JPY, CHF, SEK, NOK, DKK, PLN, CZK, HUF, RON, CAD, AUD, MXN, BRL, ARS, CLP, COP, INR, SGD, HKD, KRW, THB, PHP, IDR, MYR, TWD, NZD, CNY, TRY, AED, ILS, ZAR + BTC, ETH, SOL, XRP, ADA, DOGE, AVAX, USDT, USDC, BNB, MATIC); source of truth: `lib/src/core/currency/supported_currencies.dart`
- Multi-currency conversion view (type one amount, see all conversions)
- Four-tab shell: Convert, Favorites, Chart, and Settings
- Historical charts (up to 2 years, unlimited free)
- Favorites (3 free; temporary rewarded boost to 6; Favorites Pro up to 16)
- Offline mode (cached rates, no network required)
- Dark mode (free in 2026 — do not charge for this)
- Banner ads plus user-initiated rewarded ads for temporary unlocks
- Three one-time IAPs: Remove Ads (1.99 CHF), Charts Pro (2.99 CHF),
  Favorites Pro (0.99 CHF); no launch subscription

**Not in the Android launch:** metals (XAU/XAG), push notifications,
backend, accounts, subscriptions, or real-time/intraday rates.

**Future backend direction (post-release, not current scope):** OXR Developer
will be the planned hourly-fiat upstream ($12/month or $120/year). The OXR App
ID stays on the Hostinger VPS, where a worker pulls, validates and stores the
rates. A public Honest Fern API under `honestfern.com/currency/` then serves
those stored results to this app and future Honest Fern apps. The mobile app
must never contain the OXR credential and will keep its current providers as
fallbacks. **No CoinGecko: the crypto track was closed on 2026-09-06 — crypto
stays on fawazahmed0 (CC0, daily, direct).**

## Core app docs

| Doc | Purpose |
|-----|---------|
| `DEFINITIONS.md` | Product definition, competitive study, API strategy, pricing decisions, phase roadmap |
| `ROADMAP.md` | Delivery order, screen contracts, API/cache contracts, vertical slices |
| `PLAN.md` | Development plan, navigation structure, file layout, Phase 1 TODO |
| `AGENTS.md` | Agent instructions, skills, verification rules, modularity rules |
| `agent/README.md` | Repo-specific guidance, commands, iOS simulator notes |
| `docs/FEATURE_IDEAS.md` | Ranked post-launch feature backlog from competitive research (v0.2+) |

## UI Guidance Resources For Agents

These resources are already present in the repo and should be consulted for
mobile UI decisions before large layout changes:

- `./.agent-local/skills/mobile/mobile-ui-review.SKILL.md`
- `./.agent-local/skills/mobile/flutter/flutter-small-screen-ui.SKILL.md`
- `./.agent-local/skills/mobile/references/native-platform-ui-notes.md`
- `./.agent-local/skills/mobile/references/store-ui-readiness-checklist.md`

Use them together with `ROADMAP.md` and `AGENTS.md` when deciding interaction
patterns, top-of-screen density, and touch-target/accessibility constraints.

When a future task involves Stitch:

- use the mobile/UI skills first to refine interaction and constraints
- then use `./.agent-local/skills/publish/google-stitch-workflow/SKILL.md`
  to generate or iterate screens with better prompts and clearer acceptance
  criteria

## Development phases

| Phase | Goal | Trigger |
|-------|------|---------|
| **Phase 1 (MVP)** | Free + ads + one-time Remove Ads | Now |
| **Phase 2** | OXR-backed VPS service + subscriptions (rate alerts, hourly refresh, optional crypto API strategy) | ~2,000 DAU |
| **Phase 3** | Crypto charts + metals (XAU/XAG) + extensions | After Phase 2 |

See `DEFINITIONS.md` → Phase Roadmap for full details.

## Data sources

| Source | Use | Auth |
|--------|-----|------|
| Frankfurter v2 (`api.frankfurter.dev`) | Fiat rates | No API key |
| Local cache | Fiat rates, chart data, favorites, settings | SharedPreferences |

## Quick start

```bash
flutter pub get
flutter run
```

## Verification

```bash
./scripts/check.sh
```

If Flutter is not on `PATH`:

```bash
FLUTTER_BIN=/path/to/flutter ./scripts/check.sh
```

## iOS smoke test

```bash
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/run_ios_minimal_smoke.sh
```

## Screenshot capture

```bash
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} SCREEN_OUTPUT_DIR=.tmp/screens/ios \
  ./.devtools/capture_ios_screens.sh
```

## Machine setup on a new Mac

Expected tools:

- Xcode with iOS Simulator
- Android Studio with Android SDK and Emulator
- Flutter SDK
- CocoaPods for iOS plugin builds

Recommended install path:

```bash
brew install --cask flutter
brew install cocoapods
```

Then confirm the toolchain:

```bash
open -a Simulator
xcode-select -p
flutter doctor -v
```

Accept Android licenses when prompted:

```bash
flutter doctor --android-licenses
```

If an older build used a different Flutter SDK and iOS builds fail with stale SDK-path errors, regenerate:

```bash
flutter clean
flutter pub get
```

## Product constraints

- privacy-first: no Honest Fern account, no first-party analytics, no backend;
  AdMob collection/sharing is disclosed and requires UMP/privacy controls
- offline only in Phase 1
- no backend
- no login
- no cloud sync

## Run scripts reference

| Script | What it does |
|--------|-------------|
| `./scripts/check.sh` | analyze + test |
| `./scripts/analyze.sh` | static analysis only |
| `./scripts/test.sh` | unit tests |
| `./scripts/build_apk.sh` | Android release APK |
| `./scripts/build_web.sh` | Flutter web build |
| `./scripts/pub_get.sh` | fetch dependencies |
| `./scripts/clean-deep-files.sh` | deep clean build artifacts |

## Current phase (reviewed 2026-09-10)

Read `RELEASE_CHECKLIST.md` **Resume checkpoint — 2026-09-10** first.
Current version is `0.1.0+2`; the existing internal test and three active
one-time products are recorded there. Real Play Billing is implemented but
needs hardening and device acceptance; B4 AdMob and B8 UMP remain open.
Latest checks: 247 tests, clean analysis, no lockfile drift (2026-09-10).
Next: Billing exceptions/acknowledgement/restore/pricing review and license-tester
verification, then ads/consent and final listing/privacy/assets alignment.
No production release yet; no OXR/VPS service or CoinGecko in this scope.
New binaries need code >= 3; bump version name to 1.0.0 only at the validated RC.
