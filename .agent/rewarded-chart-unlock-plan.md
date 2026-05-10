# Rewarded Chart Unlock Plan (Reviewed)

> Status: approved for implementation
> Date: 2026-05-10
> Scope: Charts pair unlock frame + docs + safe architecture (no real ad SDK yet)

## Goals

- Add a visible close button (`X`) to the chart currency picker sheet.
- Keep swap animation as rotation only on pair swap.
- Keep range-change animation as fade/slide (no rotation).
- Add a Rewarded Ad frame for pure-free users to temporarily unlock chart pairs.
- Keep all entitlement and reward logic outside views.

## Product Rules

- Free default chart pair remains `USD <-> EUR`.
- Subscription unlocks all chart pairs, intraday ranges (`1H`, `6H`, `1D`), and removes ads.
- Charts Pro unlocks all chart pairs, but does not remove ads.
- Remove Ads removes all ad surfaces, including rewarded-ad offers.
- Rewarded Ad unlock is temporary (`24h`) and only for chart pair selection.
- Rewarded Ad unlock does not affect intraday range access.

## Naming and Format Decision

- Use **Rewarded Ad** (opt-in), not Rewarded Interstitial.
- User must explicitly choose to watch an ad for reward.
- No automatic full-screen ad transitions for this flow.

## Architecture

Create these modules:

- `lib/src/core/monetization/models/temporary_unlock.dart`
- `lib/src/core/monetization/temporary_unlock_store.dart`
- `lib/src/core/monetization/rewarded_ad_service.dart`
- `lib/src/core/monetization/rewarded_ad_service_stub.dart`
- `lib/src/features/charts/widgets/locked_pair_action_sheet.dart`

Update these modules:

- `lib/src/core/monetization/monetization_controller.dart`
- `lib/src/features/charts/widgets/chart_currency_picker_sheet.dart`
- `lib/src/features/charts/widgets/pair_selector.dart`
- `lib/src/features/charts/charts_screen.dart`
- `lib/src/app.dart`

## Core Logic Rules

### Entitlement gates

- `adsEnabled = !hasActiveSubscription && !hasRemoveAdsLifetime`
- `canUseIntradayRanges = hasActiveSubscription`

### Pair unlock gate

- `isChartPairUnlocked(base, quote)` checks in this order:
  1. free default pair (`USD <-> EUR`)
  2. active subscription
  3. Charts Pro lifetime
  4. temporary rewarded unlock

### Temporary unlock shape

- unlock target is a **bidirectional pair**, not a direction.
- canonical pair key should be stable, for example alphabetical (`EUR_USD`, `GBP_USD`).
- default lifetime: `24h`.
- expired unlocks are cleaned on load.

### Rewarded offer gate

- rewarded unlock offer is shown only for pure-free users:
  - `!hasActiveSubscription`
  - `!hasRemoveAdsLifetime`
  - `!hasChartsProLifetime`

Remove Ads owners must never see rewarded-ad prompts.

## UI Flow

When user taps a locked chart currency:

- open `LockedPairActionSheet`
- show CTA `Watch ad to unlock this pair for 24h` only when rewarded offer gate is true
- always show CTA `Unlock all pairs forever` (Charts Pro path)
- on rewarded success, grant temporary unlock and refresh picker state

Add `X` close button in chart picker header in addition to swipe-down dismiss.

## Animation Rules

- Pair swap trigger uses rotation/fade transition (`650ms`).
- Range change uses fade/slide transition (fast path).
- Rotation must not trigger on `1W/1M/3M/6M/1Y/2Y` taps.

## Development Stub Behavior (No Real Ads Yet)

For `RewardedAdServiceStub`:

- simulate loading state
- simulate short playback with dev fast-forward (~3 seconds)
- return success and grant temporary unlock

This is only for development. Real ad watch duration in production is creative-driven by ad networks.

## Risks and Mitigations

- **Policy drift risk**: showing rewarded ads to Remove Ads buyers breaks purchase promise.
  - Mitigation: strict rewarded offer gate.
- **Directionality bug**: unlocking `USD -> GBP` but not `GBP -> USD` causes swap inconsistency.
  - Mitigation: canonical bidirectional key.
- **Animation UX bug**: swap rotation applied to range taps.
  - Mitigation: separate swap and range transition paths.
- **Security/abuse risk**: temporary unlock is local without server verification.
  - Mitigation: keep reward low-value and temporary; revisit with backend/SSV if needed later.

## Test Plan

- free user sees locked non-default pairs
- free user can trigger rewarded unlock prompt
- Remove Ads user does not see rewarded unlock option
- subscription and Charts Pro users see unlocked pair selection
- temporary unlock persists and expires correctly
- temporary unlock is bidirectional
- intraday remains subscription-only after rewarded unlock
- range change does not trigger swap rotation

## Verification

- run `./scripts/check.sh`
- build and run iOS simulator app
- manual charts checks:
  - close button works
  - swap animation only on swap button
  - rewarded unlock flow updates lock state
