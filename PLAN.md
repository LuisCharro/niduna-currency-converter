# Currency Converter — Development Plan

> **Based on:** DEFINITIONS.md (2026-05-22)
> **Status:** Phase 1 implementation nearly complete; store release blockers remain

---

## Overview

Currency converter app for Android (iOS later) under Niduna brand. Privacy-first: zero tracking, zero accounts, zero data collection.

**Reference app:** Currency (currencyapp.com) — clone with privacy-first differentiation

**Roadmap:**
- Phase 1: MVP (free + ads, no backend)
- Phase 1.x: No-key BTC/ETH extension
- Phase 2: Backend + Subscriptions (~2,000 DAU trigger)
- Phase 3: Metals + Extended Crypto + Extensions

## Planning Sources

Use the docs in this order:

1. `DEFINITIONS.md` — product contract and phase boundaries
2. `ROADMAP.md` — delivery order, screen contracts, API/cache contracts, and gates
3. `PLAN.md` — current implementation plan and task tracking
4. `AGENTS.md` — agent workflow, skills, and verification rules

Rule: if a feature appears in this plan but conflicts with `DEFINITIONS.md`,
`DEFINITIONS.md` wins.

## Delivery Strategy

Implement Phase 1 through vertical slices.

Do not build all data clients first and all screens later. Each slice should
ship one user-visible behavior with its minimal model/data/state/UI/tests.

Slice order:

1. Product and architecture baseline
2. Convert with demo data
3. Fiat latest rates
4. Favorites
5. Fiat charts
6. Settings
7. Ads and Remove Ads
8. No-key BTC/ETH extension
9. Optional backend planning after MVP

See `ROADMAP.md` for acceptance criteria and guardrails.

## Provider Profile Plan

- Add a centralized build-time provider config under `lib/src/core/rates/`
- Default to `PROVIDER_PROFILE=release_safe`
- Support `PROVIDER_PROFILE=dev_coinpaprika` for local verification only
- Support `APP_DEV_MODE=true` in local emulator/test scripts so the hidden dev UI is visible by default there
- Release-safe profile rules:
  - fiat latest + charts: Frankfurter
  - crypto latest: fawazahmed0
  - crypto charts: Coingecko (no API key)
- Dev profile rules:
  - crypto latest: CoinPaprika primary, fawazahmed0 fallback
  - crypto charts: CoinPaprika historical ticks
- Settings should show the active profile and provider order
- The developer surface should stay hidden in normal builds and be unlockable from the version row
- Release builds must fail fast if a non-safe profile is selected

---

## Ad Types & Placement

### Ad Types

| Type | Description | Intrusiveness | Phase 1 Use |
|------|-------------|---------------|-------------|
| **Banner** | 320x50 rectangle, bottom | Low | **Primary ad format (only one in Phase 1)** |
| **Interstitial** | Full-screen between transitions | Medium | Future (Phase 2+) — not in MVP per DEFINITIONS |
| **Rewarded** | User opt-in full-screen ad for temporary reward | Medium | Phase 1.x optional experiment (chart pair temporary unlock for pure-free users) |
| **Native** | Blends with app content | Low | Future consideration |
| **App Open** | Shown when app enters foreground | Medium | Future (if needed for revenue) |

> **DEFINITIONS rule:** Core Phase 1 remains banner-first. Optional Phase 1.x can add opt-in Rewarded Ad only for temporary chart-pair unlock, with strict entitlement rules.

### Placement Decision

| Placement | Pros | Cons | Recommendation |
|-----------|------|------|----------------|
| **Bottom banner** | Thumb-friendly, non-intrusive | May overlap with content | **Use for Phase 1** |
| Top banner | Visible immediately | Accidental taps while scrolling | Avoid |
| Between currency list items | Natural flow | Breaks list continuity | Native format only |

### User Feedback (Currency app)
> "the advertisement banner at the bottom is way too close to the number '0'. Several times now I ended up being taken to an app which is supposed to tell me 'who I'll marry?!' while I was trying to type three zeroes"

**Action:** Keep banner at safe distance from input area. Consider larger padding between input and ad.

---

## Navigation Structure

> **Status:** Draft — proposal below, subject to change based on user feedback

### Tab Breakdown

#### Tab 1: Convert (Home) — Primary Screen

**Purpose:** Main conversion interface — multi-currency view (like Currency app)

**Layout:**
```
┌─────────────────────────────┐
│  [Amount Input Field]        │  ← User types amount
│  USD ▼                      │  ← Base currency selector
├─────────────────────────────┤
│  🇪🇺 EUR   0.9132      91.32│
│  🇬🇧 GBP   0.7945      79.45│  ← Scrollable list
│  🇯🇵 JPY   149.50   14950.00│     (16 fiat)
│  🇨🇦 CAD   1.36      136.00 │
│  ...                        │
│                        ⭐   │  ← Tap star to favorite
└─────────────────────────────┘
[        BOTTOM BANNER        ]  ← Safe distance from input
```

**Features:**
- Amount input (numeric keypad)
- Base currency selector (dropdown or tap base row)
- Scrollable list: fiat currencies plus optional BTC/ETH quote rows
- Each row shows: flag + currency code + converted amount
- Star button on each row to add pair to favorites
- Pull-to-refresh for rates
- "Last updated: [date]" footer

**API Calls (optimized):**
- 1 call to Frankfurter: `GET /v2/latest?from={base}` → all 16 fiat rates
- Total: **1 API call per refresh**
- Cross-rate calculation done client-side: `amount × rate`

**Clarification:** This IS the multi-currency view. User types 100 USD, sees the 16 fiat conversions at once. No need to select "from/to" pairs separately. This matches the Currency app UX.

---

#### Tab 2: Favorites

**Purpose:** Quick access to saved currency pairs

**Layout:**
```
┌─────────────────────────────┐
│  Favorites                  │
├─────────────────────────────┤
│  USD → EUR             ⋮   │  ← Swipe to delete
│  Last: 91.32                │
│  CHF → JPY             ⋮   │
│  Last: 187.25               │
│  EUR → GBP             ⋮   │
│  Last: 0.85                 │
├─────────────────────────────┤
│  + Add favorite             │
└─────────────────────────────┘
```

**Features:**
- List of favorited pairs (max 3 in Phase 1)
- Tap to navigate to Convert tab with that pair
- Swipe to delete
- "Add favorite" → opens pair selector

---

#### Tab 3: Charts

**Purpose:** Historical exchange rate visualization

**Layout:**
```
┌─────────────────────────────┐
│  Charts                     │
├─────────────────────────────┤
│  USD → EUR ▼                │  ← Pair selector
├─────────────────────────────┤
│  ┌───────────────────────┐  │
│  │     📈 CHART          │  │
│  │   (fl_chart)          │  │
│  └───────────────────────┘  │
├─────────────────────────────┤
│  [1W] [1M] [3M] [6M] [1Y] [2Y]│ ← Date range (2Y fiat-only)
├─────────────────────────────┤
│  High: 0.95  Low: 0.88      │
│  Change: +2.3%             │
└─────────────────────────────┘
```

**Features:**
- Pair selector (modal or dropdown)
- Interactive line chart (fl_chart)
- Date range buttons
- High/Low/Change summary
- Tap point for exact date value

---

#### Tab 4: Settings

**Purpose:** App configuration and IAP

**Layout:**
```
┌─────────────────────────────┐
│  Settings                   │
├─────────────────────────────┤
│  Appearance                 │
│  ├── Dark Mode        [○─] │
│  └── Base Currency    USD ▼│
├─────────────────────────────┤
│  Conversion                 │
│  ├── Decimal Places   2 ▼  │
│  └── Refresh on open  [─○] │  ← Refresh rates when app opens (not hourly)
├─────────────────────────────┤
│  Remove Ads                 │
│  ┌───────────────────────┐  │
│  │  Remove Ads — 1.99 CHF│  │  ← IAP
│  └───────────────────────┘  │
├─────────────────────────────┤
│  Data                       │
│  ├── Clear Cache       [ ] │
│  └── Last updated  Today   │
├─────────────────────────────┤
│  About                      │
│  ├── Privacy Policy    [→] │
│  ├── Terms of Service  [→] │
│  └── Version         1.0.0 │
└─────────────────────────────┘
```

**Features:**
- Dark mode toggle
- Default base currency selector
- Decimal precision (2, 3, 4)
- Refresh on open toggle (refreshes rates when app launches; not hourly — Frankfurter is daily only)
- Remove Ads IAP button (1.99 CHF one-time)
- Clear cache option
- Last updated timestamp
- Privacy/Terms links
- App version

> **Note:** Chart export (PNG/JPG) and data export are Phase 2 features (0.99 CHF one-time per DEFINITIONS).

---

### Multi-Currency View (Clarification)

**Phase 1 already includes multi-currency view in Tab 1.** User types one amount, sees all 16 fiat conversions at once. This is the Currency app UX.

**API cost:** Only 1 call per refresh. Frankfurter returns all rates in one response, so adding more fiat currencies later costs nothing extra.

**Phase 2 enhancement:** More frequent refresh (hourly via backend), expand to all 200 Frankfurter currencies.

**Current extension:** BTC/ETH latest rates and daily charts up to 1 year can use no-key providers.

**Future enhancement:** broader crypto coverage, intraday crypto, or more than 1 year of crypto history require a new provider or backend strategy.

---

### Navigation Ideas to Explore

- [x] BottomNavigationBar with 4 tabs
- [x] Modal bottom sheet for currency selection (vs dropdown) — `CurrencyPickerSheet`
- [x] Pull-to-refresh on currency list (Convert tab) — `RefreshIndicator`
- [ ] Context menu (long press) for quick actions (add to favorites, view chart)
- [ ] Swipe on Favorites to delete
- [ ] Rate alerts: deferred to Phase 2 unless `DEFINITIONS.md` is updated after MVP validation

---

## Phase 1 — MVP

### Goal
Ship fast, validate conversion funnel. Target: 500+ DAU within 3 months, 3-5% Remove Ads conversion.

### Currency Converter App Structure

```
lib/
├── main.dart                    # Entry point
├── src/
│   ├── app.dart                 # MaterialApp configuration
│   ├── core/
│   │   ├── theme/               # App theme (colors, typography)
│   │   ├── constants/           # Currency list, API endpoints
│   │   └── utils/               # Formatters, extensions
│   ├── data/
│   │   ├── sources/
│   │   │   └── frankfurter_api.dart      # Frankfurter v2 client
│   │   ├── models/
│   │   │   ├── currency.dart
│   │   │   ├── exchange_rate.dart
│   │   │   └── historical_data.dart
│   │   └── repositories/
│   │       └── rates_repository.dart
│   ├── domain/
│   │   └── services/
│   │       └── conversion_service.dart
│   ├── presentation/
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── amount_card.dart
│   │   │       ├── currency_pair_card.dart
│   │   │       ├── result_card.dart
│   │   │       ├── preset_buttons.dart
│   │   │       └── swap_button.dart
│   │   ├── chart/
│   │   │   └── chart_screen.dart
│   │   ├── favorites/
│   │   │   └── favorites_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   └── services/
│       ├── local_storage.dart
│       └── cache_service.dart
```

### Features

| Feature | Status | Notes |
|---------|--------|-------|
| 16 fiat currencies | DONE | USD, EUR, GBP, JPY, CAD, AUD, CNY, INR, MXN, BRL, TRY, KRW, SGD, HKD, NZD, CHF |
| Conversion | DONE | Client-side `amount × rate` |
| Historical charts | DONE | Fiat daily rates, up to 2 years |
| BTC/ETH latest in Convert | DONE | No-key providers, quote-only in first slice |
| BTC/ETH and mixed crypto charts | DONE | Daily charts up to 1 year; `multi_provider_rates_client.dart` handles all pair types |
| Favorite pairs | DONE | Save up to 3 locally (SharedPreferences) |
| Offline mode | DONE | Cache last known rates |
| Dark mode | DONE | `AppTheme.dark` + Settings toggle; caveat: manual toggle only, does NOT follow system |
| Banner ads | DONE (placeholders) | `AdBannerPlaceholder` in Convert, Charts, Chart Picker; no live AdMob SDK yet |
| Remove Ads IAP | DONE | 1.99 CHF one-time (stub) |
| Charts Pro IAP | DONE | Unlock all pairs forever (stub) |
| Subscription UI | DONE | "Not available in v1 · 1 week free trial planned later" + "Soon" badge |
| Rewarded Ad (chart pair unlock) | DONE | 24h temporary unlock for pure-free users |
| Data freshness indicator | DONE | `(i)` icon → `DailyRatesInfoSheet` explains ECB once-daily |
| Pull-to-refresh on Convert | DONE | `RefreshIndicator` wrapping rates list |
| Modal currency picker | DONE | `CurrencyPickerSheet` via `showModalBottomSheet` |
| Provider profiles | DONE | Build-time `PROVIDER_PROFILE` env var; release guard |
| Branded splash screens | DONE | Native Android + iOS launch screens |
| Android adaptive icons | DONE | Foreground seal + warm paper background layer |
| Store publishing checklists | DONE | Play Store + App Store checklists in `.plan/` |

### Data Sources

| Source | Use | Key |
|--------|-----|-----|
| Frankfurter v2 | Fiat rates | No API key |
| Coingecko | BTC/ETH historical (release_safe profile) | No API key |
| fawazahmed0 | BTC/ETH latest fallback | No API key |
| CoinPaprika | BTC/ETH latest + historical (dev profile only) | No API key |

### Technical Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| Framework | Flutter | Cross-platform (Android first) |
| State management | Riverpod | Flutter-recommended state management
| Local storage | SharedPreferences | Simple key-value for favorites + cache |
| HTTP client | dio | Better caching than http package |
| Charts | fl_chart | Free, well-maintained |
| Ads | Google Mobile Ads Flutter plugin | Verify current official package before Slice 7 integration |

### TODO List (Phase 1, Vertical Slices)

- [x] Slice 0: align `DEFINITIONS.md`, `ROADMAP.md`, and `PLAN.md`
- [x] Slice 1: finalize Convert UI with demo data and small-screen verification
- [x] Slice 2: add Frankfurter latest-rates client/repository/cache for Convert
- [x] Slice 3: implement local favorites and max-3 rule across Convert/Favorites
- [x] Slice 4: implement fiat historical charts with pair/range cache
- [x] Slice 5: implement Settings preferences, cache controls, and chart banner ad
- [x] Slice 6: integrate monetization entitlements and ad runtime (banner ads, Remove Ads, Charts Pro, Subscription, optional rewarded unlock)
- [x] Slice 8: IAP paywall — PurchaseService stub, IapPurchasePlayer, Settings Premium section, Remove Ads + Charts Pro + Subscription (Coming Soon) buttons, banner CTA, intraday "coming soon" toast
- [x] Slice 9: hide Favorites tab, data freshness indicator, dark mode, intraday toast copy fix, subscription v1 copy
- [x] Slice 10: update root docs for the no-key BTC/ETH scope (aligned in commits 764340f + ad8caab)
- [x] Slice 11: add BTC/ETH and mixed fiat/crypto charts up to 1 year
- [x] Write/update smoke tests as each slice becomes user-visible

### Remaining Phase 1 work (priority order)

- [x] **P1 — Dark mode**: make toggle follow `ThemeMode.system` instead of manual boolean only
- [x] **P2 — Localization Step 1** (system wiring): connect `MaterialApp` to `AppLocalizations.localizationsDelegates` and `AppLocalizations.supportedLocales`; migrate meaningful user-facing labels/messages to localization keys (`AppLocalizations.of(context)`)
- [x] **P3 — Localization Step 2** (language content): add and validate ARB translations for EN, DE, ES, IT, FR across Convert, Charts, Settings, dialogs/sheets, empty/error states, and accessibility labels/tooltips where user-visible
- [x] **P4 — Real AdMob SDK**: replace placeholder banners with live `google_mobile_ads` (DONE — live BannerAd + RewardedAd integrated, placeholder only shows on load failure or test mode; see `ad_banner_widget.dart`, `admob_rewarded_ad_service.dart`, `ad_helper.dart`)
- [x] **P5 — Replace CoinGecko in release_safe crypto history** (DONE — fawazahmed0 per-date CDN snapshots, CC0-1.0, batched 10-concurrent)

#### P5 Detailed Specification

**Status: NEXT ACTIONABLE ITEM (P4 is done)**

##### Context: Provider profile split

Build-time `PROVIDER_PROFILE` env var (compiled via `--dart-define`, not user-toggleable):

| Profile | Used by | Crypto Latest | Crypto History |
|---|---|---|---|
| `dev_coinpaprika` | Emulator/debug builds (`.devtools/*.sh`) | CoinPaprika → fawazahmed0 fallback | **CoinPaprika** |
| `release_safe` | Release APK/App Bundle, Firebase hosting (`scripts/build_*.sh`) | **fawazahmed0 only** | **CoinGecko** ← replace this |

Emulator builds already use CoinPaprika for crypto charts and work well. CoinPaprika cannot ship in production (commercial license restriction). Release builds use CoinGecko — which is the replacement target.

##### What CoinGecko does in release_safe

Single endpoint: `GET https://api.coingecko.com/api/v3/coins/{id}/market_chart?vs_currency=usd&days={N}` for `bitcoin`/`ethereum`, up to ~365 days. No API key, no fallback. Persistent cache is the only safety net.

##### Why replace (3 risks)

1. **Variable rate limit**: 5-15/min public tier (undocumented, fluctuates)
2. **License ambiguity**: "Non-commercial use only" + attribution required; app with AdMob+IAP may qualify as commercial ($29-129/mo paid plan)
3. **Precedent**: CoinCap was free → deprecated → died; same pattern

##### Recommended fix: expand fawazahmed0 for historical data

fawazahmed0 already serves release_safe crypto **latest rates** with ideal properties:
- License: **CC0-1.0** (public domain)
- **No rate limit** (jsdelivr CDN static files)
- Already integrated and battle-tested
- Has Cloudflare Pages mirror as built-in fallback

Challenge: no native range endpoint. New client fetches daily snapshot JSON files and composes time series:

```
https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/{date}/usd.json
```

Response contains `usd.btc` and `usd.eth` per date.

##### Implementation (~5 files)

1. Create `fawazahmed_crypto_usd_history_client.dart` implementing `CryptoUsdHistoryClient`
2. Add `CryptoHistoryProvider.fawazahmed0` enum in `provider_config.dart`; change release_safe default from `coingecko`
3. Add factory case in `provider_factory.dart`
4. (Optional) Demote CoinGecko client to dev-only
5. Update `PROVIDER_LIMITS.md` + publish checklists

Same clean-swap pattern used when CoinGecko replaced dead CoinCap. Zero changes to UI/charts/controller/cache layers.
- [ ] **P6 — Release keystore signing**: move from debug signing config to proper release keystore
- [ ] **P7 — Branded app name**: set `android:label` on Android + align `CFBundleName` on iOS
  - Android: change `android/app/src/main/AndroidManifest.xml` `android:label` from `"currency_converter"` → `"Currency Converter"`; create `res/values/strings.xml` with `@string/app_name`
  - iOS: change `ios/Runner/Info.plist` `CFBundleName` from `"currency_converter"` → `"Currency Converter"` (`CFBundleDisplayName` already correct)
  - Leave `pubspec.yaml` `name` as-is (internal Dart package name)
- [ ] **P8 — Privacy policy URL**: required by both stores before submission
- [ ] **P9 — iOS deployment target update**: bump from 13.0 → 15.0 in 3 places
  - `ios/Runner.xcodeproj/project.pbxproj`: change all 3 `IPHONEOS_DEPLOYMENT_TARGET = 13.0` → `15.0` (Debug/Release/Profile)
  - `ios/Podfile`: uncomment and set `platform :ios, '15.0'`
  - Run `flutter pub get` then verify with `flutter build ios --no-codesign`
- [ ] **P10 — Build and test APK / App Bundle**: formal RC build validating all above together
- [ ] **P11 — Store listing assets**: screenshots, descriptions, keywords for both stores (do after app is finalized)
- [x] **P12 — Long-press context menu** ~~on currency rows~~ — **deferred**: swipe-left already covers Pin/Swap/Hide actions; only new action would be "View Chart" which is low-priority vs store blockers

---

## UI Redesign — "Professional Polish" Cycle

> **Plan file:** `.agent/ui-redesign-plan.md`
> **Status:** Superseded by Niduna hybrid polish pass
> **Trigger:** Visual quality gap vs competitor (Currency app / miniapatti)
> **Reference screenshots:** `/Users/luis/Downloads/CurrencyApp/` (7 PNGs)

### Current Direction

Use a **Niduna hybrid** direction for UI work:

- keep the warm paper background, forest green accent, Manrope/Fraunces type, and privacy-first personality from `DESIGN.md`
- adopt the competitor's discipline: fewer boxes, thinner dividers, stronger value pills, cleaner chart hierarchy, and larger touch targets
- do not copy the old pure-white/iOS-blue recommendations from `.agent/ui-redesign-plan.md`
- treat older TODOs in this section as historical context when the current app already has the capability

### Phases

| Phase | Name | Goal | Status |
|-------|------|------|--------|
| 1 | Foundation | Theme/nav/ad polish around Niduna tokens | DONE (iter 2 on `turbo/ui-redesign`) |
| 2 | Convert Screen | Reduce top weight, cleaner amount panel, sharper rows | DONE (iter 2 on `turbo/ui-redesign`) |
| 3 | Chart Screen | Stronger hero header, fuller chart, cleaner controls | DONE (iter 2 on `turbo/ui-redesign`) |
| 4 | Settings Cleanup | Controller extraction is done; visual density cleanup | DONE (controller extraction), PARTIAL (visual density) |
| 5 | Icons & Details | Regenerate blurry icons only if needed after screenshot review | DONE (app icons, splash, adaptive icons) |
| 6 | Polish Cycle | Screenshot comparison + iterative refinement | TODO |

### Key Architecture Rule for Phase 4

**Views must not contain app logic.** All interaction logic (navigation, dialogs, persistence writes, snackbars) lives in `SettingsController`. Views receive callbacks only. This matches the existing pattern used by `ConvertController` and `ChartsController`.

See `.agent/ui-redesign-plan.md` for full spec per phase including:
- Competitor analysis with side-by-side comparison table
- Before/after wireframes for each screen
- Exact token changes (colors, typography, spacing)
- File-by-file extraction plan for settings cleanup
- Controller API specification
- MiniMax icon generation queue

---

## Phase 2 — Backend + Subscriptions

Note: Phase 1 can include store subscription as a premium unlock bundle (no backend required).
Phase 2 adds backend-dependent subscription value (alerts, hourly refresh, server features).

### Trigger
~2,000 DAU or user demand for rate alerts.

### Backend Stack

| Component | Technology |
|-----------|------------|
| API | ASP.NET Core Minimal API |
| Database | PostgreSQL |
| Host | Existing Hostinger VPS |
| Push notifications | Firebase Cloud Messaging (free tier: 2M/month) |
| Rate API | ExchangeRate-API Pro ($10/month) |

### Additional Cost
~$10/month (ExchangeRate-API Pro)

### Features

| Feature | Price |
|---------|-------|
| Rate alerts (push) | 12 CHF/año |
| Hourly refresh | Included in Basic tier |
| Optional BTC/ETH prices | Requires backend/proxy or documented API-key decision |
| Multi-pair chart comparison | Phase 2 feature |
| Chart export (PNG/JPG) | 0.99 CHF one-time |
| Save > 3 favorite pairs | 0.50-0.99 CHF |

### TODO (Phase 2)

- [ ] Set up ASP.NET Core Minimal API project
- [ ] Configure PostgreSQL database
- [ ] Implement user device registration (FCM tokens)
- [ ] Implement rate alert push notifications
- [ ] Add hourly data refresh job
- [ ] Implement subscription management (Google Play + App Store)
- [ ] Add multi-pair chart comparison
- [ ] Add chart export feature
- [ ] Performance testing with 2,000+ DAU

---

## Phase 1.x — No-Key BTC/ETH Extension

### Features

| Feature | Scope |
|---------|-------|
| BTC/ETH latest in Convert | No-key, daily refresh, quote-only |
| BTC/ETH charts | Daily, up to 1 year |
| Mixed fiat/crypto charts | Daily, up to 1 year |
| Fiat charts | Unchanged, up to 2 years |

### TODO (Phase 1.x)

- [x] Add BTC/ETH latest with no-key providers
- [x] Add BTC/ETH and mixed fiat/crypto chart routing
- [x] Disable `2Y` for crypto-involved pairs
- [ ] Add chart tests for crypto/crypto and fiat/crypto formulas

---

## Phase 3 — Metals + Extended Crypto + Extensions

### Features

| Feature | Price |
|---------|-------|
| Extended crypto pack (> BTC/ETH, intraday, or > 1Y) | 1-1.50 CHF one-time pack or add-on |
| Metals (XAU, XAG) | Included in crypto pack |
| Apple Watch support | 0.99 CHF or included in Remove Ads |
| 10-year charts | Free for all |

### TODO (Phase 3)

- [ ] Add metals API (TBD source)
- [ ] Extended crypto implementation
- [ ] Apple Watch app
- [ ] Multi-pair chart with metals overlay

---

## Technical Notes

### Frankfurter API

- **No `/convert` endpoint** — use `/v2/latest?from={base}`
- **No API key required**
- **1-call trick:** `GET /v2/latest?from=USD` returns ALL rates against USD in one response
- **Total Phase 1 calls per refresh:** 1 Frankfurter call
- Self-host at 10,000+ DAU via Docker (`lineofflight/frankfurter`)

### Crypto API

- Current BTC/ETH support uses no-key providers.
- Do not embed CoinGecko or similar API keys in the mobile app.
- Revisit broader crypto coverage only with backend/proxy or an explicit public-key decision.

### Caching Strategy

> **Note:** Caching is for **offline mode + UX** (instant load), NOT because of API rate limits.
> Frankfurter has no hard quota. At < 500 DAU, caching is optional per DEFINITIONS.

| Data | Cache TTL | Reason |
|------|----------|--------|
| Fiat rates | Until next app open | Offline mode: show last known rates when no network |
| Crypto latest USD source | Daily | Avoid repeat provider calls within the day |
| Historical data | Persistent | Avoid re-fetching chart data already loaded |
| Crypto historical USD source | Persistent | Reuse source series across BTC/ETH and mixed chart pairs |
| User favorites | Persistent | SharedPreferences, never expires |

---

## Out of Scope (All Phases)

- RUB (Russian Ruble) — not supported by Frankfurter (ECB suspended 2022-03-01)
- Intraday/hourly refresh — Frankfurter provides daily rates only
- Android Launcher Widgets — consider in future

---

## File Structure

```
currency-converter/
├── lib/
│   ├── main.dart
│   └── src/
│       ├── app.dart
│       ├── core/
│       ├── data/
│       ├── domain/
│       ├── presentation/
│       └── services/
├── integration_test/
├── test_driver/
├── scripts/
├── .devtools/
└── pubspec.yaml
```
