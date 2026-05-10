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

---

## Paywall Trigger Rules

Trigger upgrade UI when:

- user taps locked chart pair selection (without Subscription or Charts Pro)
- user taps intraday range (`1H`, `6H`, `1D`) without Subscription

Recommended copy themes:

- Pair lock: "Unlock all chart pairs"
- Intraday lock: "Unlock intraday ranges with Subscription"

Keep CTA text short and specific.

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

### Restore purchases

- Restored one-time purchases must reactivate immediately.
- Restored subscription state follows store active/inactive status.

---

## QA Checklist

Validate all flows below:

- Free user sees ads and locked pair selection beyond `USD <-> EUR`.
- Free user sees locked intraday ranges.
- Remove Ads user sees no ads but still has locked pair/intraday unless separately unlocked.
- Charts Pro user can pick any pair but still sees ads and locked intraday ranges.
- Subscription user gets no ads + any pair + intraday ranges.
- Subscription canceled user falls back correctly to owned one-time unlocks.
- Restore purchases restores expected entitlement state.

---

## Implementation Notes

- Keep entitlement logic in one place (single service/provider).
- UI should read computed capability flags, not raw store state.
- Keep lock copy and purchase entry points consistent across tabs.
- Reuse the same bottom sheet component for base/quote selection.
