# IAP Purchase Plan — Slice 8

> Status: In progress
> Scope: Phase 1 IAP stub (simulated purchase flows)
> Last updated: 2026-05-10

---

## Purpose

Implement simulated IAP purchase flows for Phase 1 before real Store Kit (iOS) / Play Billing (Android) integration. The UI, entitlement system, and purchase-player pattern are fully wired — only the actual payment processing is stubbed.

When real IAP is added in Phase 2: replace `PurchaseServiceStub` with real implementation. Zero UI changes needed.

---

## Architecture

### Pattern (mirrors RewardedAdService)

```
lib/src/core/monetization/
├── purchase_service.dart          ← abstract interface
└── purchase_service_stub.dart    ← stub implementation
```

### PurchaseService interface

```dart
enum ProductType { removeAds, chartsPro, subscription }

abstract class PurchaseService {
  Future<bool> purchase(ProductType product);
}
```

### Stub phases (~2s total)

| Phase | Duration | UI |
|-------|----------|-----|
| Loading | ~800ms | "Purchasing..." spinner |
| Processing | ~1200ms | "Processing payment..." spinner |
| Completed | ~1s | "✓ Purchase complete!" green check |
| Failed | — | "✕ Purchase failed" red error (stub always succeeds) |

---

## Files

| File | Action | Description |
|------|--------|-------------|
| `lib/src/core/monetization/purchase_service.dart` | New | Abstract interface + `ProductType` enum |
| `lib/src/core/monetization/purchase_service_stub.dart` | New | Stub implementation (~2s simulated purchase) |
| `lib/src/features/settings/widgets/iap_purchase_player.dart` | New | Fullscreen overlay widget |
| `lib/src/core/monetization/monetization_controller.dart` | Modify | Add `PurchaseService` dependency + `purchaseChartsPro()` + `purchaseRemoveAds()` |
| `lib/src/features/settings/settings_screen.dart` | Modify | Add Premium section (3 cards) |
| `lib/src/features/charts/widgets/chart_currency_picker_sheet.dart` | Modify | Wire `'buy_forever'` → `IapPurchasePlayer` |
| `lib/src/features/convert/convert_screen.dart` | Modify | Add "Remove ads →" CTA below banner |
| `lib/src/features/charts/charts_screen.dart` | Modify | Add "Remove ads →" CTA below banner |
| `lib/src/app.dart` | Modify | Inject `PurchaseServiceStub()` |

---

## Product Catalog

| Product | Price | Calls on success |
|--------|-------|-----------------|
| `removeAds` | 1.99 CHF | `monetization.setRemoveAdsLifetime(true)` |
| `chartsPro` | 2.99 CHF | `monetization.setChartsProLifetime(true)` |
| `subscription` | Coming Soon | Informational only (no service call) |

---

## IapPurchasePlayer

### API

```dart
class IapPurchasePlayer extends StatefulWidget {
  final MonetizationController controller;
  final ProductType product;
  final void Function(bool success) onResult;
}
```

### Phases

```dart
enum _IapPhase { loading, processing, completed, failed }
```

### Flow

1. `initState` → starts `_runPurchaseFlow()`
2. `_runPurchaseFlow()`:
   - `loading` phase (~800ms)
   - `controller.purchaseChartsPro()` or `controller.purchaseRemoveAds()`
   - If success → `completed` phase (~1s)
   - If failure → `failed` phase
3. Fade out → call `onResult(success)`
4. Parent pops the route

### Entitlements on success

- `removeAds` → `setRemoveAdsLifetime(true)` → `notifyListeners()` → ads hidden everywhere
- `chartsPro` → `setChartsProLifetime(true)` → `notifyListeners()` → all pairs unlocked

---

## Settings Premium Section

```
┌─────────────────────────────────────────┐
│  💎 Premium                            │
├─────────────────────────────────────────┤
│  🚫 Remove Ads            [1.99  Buy]  │
│     Enjoy without ads                  │
│                                        │
│  🔓 Unlock All Pairs    [2.99  Buy]     │
│     Any chart pair, forever            │
│                                        │
│  ⭐ Premium Subscription               │
│     Everything + intraday ranges       │
│     🚧 Coming Soon                     │
│     1 week free, then X.XX CHF/year    │
│                      [Notify Me]       │
│                                        │
│  ─────────────────────────────────     │
│  Restore Purchases                     │
└─────────────────────────────────────────┘
```

### Card states

| Card | Not owned | Owned |
|------|-----------|-------|
| Remove Ads | "Buy" active | "✓ Purchased" badge |
| Charts Pro | "Buy" active | "✓ Purchased" badge |
| Subscription | "Notify Me" disabled | N/A |

---

## Banner "Remove ads" CTA

Thin row below `AdBannerPlaceholder`:

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Text('Enjoy without ads', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
    const SizedBox(width: 4),
    GestureDetector(
      onTap: () => _showRemoveAdsPurchase(context),
      child: Text('Remove ads →', style: TextStyle(fontSize: 12, color: AppTheme.primary)),
    ),
  ],
)
```

Shown only when `monetization.adsEnabled == true`.

---

## Intraday Range Lock Toast

When user taps `1H`/`6H`/`1D` without subscription:

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Intraday ranges require Premium Subscription — coming soon!'),
    duration: Duration(seconds: 3),
  ),
);
```

---

## Tests

```dart
test('PurchaseServiceStub.purchase returns true for removeAds', ...)
test('PurchaseServiceStub.purchase returns true for chartsPro', ...)
test('IapPurchasePlayer phases: loading → processing → completed', ...)
test('MonetizationController.purchaseRemoveAds sets entitlement', ...)
test('MonetizationController.purchaseChartsPro sets entitlement', ...)
test('banner CTA hidden when adsEnabled == false', ...)
test('subscription card shows Coming Soon state', ...)
```

---

## Migration to Real IAP

Phase 2 steps:

1. Add `store_kit` or `in_app_purchase` package
2. Create `PurchaseServiceImpl` implementing `PurchaseService`
3. In `app.dart`: replace `PurchaseServiceStub()` with `PurchaseServiceImpl()`
4. Zero UI changes — `IapPurchasePlayer`, `ProductType`, and entitlement logic stay identical
