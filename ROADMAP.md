# Currency Converter Roadmap

This file is the practical guide for sequencing product, design, data, and
Flutter implementation work.

Use it together with:

- `DEFINITIONS.md` for product decisions and phase boundaries
- `PLAN.md` for implementation structure and task tracking
- `AGENTS.md` for agent workflow and verification rules

## Current Reality

The app has all Phase 1 slices implemented (slices 0-9, 11) and a UI redesign
iteration 2 on branch `turbo/ui-redesign`. Feature audit completed 2026-05-22.

- a Flutter app with three visible tabs: `Convert`, `Charts`, `Settings`
  (Favorites code retained but hidden from nav for Phase 2)
- real fiat rates from Frankfurter v2 + BTC/ETH latest from no-key providers
- historical charts: fiat up to 2Y, crypto up to 1Y
- full monetization stubs: banner ad placeholders, Remove Ads, Charts Pro,
  rewarded ad chart-pair unlock, subscription "Coming Soon" card
- dark mode, data freshness indicator, pull-to-refresh, modal currency picker
- branded splash screens + adaptive icons (Android)
- store publishing checklists for Play Store and App Store
- product docs covering privacy, monetization, APIs, and phase boundaries
- repo-local agent docs and skills
- scripts for analysis, tests, and builds

Remaining Phase 1 work: dark mode system-follow, real AdMob SDK, release
signing, privacy policy, store listing assets, branded app names.

## Product Contract First

Before implementation expands, keep `DEFINITIONS.md` as the source of truth for:

- Phase 1 included features
- Phase 1 excluded features
- Phase 1 data sources
- Phase 1 monetization
- privacy promises
- phase triggers for backend, subscriptions, expanded crypto/metals, and exports
- open questions that block implementation

Do not implement a feature just because it appears in a UI idea or generated
design. If it is not allowed by `DEFINITIONS.md`, update the definition first or
defer the feature.

## Phase 1 Screen Contract

Phase 1 has four primary tabs.

## Phase 1 Screen Matrix

| Tab | Primary job | Required content | Required states | Explicitly excluded |
|-----|-------------|------------------|-----------------|---------------------|
| `Convert` | Convert one amount into the supported fiat set plus BTC/ETH quote rows | amount input, base selector, fiat result rows, optional BTC/ETH quote rows, favorite star per row, last updated, local-only/privacy signal, refresh action, banner reserve | fresh, loading refresh, cached, stale/offline, fetch error with cached fallback, empty/no-cache error | transfers, accounts, RUB |
| `Favorites` | Manage up to 3 local pairs | saved pair rows, last known value, delete/edit action, empty state, add/select pair flow | empty, 1-3 saved pairs, max reached, stale value, local storage error | cloud sync, login, unlimited favorites |
| `Charts` | Review fiat and limited crypto history | pair selector, 1W/1M/3M/6M/1Y/2Y ranges, chart, high/low/change, last updated | loading, fresh, cached, stale/offline, no historical data, fetch error with cached fallback | crypto history beyond 1Y, metals, export, multi-pair comparison |
| `Settings` | Configure local behavior and trust surface | default base, decimal precision, theme, refresh-on-open, clear cache, cache status, Remove Ads, privacy/about/version, subscription restore/management entry | normal, cache cleared, restore purchase/loading, IAP unavailable, no network for purchase | accounts, cloud backup |

Use this matrix as the first checklist before generating or editing Stitch
screens. If a screen concept introduces excluded content, reject that part of
the design instead of carrying it into Flutter.

### Convert

Purpose: the main daily-use conversion surface.

Must include:

- Niduna branding
- privacy-first/local-only status
- amount input
- base currency selector
- multi-currency results list
- fiat currencies from the Phase 1 list plus optional BTC/ETH quote rows
- favorite toggle per row
- **data freshness indicator** (last-updated timestamp + `(i)` info icon with ECB once-daily tooltip)
- last updated status
- offline or stale-data indication when relevant
- refresh action
- bottom banner ad area with safe distance from the input

Must not include:

- accounts
- transfers
- aggressive paywall patterns
- RUB
- Phase 2 alert or backend features

### Favorites

Purpose: quick access to saved pairs.

Must include:

- up to 3 favorite pairs in Phase 1
- local-only persistence
- delete/edit affordance
- tap pair to open `Convert` with the same base/quote context
- empty state that stays useful without marketing copy

Must not include:

- cloud sync
- account login
- unlimited favorites unless a later monetization decision allows it

### Charts

Purpose: fiat historical review plus limited BTC/ETH chart support.

Must include:

- pair selector (base + quote, with per-pair lock/unlock state)
- 1W, 1M, 3M, 6M, 1Y, 2Y ranges for fiat pairs
- 1W, 1M, 3M, 6M, 1Y ranges for crypto-involved pairs
- historical line chart
- high, low, and change summary
- loading, cached, stale, and error states
- locked-pair UI with rewarded-ad unlock flow (opt-in, 24h temporary access)
- temp-unlock visual indicators (24h badge, primary-tinted avatar)
- banner ad area at bottom of chart screen (same gating as Convert tab)

Must not include:

- crypto history beyond 1 year
- metals
- chart export
- multi-pair chart comparison

### Settings

Purpose: app configuration and trust surface.

Must include:

- default base currency selector
- decimal precision selector (2/3/4 decimals for fiat Phase 1)
- **dark mode toggle** (follows system by default; free in 2026)
- refresh-on-open preference (smart: only refetch if cache stale >24h)
- clear cache action (clears rates + chart + temp unlocks)
- **data freshness explanation** (ECB once-daily, last update timestamp, up to 24h old)
- **Premium section** with IAP purchase cards:
  - Remove Ads one-time purchase entry
  - Charts Pro one-time purchase entry
  - Subscription (informational "Coming Soon" / "Not available in v1" with pricing hint)
  - Restore Purchases button
- **"Remove ads" CTA row** below banner ad areas (Convert + Charts tabs): subtle text link below/beside the banner
- Dev Sandbox section with entitlement toggles (visible during development)
- privacy policy/about/version
- active provider profile and data-source disclosure

Must not include:

- account settings
- backend account sync
- backend-only subscription features

### Monetization contract (Phase 1)

- Active subscription unlocks all premium app features and hides ads.
- Without subscription, users can still buy one-time unlocks.
- If subscription expires, subscription-only access is removed.
- If subscription expires, one-time unlocks remain active.
- Charts defaults to `USD -> EUR` (with free swap to `EUR -> USD`).
- Charts intraday ranges (`1H`, `6H`, `1D`) are subscription-only.
- Charts "any pair" selection is unlocked by subscription or one-time Charts Pro.
- Pure-free users (no subscription, no Remove Ads, no Charts Pro) can unlock individual chart pairs for 24h by watching a Rewarded Ad.
- Rewarded Ad grants bidirectional temporary access to one pair; does NOT unlock intraday ranges.
- Remove Ads purchase hides ALL ad surfaces AND removes rewarded-ad offer prompts.
- Temporary unlocks persist in SharedPreferences and survive app restarts until expiry.

#### IAP purchase products (Phase 1)

| Product | Type | Price | Stub |
|---------|------|-------|------|
| Remove Ads | One-time | 1.99 CHF | ✅ (simulated 2s purchase) |
| Charts Pro | One-time | 2.99 CHF | ✅ (simulated 2s purchase) |
| Subscription | Recurring | Coming Soon — 1-week free trial planned; store-local yearly price TBD | Informational only |

#### Paywall entry points (Phase 1)

| Entry point | Location | Product | UI type |
|-------------|----------|---------|---------|
| Settings Premium section | Settings tab | Remove Ads / Charts Pro / Subscription | Cards with Buy / Notify Me buttons |
| Locked pair action sheet | Charts picker | Charts Pro | "Unlock all pairs forever" → IapPurchasePlayer |
| Banner "Remove ads" CTA | Convert + Charts tabs | Remove Ads | Subtle text link below banner |

Implementation detail and edge cases live in `.agent/monetization-access-rules.md`.
Rewarded ad implementation plan lives in `.agent/rewarded-chart-unlock-plan.md`.
IAP stub implementation plan lives in `.agent/iap-purchase-plan.md`.

## Data And Cache Contract

Define data behavior before wiring UI states.

### Fiat Latest Rates

Source:

- Frankfurter v2

App behavior:

- fetch latest rates by base currency
- calculate conversions client-side
- cache last successful payload locally
- show cached data immediately on app open when available
- refresh on app open if user setting allows it
- show offline/stale status when network refresh fails

Phase 1 does not need a backend proxy for fiat rates.

### Fiat Historical Rates

Source:

- Frankfurter historical endpoints

App behavior:

- cache by base currency, quote currency, and range
- reuse cached chart data when offline
- clearly distinguish stale chart data from fresh data

### Crypto Data

Phase 1.x includes limited no-key crypto data.

Supported scope:

- BTC and ETH latest rates in Convert
- BTC/ETH daily charts up to 1 year
- mixed fiat/crypto daily charts up to 1 year

Sources:

- release-safe profile: fawazahmed0 for BTC/ETH latest, Coingecko for BTC/ETH historical charts
- dev CoinPaprika profile: CoinPaprika for BTC/ETH latest and historical, fawazahmed0 as latest fallback

Still deferred:

- crypto beyond BTC/ETH
- intraday crypto charts
- crypto history beyond 1 year
- any crypto path that requires embedding an API key

### Provider Profiles

Provider selection must be controlled by a build-time profile, not by a normal
user-facing settings toggle.

- default profile: `release_safe`
- optional dev profile: `dev_coinpaprika`
- release builds must reject non-safe profiles
- Settings should disclose the active profile and current provider order
- dev-only UI may display provider diagnostics, but release UI must not let users
  enable restricted providers

### Local User Data

Source:

- device-local storage

Stores:

- favorites
- settings
- latest fiat cache
- historical chart cache
- IAP/ad-removal state when implemented
- temporary chart-pair unlocks (24h TTL, per canonical pair key)

Phase 1 has no account, no backend, no cloud sync, and no tracking.

## Stitch Before Flutter

Use Stitch after the screen contract is clear.

Recommended order:

1. Generate or refine the canonical `Convert` screen.
2. Generate `Favorites` using the same design system.
3. Generate `Charts` using the same design system.
4. Generate `Settings` using the same design system.
5. Review the four screens as one app system.
6. Create a handoff pack for Flutter.

Stitch should solve visual direction, screen hierarchy, density, and component
language. It should not decide product scope.

Flutter implementation should translate the approved design into native widgets.
Do not try to copy Stitch HTML/CSS one-to-one.

## Flutter Delivery Strategy

Build by vertical slices. Avoid building a large data layer and a large UI layer
separately.

Each slice should include only the data, state, UI, and tests needed for one
user-visible behavior.

### Slice 0: Product And Architecture Baseline

Goal:

- align `DEFINITIONS.md`, `PLAN.md`, and this roadmap
- make Phase 1 screen/API/cache contracts explicit
- confirm dependencies
- keep the existing shell intact

Done when:

- docs agree on Phase 1 scope
- no screen has ambiguous Phase 2 features
- the next Flutter slice has clear acceptance criteria

### Slice 1: Convert With Demo Data

Goal:

- finalize the native Flutter Convert UI based on the approved Stitch direction
- keep demo data isolated
- verify layout on small screens

Done when:

- Convert contains all required Phase 1 visual elements
- widget files remain small
- tests and static analysis pass

### Slice 2: Fiat Latest Rates

Goal:

- add Frankfurter latest-rates client/repository/cache only for Convert
- replace fiat demo values with real data

Done when:

- Convert works online
- Convert works from cache after a successful fetch
- refresh failure leaves usable cached values when available
- tests cover conversion math and repository fallback behavior

## Next Slice Plan: Convert Real Rates

This is the next logical implementation step.

Scope:

- Replace Convert demo values with real Frankfurter latest-rate data.
- Keep the existing four-tab shell and Stitch-derived visual direction.
- Implement only the minimum data/state/cache needed by Convert.
- Do not implement Favorites, Charts, Settings behavior, ads, IAP, backend, or
  crypto in this slice.

### User-Visible Behavior

Convert should:

- show cached values immediately on open when cache exists
- fetch latest fiat rates for the selected base currency
- calculate `amount × rate` client-side
- show 16 Phase 1 fiat currencies, excluding the active base from result rows
- expose a manual refresh action
- show `fresh`, `loading refresh`, `cached`, `stale/offline`, and `no cache`
  states clearly
- keep the banner ad area as a placeholder only

### API Contract

Use Frankfurter v2 directly from the app:

```text
GET https://api.frankfurter.dev/v2/rates?base={BASE}&quotes={QUOTE_CODES}
```

Expected handling:

- `{BASE}` must be one of the Phase 1 fiat codes.
- Response rows are normalized into decimal rates by quote currency.
- If a requested Phase 1 currency is missing from the response, skip that row
  and surface a recoverable data warning in state, not a crash.
- Frankfurter has no `/convert` endpoint; conversion is always local math.

### Cache Contract

Persist only the last successful latest-rates payload per base currency.

Minimum cached fields:

- base currency
- fetched timestamp from the API response when available
- local saved timestamp
- rates map for supported Phase 1 fiat currencies

Failure behavior:

- Network success: update cache and show fresh data.
- Network failure with cache: show cached values and stale/offline status.
- Network failure without cache: show a no-data state with a retry action.
- Invalid/partial payload: do not overwrite the last good cache.

### Suggested File Shape

Keep files small and split early.

Expected additions:

- `lib/src/core/currency/supported_currencies.dart`
- `lib/src/features/convert/data/frankfurter_latest_rates_client.dart`
- `lib/src/features/convert/data/latest_rates_cache.dart`
- `lib/src/features/convert/data/latest_rates_repository.dart`
- `lib/src/features/convert/domain/currency_rate.dart`
- `lib/src/features/convert/domain/convert_quote.dart`
- `lib/src/features/convert/domain/convert_state.dart`
- `lib/src/features/convert/presentation/convert_controller.dart`

Expected UI extraction if needed:

- `lib/src/features/convert/presentation/amount_card.dart`
- `lib/src/features/convert/presentation/rate_row.dart`
- `lib/src/features/convert/presentation/rates_status_bar.dart`

The exact names can change, but avoid one large data class or one large screen
file. `ConvertScreen` should orchestrate widgets, not own networking or cache
logic.

### Dependency Bias

Prefer minimal dependencies for this slice.

Acceptable:

- `http` for network calls
- `shared_preferences` for simple JSON cache

Defer unless clearly needed:

- database packages
- broad state-management frameworks
- dependency-injection frameworks
- chart libraries
- ad/IAP packages

### Test Plan

Add tests before calling this slice done:

- conversion math for amount and rates
- supported currency list contains the 16 Phase 1 fiat codes
- no RUB, BTC, ETH, XAU, or XAG in supported currencies
- repository returns fresh data on successful fetch
- repository falls back to cache on network failure
- repository does not overwrite good cache with invalid data
- Convert widget shows the key states: fresh, cached/offline, no-data retry

Verification:

```bash
./scripts/check.sh
```

For UI review, rebuild or hot restart the iOS simulator after checks pass.

### Done Criteria

This slice is done when:

- Convert no longer depends on hard-coded demo rates for normal operation.
- The app still works offline after one successful fetch.
- The user can distinguish fresh data from cached/offline data.
- The implementation follows `AGENTS.md` file-size and modularity rules.
- `./scripts/check.sh` passes.
- No Phase 2/3 concepts enter the code or UI.

### Slice 3: Favorites

Goal:

- persist up to 3 local favorite pairs
- make row stars in Convert meaningful
- implement Favorites tab around the same local store

Done when:

- adding/removing favorites works from Convert and Favorites
- max-3 rule is enforced
- navigation back to Convert with selected pair/context works

### Slice 4: Charts

Goal:

- implement historical charts
- add range selection and historical cache

Done when:

- chart data loads for supported fiat pairs
- cached chart data is reused offline
- crypto-involved pairs work up to 1 year only

### Slice 5: Settings

Goal:

- implement user preferences that already affect existing slices
- add cache controls

Done when:

- default base, decimals, theme, and refresh-on-open work
- clearing cache has visible effect
- settings do not introduce account/backend concepts

### Slice 6: Ads And Remove Ads

Goal:

- add banner ad integration and one-time Remove Ads purchase

Done when:

- banner placement respects the Convert screen safe-distance rule
- removed-ads state hides ad surfaces
- store/release privacy implications are documented

### Slice 7: No-Key Crypto Extension

Goal:

- ship the constrained no-key BTC/ETH extension without breaking privacy rules
- document the range and provider limits clearly

Done when:

- no API key is embedded in the mobile app
- BTC/ETH latest and chart scope is recorded in `DEFINITIONS.md`
- crypto charts remain limited to 1 year until a new provider decision exists

## Architecture Guardrails

The calorie app required heavy refactoring after too much lived in one class.
Do not repeat that here.

Rules:

- keep screens thin
- keep business logic out of widgets
- keep each widget focused and reusable
- introduce repositories before API clients leak into UI
- introduce providers/state objects only when a slice needs them
- do not create a giant shared controller for all tabs
- do not merge unrelated tab logic into `app.dart`

Recommended direction:

- feature folders own their screen-specific widgets
- shared widgets stay generic
- data contracts live outside UI files
- caches and repositories are tested without rendering UI

## Decision Gates

Use these gates to avoid surprises:

- Product gate: feature exists in `DEFINITIONS.md`
- Screen gate: feature is assigned to one tab in the screen contract
- Data gate: API/cache/error behavior is defined
- Design gate: Stitch or design notes show the accepted visual direction
- Implementation gate: slice has tests/checks passing
- Release gate: ads, IAP, privacy, and store language have been reviewed

If a change fails one of these gates, stop and update the relevant doc before
expanding code.

## Feature Audit (2026-05-22)

All Phase 1 slices (0-9) and the BTC/ETH extension (Slice 11) are **implemented**.
UI redesign iteration 2 is on branch `turbo/ui-redesign` (not yet merged).

### Done

| Feature | Evidence |
|---------|----------|
| 16 fiat currencies + BTC/ETH latest | `supported_currencies.dart`, `multi_provider_latest_rates_repository.dart` |
| Client-side conversion | `amount × rate` in Convert |
| Historical charts (fiat up to 2Y, crypto up to 1Y) | `multi_provider_rates_client.dart` handles all pair types |
| BTC/ETH + mixed fiat/crypto charts | `charts_controller.dart` clamps crypto to 1Y; picker includes BTC/ETH |
| Favorites (max 3, local storage) | `FavoritesStore` wired into `ConvertController` |
| Favorites tab **hidden** from nav | `floating_pill_nav.dart` has 3 tabs: Convert, Chart, Settings |
| Offline mode / cache | Cache per base/range; stale fallback works |
| Dark mode | `AppTheme.dark` + Settings toggle + wired in `app.dart` |
| Banner ad placeholders | `AdBannerPlaceholder` in Convert, Charts, Chart Picker |
| Remove Ads IAP stub | `PurchaseServiceStub`, `IapPurchasePlayer`, 1.99 CHF |
| Charts Pro IAP stub | Same infrastructure, 2.99 CHF |
| Subscription card | "Not available in v1 · 1 week free trial planned later" + "Soon" badge |
| Rewarded ad (chart pair unlock) | `LockedPairActionSheet` → `RewardedAdPlayer` → 24h unlock |
| Data freshness indicator | `(i)` icon in `amount_status_bar.dart` → `DailyRatesInfoSheet` |
| Intraday toast (fixed copy) | "Intraday ranges coming soon — requires Premium Subscription" |
| Pull-to-refresh on Convert | `RefreshIndicator` wrapping rates list |
| Modal bottom sheet for currency picker | `CurrencyPickerSheet` via `showModalBottomSheet` |
| Settings: base currency, decimals, refresh-on-open, clear cache | All wired and functional |
| Provider profiles (release_safe / dev_coinpaprika) | Build-time env var; release guard throws on non-safe profile |
| Branded splash screens | Native Android + iOS launch screens |
| Android adaptive icons | Foreground seal + warm paper background layer |
| Store publishing checklists | `.plan/PLAY_STORE_PUBLISH_CHECKLIST.md`, `.plan/APP_STORE_PUBLISH_CHECKLIST.md` |

### Pending (within Phase 1 scope)

> **CONSOLIDATED:** All remaining release tasks are tracked in [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md).
> That file is the single source of truth for what's left before Play Store submission.
> Per-provider details are in [`docs/providers/`](docs/providers/).

| Item | Status | Notes |
|------|--------|-------|
| Slice 10: update root docs for BTC/ETH scope | **DONE** | Aligned in commits 764340f + ad8caab |
| Dark mode follows system default | **DONE** | App theme now follows platform brightness while preserving settings entry point |
| i18n Step 1 — system wiring | **DONE** | MaterialApp wired to AppLocalizations delegates/locales |
| i18n Step 2 — ARB translations | **DONE** | DE, ES, IT, FR locale files and generated localizations shipped |
| Real AdMob SDK (replace placeholders) | **DONE** | Live BannerAd + RewardedAd via google_mobile_ads |
| Replace CoinGecko in release_safe crypto history | **DONE** | fawazahmed0 CC0 date-file client; see `RELEASE_CHECKLIST.md` |
| Keystore signing for release | **PENDING** | See `RELEASE_CHECKLIST.md` → B1-B3 |
| Privacy policy URL | **PENDING** | See `RELEASE_CHECKLIST.md` → C1, B5 |
| Branded app name | **DONE** | Committed bade57e |
| iOS deployment target update | **DONE** | Updated to 15.0 (bade57e) |
| Store listing assets (screenshots, description) | **PENDING** | See `RELEASE_CHECKLIST.md` → C2-C11 |
| Release AAB build validation | **PENDING** | See `RELEASE_CHECKLIST.md` → B6 |
| Long-press context menu on currency rows | **DEFERRED** | Low priority polish |

### Next Best Step: Execute `RELEASE_CHECKLIST.md`

All code features are complete. The path to store is operational:
keystore → real AdMob IDs → privacy policy → screenshots → metadata → submit.

See [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md) for the full ordered checklist with effort estimates.
