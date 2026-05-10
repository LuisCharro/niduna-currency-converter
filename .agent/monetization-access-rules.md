# Monetization Access Rules

> Status: Draft for implementation
> Scope: Phase 1 behavior + future-safe entitlement model
> Last updated: 2026-05-10

---

## Purpose

This document defines exactly how the app behaves for free users, one-time unlock users,
and subscription users.

Use this as the source of truth for:

- ad visibility
- chart access limits
- upgrade prompts
- behavior when subscription expires

If a UI proposal conflicts with these rules, update this file first.

---

## Entitlements

Represent monetization state with explicit booleans:

- `hasActiveSubscription`
- `hasRemoveAdsLifetime`
- `hasChartsProLifetime`

Optional future entitlement (not Phase 1):

- `hasIntradayLifetime`

Notes:

- Subscription has highest priority for unlocked access.
- One-time unlocks remain owned forever.
- If subscription expires, one-time unlocks still apply.

---

## Global Access Rules

### 1) Subscription active

- Ads are hidden everywhere.
- All chart pair selection is unlocked.
- Intraday ranges (`1H`, `6H`, `1D`) are unlocked.

### 2) No active subscription

- Ads are visible unless `hasRemoveAdsLifetime` is true.
- Chart pair selection is unlocked only if `hasChartsProLifetime` is true.
- Intraday ranges remain locked (subscription feature).
- Pure-free users can optionally use Rewarded Ad for temporary chart-pair unlock.

### 3) Subscription canceled or expired

- Subscription unlocks are removed.
- Any one-time unlocks stay active.
- Ads return only if the user does not own Remove Ads lifetime.

---

## Feature Matrix

| Feature | Free | Remove Ads (one-time) | Charts Pro (one-time) | Subscription |
|---|---|---|---|---|
| Banner ads hidden | No | Yes | No | Yes |
| Default chart pair (`USD -> EUR`) | Yes | Yes | Yes | Yes |
| Swap (`USD <-> EUR`) | Yes | Yes | Yes | Yes |
| Choose any chart pair | No | No | Yes | Yes |
| Ranges `1W/1M/3M/6M/1Y/2Y` | Yes | Yes | Yes | Yes |
| Intraday `1H/6H/1D` | No | No | No | Yes |
| "All premium chart features" | No | No | Partial | Yes |
| Rewarded ad offer for temporary pair unlock | Yes | No | No | No need |

---

## Charts UX Rules

## Pair selection

- Replace pair dropdown with two buttons:
  - Base currency button
  - Quote currency button
- Place a one-tap swap button between/near these controls.
- Use a bottom sheet picker for both Base and Quote selection.

## Bottom sheet behavior

- Use a bottom-up modal sheet pattern.
- Include search field + currency list (code, name, symbol).
- If ads are enabled for the user, show the chart-context banner area in the sheet.

## Locked behavior

- Free users can use only `USD <-> EUR` in charts.
- If free user taps a locked currency selection path, show lock state + upgrade CTA.
- If non-subscriber taps `1H`, `6H`, or `1D`, show lock state + subscription CTA.
- Rewarded ad unlock applies only to chart pair selection, not intraday ranges.
- Rewarded unlock duration is temporary (`24h`) and pair-specific.
- Rewarded unlock must be bidirectional for the pair (`USD<->GBP`, not one direction only).

---

## Default Pair Rules

- Default chart pair is `USD -> EUR`.
- Swap is always available to flip to `EUR -> USD`.
- This default gives immediate value without forcing payment.

---

## Ads Visibility Logic

Implement the ads decision as a single computed rule:

```text
adsEnabled = !hasActiveSubscription && !hasRemoveAdsLifetime
```

Interpretation:

- Subscription always removes ads while active.
- Remove Ads lifetime removes ads permanently.
- If subscription expires, ads come back unless lifetime Remove Ads is owned.

---

## Unlock Logic (Suggested)

Use simple guard helpers:

```text
canSelectAnyChartPair = hasActiveSubscription || hasChartsProLifetime
canUseIntradayRanges = hasActiveSubscription
```

Recommended additional helpers:

```text
canOfferRewardedChartUnlock = !hasActiveSubscription && !hasRemoveAdsLifetime && !hasChartsProLifetime
isChartPairUnlocked = defaultFreePair || hasActiveSubscription || hasChartsProLifetime || temporaryPairUnlockActive
```

---

## Paywall Trigger Rules

Trigger upgrade UI when:

- user taps locked chart pair selection (without Subscription or Charts Pro)
- user taps intraday range (`1H`, `6H`, `1D`) without Subscription
- user taps "Remove ads" CTA below banner

Recommended copy themes:

- Pair lock: "Unlock all chart pairs"
- Intraday lock: "Unlock intraday ranges with Subscription"
- Banner CTA: "Remove ads →" (subtle text link below banner)

Keep CTA text short and specific.

---

## IAP Purchase Products (Phase 1)

### Product catalog

| Product | Type | Price | Stub | Entitlement on success |
|--------|------|-------|------|------------------------|
| `removeAds` | One-time | 1.99 CHF | ✅ | `setRemoveAdsLifetime(true)` |
| `chartsPro` | One-time | 2.99 CHF | ✅ | `setChartsProLifetime(true)` |
| `subscription` | Recurring | Coming Soon | N/A (informational) | Informational only |

### Subscription "Coming Soon" treatment (Phase 1)

- Subscription card is **informational only** — not clickable for purchase
- Shows pricing hint: "1 week free, then X.XX CHF/year"
- Button says `[Notify Me]` — tapping shows toast: "We'll notify you when Premium is ready!"
- Does NOT call `PurchaseService` — no backend yet
- When real subscriptions are built (Phase 2): swap card to active state, wire to service

### IAP stub architecture

Identical pattern to `RewardedAdService`:

```
lib/src/core/monetization/
├── purchase_service.dart          ← abstract interface: Future<bool> purchase(ProductType)
└── purchase_service_stub.dart    ← stub: ~2s simulated purchase → always returns true
```

`PurchaseServiceStub` phases:
1. "Purchasing..." spinner (~800ms)
2. "Processing payment..." spinner (~1200ms)
3. "✓ Purchase complete!" green check (~1s)
4. Auto-dismiss, `onResult(true)` called

When real IAP is integrated (Phase 2): replace `PurchaseServiceStub` with real Store Kit / Play Billing implementation. Zero UI changes needed.

### IAP purchase player (`IapPurchasePlayer`)

Reusable fullscreen overlay (same pattern as `RewardedAdPlayer`):

```dart
class IapPurchasePlayer extends StatefulWidget {
  final MonetizationController controller;
  final ProductType product; // removeAds | chartsPro | subscription
  final void Function(bool success) onResult;
}
```

Phase machine: `loading` → `processing` → `completed` | `failed`

Called from:
- Settings Premium section Remove Ads card → `product: removeAds`
- Settings Premium section Charts Pro card → `product: chartsPro`
- Charts picker "Unlock all pairs forever" → `product: chartsPro`
- Banner "Remove ads" CTA → `product: removeAds`

---

## Paywall Entry Points

| Entry point | Screen | Product | Trigger UI |
|-------------|---------|---------|------------|
| Premium section | Settings | Remove Ads | Card with [Buy] button → `IapPurchasePlayer` |
| Premium section | Settings | Charts Pro | Card with [Buy] button → `IapPurchasePlayer` |
| Premium section | Settings | Subscription | Card with [Notify Me] button → toast |
| Locked pair action sheet | Charts picker | Charts Pro | "Unlock all pairs forever" → `IapPurchasePlayer` |
| Banner "Remove ads" CTA | Convert + Charts | Remove Ads | Text link below banner → `IapPurchasePlayer` |
| Intraday range lock | Charts | Subscription | Tap 1H/6H/1D → SnackBar "Coming Soon with Premium" |
| Max favorites card | Favorites | Favorites unlock | Future Phase 2 |

---

## Remove Ads Purchase Rules

- Remove Ads purchase hides ALL ad surfaces (Convert tab, Charts tab, picker sheet banner)
- Remove Ads purchase removes ALL rewarded-ad offer prompts (users should never be prompted to watch ads after purchasing Remove Ads)
- Remove Ads is a **permanent** one-time unlock stored in SharedPreferences (`entitlement_remove_ads_lifetime`)
- Remove Ads owners can still buy Charts Pro for pair selection + subscription for intraday ranges

---

## Subscription (Phase 1 — Informational Only)

Phase 1 shows subscription as "Coming Soon" without purchase functionality.

Rules:

- Subscription card is **disabled** (informational) until real IAP is wired
- Shows: "🚧 Coming Soon", "1 week free, then X.XX CHF/year", `[Notify Me]` button
- Tapping `Notify Me` → toast confirmation (future: stored interest list)
- When subscription is active (Phase 2+): `hasActiveSubscription = true` unlocks everything
- Subscription expiry: falls back to owned one-time unlocks (Remove Ads, Charts Pro)

---

## Edge Cases

### Subscription expires after prior use

- Remove subscription-only access immediately after entitlement refresh.
- Keep lifetime unlocks active.

### User has both one-time unlocks and subscription

- Subscription active state still governs access (superset).
- On expiration, fallback to one-time unlock scope.

### Offline launch

- Use last known valid entitlement cache.
- Revalidate with store when network returns.
- Do not grant new premium access without prior entitlement proof.
- Temporary rewarded unlocks can still work offline until expiration.

### Restore purchases

- Restored one-time purchases must reactivate immediately.
- Restored subscription state follows store active/inactive status.
- "Restore Purchases" button in Settings Premium section triggers store restore flow.

### Remove Ads + Rewarded conflict

- Users with Remove Ads ownership must not see rewarded-ad prompts.
- If user buys Remove Ads after using rewarded unlocks, rewarded prompts stop immediately.

### User buys Charts Pro after Remove Ads

- Both entitlements are independent and stack correctly.
- Charts Pro enables pair selection; Remove Ads hides ad surfaces.
- No conflicts.

---

## Edge Cases

### Subscription expires after prior use

- Remove subscription-only access immediately after entitlement refresh.
- Keep lifetime unlocks active.

### User has both one-time unlocks and subscription

- Subscription active state still governs access (superset).
- On expiration, fallback to one-time unlock scope.

### Offline launch

- Use last known valid entitlement cache.
- Revalidate with store when network returns.
- Do not grant new premium access without prior entitlement proof.
- Temporary rewarded unlocks can still work offline until expiration.

### Restore purchases

- Restored one-time purchases must reactivate immediately.
- Restored subscription state follows store active/inactive status.

### Remove Ads + Rewarded conflict

- Users with Remove Ads ownership must not see rewarded-ad prompts.
- If user buys Remove Ads after using rewarded unlocks, rewarded prompts stop immediately.

---

## QA Checklist

Validate all flows below:

- Free user sees ads and locked pair selection beyond `USD <-> EUR`.
- Free user sees locked intraday ranges.
- Free user can watch rewarded ad and unlock selected pair temporarily.
- Remove Ads user sees no ads but still has locked pair/intraday unless separately unlocked.
- Remove Ads user never sees rewarded unlock option.
- Charts Pro user can pick any pair but still sees ads and locked intraday ranges.
- Subscription user gets no ads + any pair + intraday ranges.
- Subscription canceled user falls back correctly to owned one-time unlocks.
- Restore purchases restores expected entitlement state.
- Temporary unlock expires and relocks pair automatically.

---

## Implementation Notes

- Keep entitlement logic in one place (single service/provider).
- UI should read computed capability flags, not raw store state.
- Keep lock copy and purchase entry points consistent across tabs.
- Reuse the same bottom sheet component for base/quote selection.
