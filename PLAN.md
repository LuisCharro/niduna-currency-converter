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
│  🇯🇵 JPY   149.50   14950.00│     (34 fiat + 11 crypto)
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
- 1 call to Frankfurter: `GET /v2/latest?from={base}` → all 34 fiat rates
- Total: **1 API call per refresh**
- Cross-rate calculation done client-side: `amount × rate`

**Clarification:** This IS the multi-currency view. User types 100 USD, sees the 40 fiat conversions at once. No need to select "from/to" pairs separately. This matches the Currency app UX.

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

**Phase 1 already includes multi-currency view in Tab 1.** User types one amount, sees all 34 fiat + 11 crypto conversions at once. This is the Currency app UX.

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
| 34 fiat currencies (11 crypto) | DONE | USD, EUR, GBP, JPY, CAD, AUD, CNY, INR, MXN, BRL, TRY, KRW, SGD, HKD, NZD, CHF + BTC/ETH etc. |
| Conversion | DONE | Client-side `amount × rate` |
| Historical charts | DONE | Fiat daily rates, up to 2 years |
| BTC/ETH latest in Convert | DONE | No-key providers, quote-only in first slice |
| BTC/ETH and mixed crypto charts | DONE | Daily charts up to 1 year; `multi_provider_rates_client.dart` handles all pair types |
| Favorite pairs | DONE | Save up to 3 locally (SharedPreferences) |
| Favorites manual reorder | DONE | Always-visible drag handle on each row; order persisted. Replaced the earlier usage-based auto-sort (`FavoriteUsageTracker`/`sortedPairs` removed). |
| Offline mode | DONE | Cache last known rates |
| Dark mode | DONE | Follows system by default with a Settings entry point |
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
| Pull-to-refresh on Favorites & Charts | DONE | RefreshIndicator wrapping tab content |
| Trend arrows (previous day comparison) | DONE | Yesterday rates fetch via Frankfurter historical endpoint |
| Sectioned currency picker (geographic groups) | DONE | Europe/Americas/AsiaPacific/MiddleEastAfrica/Crypto |
| Home widget data push on cached load | DONE | Widget data pushed immediately when cached state loads |
| Android home-screen widget | DONE | Redesigned to 3-pair icon-led widget — warm paper, currency circles, dividers, trend arrows. Favorites-driven with fallback. Runtime-verified on emulator. |
| Starter favorites seeding | DONE | Seeds USD-EUR, USD-GBP, USD-BTC on first run so widget is useful immediately |
| iOS home-screen widget code | DONE (disabled by default) | Target and Swift code wired; embed phase removed on main for iOS 26 sim install stability |
| Calculator expression evaluator tests | DONE | 12 test cases covering arithmetic and edge cases |
| 194 total tests passing | DONE | Current baseline after widget redesign work |

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
| State management | ChangeNotifier (Flutter built-in observer pattern) | Lightweight, no external dependency |
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
- [x] Slice 9: data freshness indicator, dark mode, intraday toast copy fix, subscription v1 copy
- [x] Slice 10: update root docs for the no-key BTC/ETH scope (aligned in commits 764340f + ad8caab)
- [x] Slice 11: add BTC/ETH and mixed fiat/crypto charts up to 1 year
- [x] Write/update smoke tests as each slice becomes user-visible

### Remaining Phase 1 work (priority order)

> **CONSOLIDATED:** See [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) for the authoritative
> release checklist with effort estimates, execution order, and status tracking.
> Per-provider licensing details: [`docs/providers/`](docs/providers/).
>
> **2026-06-01 update:** Backend (Phase 2/3) deferred until post-publish, only resumes if there are users. The code-only execution order lives in [`docs/superpowers/plans/2026-06-01-post-phase-ad-next-steps.md`](docs/superpowers/plans/2026-06-01-post-phase-ad-next-steps.md) — work happens on branch `release-prep`.

- [x] **P1 — Dark mode**: make toggle follow `ThemeMode.system` instead of manual boolean only
- [x] **P2 — Localization Step 1** (system wiring): connect `MaterialApp` to `AppLocalizations.localizationsDelegates` and `AppLocalizations.supportedLocales`; migrate meaningful user-facing labels/messages to localization keys (`AppLocalizations.of(context)`)
- [x] **P3 — Localization Step 2** (language content): add and validate ARB translations for EN, DE, ES, IT, FR across Convert, Charts, Settings, dialogs/sheets, empty/error states, and accessibility labels/tooltips where user-visible
- [x] **P4 — Real AdMob SDK**: replace placeholder banners with live `google_mobile_ads` (DONE — live BannerAd + RewardedAd integrated, placeholder only shows on load failure or test mode; see `ad_banner_widget.dart`, `admob_rewarded_ad_service.dart`, `ad_helper.dart`)
- [x] **P5 — Replace CoinGecko in release_safe crypto history** (DONE — fawazahmed0 per-date CDN snapshots, CC0-1.0, batched 10-concurrent)
- [ ] **P6 — Release keystore signing**: move from debug signing config to proper release keystore → `RELEASE_CHECKLIST.md` B1-B3
- [x] **P7 — Branded app name** ✅ committed `bade57e`
- [ ] **P8 — Privacy policy URL**: required by both stores before submission → `RELEASE_CHECKLIST.md` C1, B5
- [x] **P9 — iOS deployment target update** ✅ committed `bade57e`
- [x] **P10 — Release APK + App Bundle** ✅ verified (needs real keystore for store submission)
- [ ] **P11 — Store listing assets**: screenshots, descriptions, keywords for both stores → `RELEASE_CHECKLIST.md` C2-C11
- [x] **P12 — Long-press context menu** ~~on currency rows~~ — **deferred**: swipe-left already covers Pin/Swap/Hide actions

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
- [x] Add chart tests for crypto/crypto and fiat/crypto formulas

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
- Android Launcher Widgets — implemented on main; see `RELEASE_CHECKLIST.md` and `docs/superpowers/plans/2026-06-13-local-feature-status-harmonization.md`

---

## File Structure

> See [`ARCHITECTURE.md`](ARCHITECTURE.md) for the layered architecture overview
> and data flow diagrams.
>
> See [`AGENTS.md`](AGENTS.md) for the complete import structure,
> modularity rules, and shared widget inventory.
