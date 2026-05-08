# Currency Converter

Privacy-first Flutter currency converter for the Niduna portfolio.

**Phase 1 — MVP** | Android first, iOS later | No account, no tracking, no backend.

## What's in Phase 1

- 16 fiat currencies (USD, EUR, GBP, JPY, CAD, AUD, CNY, INR, MXN, BRL, TRY, KRW, SGD, HKD, NZD, CHF)
- BTC + ETH live prices via CoinGecko Demo API
- Multi-currency conversion view (type one amount, see all conversions)
- Historical charts (up to 2 years, unlimited free)
- Favorites (save up to 3 currency pairs locally)
- Offline mode (cached rates, no network required)
- Dark mode (free in 2026 — do not charge for this)
- Banner ads (bottom, safe distance from input)
- Remove Ads IAP (1.99 CHF one-time)

**Not in Phase 1:** crypto charts, metals (XAU/XAG), push notifications, backend, accounts.

## Core app docs

| Doc | Purpose |
|-----|---------|
| `DEFINITIONS.md` | Product definition, competitive study, API strategy, pricing decisions, phase roadmap |
| `ROADMAP.md` | Delivery order, screen contracts, API/cache contracts, vertical slices |
| `PLAN.md` | Development plan, navigation structure, file layout, Phase 1 TODO |
| `AGENTS.md` | Agent instructions, skills, verification rules, modularity rules |
| `agent/README.md` | Repo-specific guidance, commands, iOS simulator notes |

## Development phases

| Phase | Goal | Trigger |
|-------|------|---------|
| **Phase 1 (MVP)** | Free + ads + one-time Remove Ads | Now |
| **Phase 2** | Backend + subscriptions (rate alerts, hourly refresh) | ~2,000 DAU |
| **Phase 3** | Crypto charts + metals (XAU/XAG) + extensions | After Phase 2 |

See `DEFINITIONS.md` → Phase Roadmap for full details.

## Data sources

| Source | Use | Auth |
|--------|-----|------|
| Frankfurter v2 (`api.frankfurter.dev`) | Fiat rates | No API key |
| CoinGecko Demo API | BTC + ETH prices | Free API key required |
| Local cache | Fiat + crypto | SharedPreferences, 24h crypto TTL |

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

- privacy-first: zero tracking, zero accounts, zero data collection
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
| `./scripts/build_apk.sh` | Android debug APK |
| `./scripts/build_web.sh` | Flutter web build |
| `./scripts/pub_get.sh` | fetch dependencies |
| `./scripts/clean-deep-files.sh` | deep clean build artifacts |

## Current phase

- Screen-by-screen implementation
- Stub screens exist (Convert, Favorites, Charts, Settings)
- API client integration pending (Frankfurter + CoinGecko)
- AdMob integration pending
- IAP integration pending
