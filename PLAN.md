# Currency Converter — Development Plan

> **Based on:** DEFINITIONS.md (2026-05-07)
> **Status:** Planning

---

## Overview

Currency converter app for Android (iOS later) under Niduna brand. Privacy-first: zero tracking, zero accounts, zero data collection.

**Reference app:** Currency (currencyapp.com) — clone with privacy-first differentiation

**3-Phase Roadmap:**
- Phase 1: MVP (free + ads, no backend)
- Phase 2: Backend + Subscriptions (~2,000 DAU trigger)
- Phase 3: Crypto charts + Metals + Extensions

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
8. Optional crypto/backend planning after MVP

See `ROADMAP.md` for acceptance criteria and guardrails.

---

## Ad Types & Placement

### Ad Types

| Type | Description | Intrusiveness | Phase 1 Use |
|------|-------------|---------------|-------------|
| **Banner** | 320x50 rectangle, bottom | Low | **Primary ad format (only one in Phase 1)** |
| **Interstitial** | Full-screen between transitions | Medium | Future (Phase 2+) — not in MVP per DEFINITIONS |
| **Native** | Blends with app content | Low | Future consideration |
| **App Open** | Shown when app enters foreground | Medium | Future (if needed for revenue) |

> **DEFINITIONS rule:** Phase 1 = "Banner only (AdMob or similar)". No interstitials, no app open ads.

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
- Scrollable list: 16 fiat currencies
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
│  [1W] [1M] [3M] [6M] [1Y] [2Y]│ ← Date range
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

**Future enhancement:** Crypto/metals require a backend or explicit API-key strategy before implementation.

---

### Navigation Ideas to Explore

- [x] BottomNavigationBar with 4 tabs
- [ ] Modal bottom sheet for currency selection (vs dropdown)
- [ ] Pull-to-refresh on currency list (Convert tab)
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
| 16 fiat currencies | TODO | USD, EUR, GBP, JPY, CAD, AUD, CNY, INR, MXN, BRL, TRY, KRW, SGD, HKD, NZD, CHF |
| Conversion | TODO | Client-side `amount × rate` |
| Historical charts | TODO | Daily rates, up to 2 years |
| Favorite pairs | TODO | Save up to 3 locally (SharedPreferences) |
| Offline mode | TODO | Cache last known rates |
| Dark mode | TODO | Free in 2026 |
| Banner ads | TODO | Bottom banner, safe distance from input |
| Remove Ads IAP | TODO | 1.99 CHF one-time |

### Data Sources

| Source | Use | Key |
|--------|-----|-----|
| Frankfurter v2 | Fiat rates | No API key |

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

- [ ] Slice 0: align `DEFINITIONS.md`, `ROADMAP.md`, and `PLAN.md`
- [ ] Slice 1: finalize Convert UI with demo data and small-screen verification
- [ ] Slice 2: add Frankfurter latest-rates client/repository/cache for Convert
- [ ] Slice 3: implement local favorites and max-3 rule across Convert/Favorites
- [ ] Slice 4: implement fiat historical charts with pair/range cache
- [ ] Slice 5: implement Settings preferences and cache controls
- [ ] Slice 6: integrate banner ads and one-time Remove Ads IAP
- [ ] Slice 7: decide optional crypto/backend strategy after MVP
- [ ] Keep English-only launch text; add DE, FR, IT, ES, PT in Phase 1.x updates
- [ ] Write/update smoke tests as each slice becomes user-visible
- [ ] Build and test APK before release candidate

---

## Phase 2 — Backend + Subscriptions

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

## Phase 3 — Crypto + Metals + Extensions

### Features

| Feature | Price |
|---------|-------|
| Crypto charts (BTC, ETH) | 1-1.50 CHF one-time pack |
| Metals (XAU, XAG) | Included in crypto pack |
| Apple Watch support | 0.99 CHF or included in Remove Ads |
| 10-year charts | Free for all |

### TODO (Phase 3)

- [ ] Add metals API (TBD source)
- [ ] Crypto charts implementation
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

### Crypto API (Deferred)

- CoinGecko Demo API requires a key.
- Do not embed that key in the Phase 1 mobile app.
- Revisit BTC/ETH prices only with backend/proxy or an explicit API-key decision.

### Caching Strategy

> **Note:** Caching is for **offline mode + UX** (instant load), NOT because of API rate limits.
> Frankfurter has no hard quota. At < 500 DAU, caching is optional per DEFINITIONS.

| Data | Cache TTL | Reason |
|------|----------|--------|
| Fiat rates | Until next app open | Offline mode: show last known rates when no network |
| Historical data | Persistent | Avoid re-fetching chart data already loaded |
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
