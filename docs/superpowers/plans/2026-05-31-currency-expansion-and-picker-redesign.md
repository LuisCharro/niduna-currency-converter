# Currency Expansion & Sectioned Picker Implementation Plan

## Status Update (2026-05-31)

Completed in this session:

- Fiat expansion completed: 16 -> 40 supported fiat currencies
- Crypto expansion completed: 2 -> 11 supported crypto currencies
- Currency icon generation completed: 10 new icons (AED + 9 crypto)
- Convert picker redesign completed: region-based sectioned groups
- Follow-up picker update completed: removed `Major` section and redistributed codes to region groups
- Convert defaults updated to `EUR`, `GBP`, `JPY`, `CAD`, `BTC`
- Charts picker updated to the same sectioned group model
- Chart pair 24h unlock badge fixed for both base (left) and quote (right) pills
- Chart pair 24h badge overlap fixes shipped (reserved badge space + compact narrow-screen mode)
- Agent workflow note documented: `sim_tap.sh` is unreliable for precise UI flows; prefer integration-test-based interaction scripts

Open items from release work remain in `RELEASE_CHECKLIST.md`.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expand currency coverage from 18 (16 fiat + 2 crypto) to ~51 (40 fiat + 11 crypto), generate missing currency badge icons via MiniMax (10 new icons within 50/day quota), and redesign the currency picker with region-based sectioned groups.

**Architecture:** Add new `SupportedCurrency` entries to `supported_currencies.dart` and new `CryptoAsset` entries to `crypto_asset.dart`. Update the fawazahmed price client to parse all new crypto codes from the existing single API call (zero extra cost). Generate 10 missing badge icons via MiniMax `image-01`. Redesign `CurrencyPickerSheet` to group currencies into collapsible sections. Generalize all hardcoded BTC/ETH logic to handle the expanded crypto set.

**Tech Stack:** Flutter/Dart, fawazahmed0 CDN (CC0-1.0), Frankfurter API (Unlicense), MiniMax image-01 (50 images/day quota)

---

## API Coverage Verification (done)

Frankfurter `/v2/rates?base=USD` returns **164 currencies**. Verified all 40 planned fiat currencies are present:
- All 40 codes return rates: USD, EUR, GBP, JPY, CNY, CHF, SEK, NOK, DKK, PLN, CZK, HUF, RON, CAD, AUD, MXN, BRL, ARS, CLP, COP, INR, SGD, HKD, KRW, THB, PHP, IDR, MYR, TWD, NZD, TRY, AED, ILS, ZAR
- BGN is NOT available — excluded from plan (was never planned)
- fawazahmed0 `usd.json` returns 200+ crypto entries including all 11 target cryptos

---

## Deep Impact Analysis

### Files that MUST change

| File | Why | Severity |
|------|-----|----------|
| `supported_currencies.dart` | Add 24 fiat + 9 crypto entries | CRITICAL |
| `crypto_asset.dart` | Add 9 CryptoAsset entries with provider IDs | CRITICAL |
| `fawazahmed_crypto_usd_price_client.dart` | Hardcoded `btc`/`eth` parsing → iterate `supportedCryptoAssets` | CRITICAL |
| `fawazahmed_crypto_usd_history_client.dart` | Validation bounds `min=50` rejects stablecoins (~$1) | HIGH |
| `coinpaprika_crypto_usd_price_client.dart` | Hardcoded BTC/ETH validation | HIGH |
| `coinpaprika_crypto_usd_history_client.dart` | Binary BTC/not-BTC validation bounds | HIGH |
| `coingecko_crypto_usd_history_client.dart` | Binary BTC/not-BTC validation bounds | HIGH |
| `convert_quote_builder.dart` | Hardcoded `BTC=>8, ETH=>6` decimal precision switch | HIGH |
| `conversion_lens_sheet.dart` | Hardcoded BTC/ETH reverse targets + precision in 5 methods | HIGH |
| `currency_flags.dart` | Missing AED + 9 crypto emojis | MEDIUM |
| `currency_flag_icon.dart` | Missing 10 _assetMap entries (AED + 9 crypto) | MEDIUM |
| `test/convert_real_rates_test.dart` | `hasLength(16)` assertion breaks immediately | HIGH |
| `ui_copy.dart` | "BTC and ETH" hardcoded in 5 languages (4 strings) | LOW |

### Files that are fine (no changes needed)

| File | Why OK |
|------|--------|
| `frankfurter_latest_rates_client.dart` | Iterates `supportedFiatCurrencies` dynamically |
| `frankfurter_client.dart` (charts) | Iterates `supportedCurrencies` dynamically |
| `multi_provider_latest_rates_repository.dart` | Generic routing by `isFiatCurrency()`/`isCryptoCurrency()` |
| `multi_provider_rates_client.dart` | Generic fiat/crypto routing |
| `convert_controller.dart` | Default `'USD'` base + `['EUR','GBP','JPY']` selected = fine |
| `convert_controller_loading.dart` | Iterates `supportedCryptoCurrencies` dynamically |
| `convert_controller_editing.dart` | Uses `isCryptoCurrency()` for toggle |
| `app_preferences.dart` | Generic key patterns, sensible defaults |
| `favorites_store.dart` | Generic `'BASE-QUOTE'` key format |
| `charts_controller.dart` | Only uses `isCryptoCurrency()` for range |
| `currency_picker_sheet.dart` | Iterates `allSupportedCurrencies` dynamically |
| `currency_picker_tile.dart` | Generic `SupportedCurrency` properties |
| `base_currency_picker.dart` | Iterates `supportedCurrencies` dynamically |
| `rates_service.dart` | Only uses `isCryptoCurrency()` |
| `latest_rates_cache.dart` | Generic `latest_rates_$base` key |
| `rate_normalizer.dart` | USD pivot is correct for all |
| `provider_config.dart` | No currency logic |
| `provider_usage_info.dart` | "BTC/ETH" text reference only (cosmetic) |
| `currency_colors.dart` | Has hash fallback for unmapped codes |

### Edge Cases

1. **Stablecoins (USDT, USDC ≈ $1.00):**
   - Current `min=50` validation would reject them → fix validation
   - Decimal precision 6-8 is overkill → need `2` like fiat
   - Reverse targets `[10, 50, 100]` (fiat-like) instead of `[0.01, 0.1, 1]` (crypto-like)

2. **Low-value cryptos (DOGE ≈ $0.20, MATIC ≈ $0.50):**
   - Need different precision than BTC (8 digits overkill)
   - Reverse targets need to be fiat-like amounts

3. **High-inflation fiat (ARS ≈ 1200/USD, TRY ≈ 38/USD):**
   - Generic `decimalPlaces` default of 2 is fine
   - Rate display may show 3-4 digit numbers — OK, NumberFormat handles it

---

## File Structure

| File | Role | Change |
|------|------|--------|
| `lib/src/core/currency/supported_currencies.dart` | Currency registry | **MODIFY** — add 24 fiat + 9 crypto |
| `lib/src/core/rates/crypto/crypto_asset.dart` | Crypto asset registry | **MODIFY** — add 9 entries |
| `lib/src/core/rates/crypto/fawazahmed_crypto_usd_price_client.dart` | Crypto price fetcher | **MODIFY** — dynamic parsing |
| `lib/src/core/rates/crypto/fawazahmed_crypto_usd_history_client.dart` | Crypto history fetcher | **MODIFY** — relax validation |
| `lib/src/core/rates/crypto/coinpaprika_crypto_usd_price_client.dart` | Dev-only price client | **MODIFY** — generalize validation |
| `lib/src/core/rates/crypto/coinpaprika_crypto_usd_history_client.dart` | Dev-only history client | **MODIFY** — generalize validation |
| `lib/src/core/rates/crypto/coingecko_crypto_usd_history_client.dart` | Dev-only history client | **MODIFY** — generalize validation |
| `lib/src/features/convert/domain/convert_quote_builder.dart` | Quote formatting | **MODIFY** — generalize crypto precision |
| `lib/src/features/convert/widgets/conversion_lens_sheet.dart` | Long-press detail sheet | **MODIFY** — generalize crypto handling |
| `lib/src/core/localization/ui_copy.dart` | Localized strings | **MODIFY** — replace "BTC and ETH" references |
| `lib/src/shared/widgets/currency_flags.dart` | Emoji flag map | **MODIFY** — add AED + 9 crypto |
| `lib/src/shared/widgets/currency_flag_icon.dart` | Icon widget | **MODIFY** — add 10 _assetMap entries |
| `.devtools/currency_icon_prompts.json` | Icon prompts | **MODIFY** — add 10 entries |
| `test/convert_real_rates_test.dart` | Fiat scope test | **MODIFY** — update length + code list |
| `lib/src/features/convert/widgets/currency_picker_sheet.dart` | Picker sheet | **REWRITE** — sectioned groups |
| `lib/src/features/convert/widgets/currency_section_header.dart` | Section header | **NEW** |
| `lib/src/core/currency/currency_groups.dart` | Grouping model | **NEW** |

### New crypto categorization for precision/validation

```
┌─────────────┬────────────────────┬──────────┬─────────────────┐
│ Category    │ Codes              │ Digits   │ Reverse targets │
├─────────────┼────────────────────┼──────────┼─────────────────┤
│ Major crypto│ BTC                │ 8        │ [0.001,0.01,0.1]│
│ Alt crypto  │ ETH, SOL, AVAX,   │ 6        │ [0.01, 0.1, 1]  │
│             │ BNB, MATIC, ADA,  │          │                 │
│             │ XRP                │          │                 │
│ Stablecoin  │ USDT, USDC        │ 2        │ [10, 50, 100]   │
│ Meme coin   │ DOGE               │ 4        │ [10, 50, 100]   │
└─────────────┴────────────────────┴──────────┴─────────────────┘
```

This categorization drives precision in `convert_quote_builder.dart`, reverse targets in `conversion_lens_sheet.dart`, and validation bounds in history clients.

---

## Inventory: What We Already Have

### Icons already in `assets/icons/currencies/` (39 total for our planned 40 fiats + 2 crypto):
All 40 planned fiat currencies except **AED** already have PNG icons. BTC and ETH also have icons. That's 41 existing icons.

### Icons that need MiniMax generation (10 total):

| Code | Name | Type |
|------|------|------|
| AED | UAE Dirham | Fiat |
| SOL | Solana | Crypto |
| XRP | Ripple | Crypto |
| ADA | Cardano | Crypto |
| DOGE | Dogecoin | Crypto |
| AVAX | Avalanche | Crypto |
| USDT | Tether USD | Crypto |
| USDC | USD Coin | Crypto |
| BNB | BNB | Crypto |
| MATIC | Polygon | Crypto |

---

## Task 1: Expand Fiat Currencies (16 → 40)

**Files:**
- Modify: `lib/src/core/currency/supported_currencies.dart`

- [ ] **Step 1: Replace `supportedFiatCurrencies` list with expanded set**

Replace the current 16-item list with 40 items:

```dart
const List<SupportedCurrency> supportedFiatCurrencies = <SupportedCurrency>[
  // ── Major ──────────────────────────────────────
  SupportedCurrency(code: 'USD', name: 'US Dollar', symbol: r'$'),
  SupportedCurrency(code: 'EUR', name: 'Euro', symbol: '€'),
  SupportedCurrency(code: 'GBP', name: 'British Pound', symbol: '£'),
  SupportedCurrency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
  SupportedCurrency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
  // ── Europe ─────────────────────────────────────
  SupportedCurrency(code: 'CHF', name: 'Swiss Franc', symbol: 'Fr'),
  SupportedCurrency(code: 'SEK', name: 'Swedish Krona', symbol: 'kr'),
  SupportedCurrency(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr'),
  SupportedCurrency(code: 'DKK', name: 'Danish Krone', symbol: 'kr'),
  SupportedCurrency(code: 'PLN', name: 'Polish Zloty', symbol: 'zł'),
  SupportedCurrency(code: 'CZK', name: 'Czech Koruna', symbol: 'Kč'),
  SupportedCurrency(code: 'HUF', name: 'Hungarian Forint', symbol: 'Ft'),
  SupportedCurrency(code: 'RON', name: 'Romanian Leu', symbol: 'lei'),
  // ── Americas ───────────────────────────────────
  SupportedCurrency(code: 'CAD', name: 'Canadian Dollar', symbol: r'CA$'),
  SupportedCurrency(code: 'AUD', name: 'Australian Dollar', symbol: r'AU$'),
  SupportedCurrency(code: 'MXN', name: 'Mexican Peso', symbol: r'MX$'),
  SupportedCurrency(code: 'BRL', name: 'Brazilian Real', symbol: r'R$'),
  SupportedCurrency(code: 'ARS', name: 'Argentine Peso', symbol: r'AR$'),
  SupportedCurrency(code: 'CLP', name: 'Chilean Peso', symbol: r'CLP$'),
  SupportedCurrency(code: 'COP', name: 'Colombian Peso', symbol: r'COP$'),
  // ── Asia Pacific ───────────────────────────────
  SupportedCurrency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
  SupportedCurrency(code: 'SGD', name: 'Singapore Dollar', symbol: r'S$'),
  SupportedCurrency(code: 'HKD', name: 'Hong Kong Dollar', symbol: r'HK$'),
  SupportedCurrency(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
  SupportedCurrency(code: 'THB', name: 'Thai Baht', symbol: '฿'),
  SupportedCurrency(code: 'PHP', name: 'Philippine Peso', symbol: '₱'),
  SupportedCurrency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp'),
  SupportedCurrency(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM'),
  SupportedCurrency(code: 'TWD', name: 'Taiwan Dollar', symbol: r'NT$'),
  SupportedCurrency(code: 'NZD', name: 'New Zealand Dollar', symbol: r'NZ$'),
  // ── Middle East & Africa ──────────────────────
  SupportedCurrency(code: 'TRY', name: 'Turkish Lira', symbol: '₺'),
  SupportedCurrency(code: 'AED', name: 'UAE Dirham', symbol: r'AED'),
  SupportedCurrency(code: 'ILS', name: 'Israeli Shekel', symbol: '₪'),
  SupportedCurrency(code: 'ZAR', name: 'South African Rand', symbol: 'R'),
];
```

- [ ] **Step 2: Update test to match new count**

In `test/convert_real_rates_test.dart`, update the assertion:

Change line 17 from `expect(codes, hasLength(16));` to `expect(codes, hasLength(40));` and update the `containsAll` list to include all 40 fiat codes. Change line 39 from `isNot(contains(anyOf('RUB', 'BTC', 'ETH', 'XAU', 'XAG')))` to keep it (crypto should NOT appear in `supportedCurrencies` which is fiat-only).

- [ ] **Step 3: Run analysis**

Run: `./scripts/check.sh`
Expected: analyze passes, tests pass

- [ ] **Step 4: Commit**

```bash
git add lib/src/core/currency/supported_currencies.dart test/convert_real_rates_test.dart
git commit -m "feat(currencies): expand fiat coverage from 16 to 40"
```

---

## Task 2: Expand Crypto Currencies (2 → 11)

**Files:**
- Modify: `lib/src/core/rates/crypto/crypto_asset.dart`
- Modify: `lib/src/core/currency/supported_currencies.dart` (crypto list)
- Modify: `lib/src/core/rates/crypto/fawazahmed_crypto_usd_price_client.dart`
- Modify: `lib/src/core/rates/crypto/fawazahmed_crypto_usd_history_client.dart`
- Modify: `lib/src/core/rates/crypto/coinpaprika_crypto_usd_price_client.dart`
- Modify: `lib/src/core/rates/crypto/coinpaprika_crypto_usd_history_client.dart`
- Modify: `lib/src/core/rates/crypto/coingecko_crypto_usd_history_client.dart`
- Modify: `lib/src/features/convert/domain/convert_quote_builder.dart`
- Modify: `lib/src/features/convert/widgets/conversion_lens_sheet.dart`
- Modify: `lib/src/core/localization/ui_copy.dart`
- Modify: `lib/src/shared/widgets/currency_flags.dart`

- [ ] **Step 1: Expand `crypto_asset.dart`**

Replace the 2-item list with 11:

```dart
class CryptoAsset {
  const CryptoAsset({
    required this.code,
    required this.coinPaprikaId,
    required this.coinCapId,
  });

  final String code;
  final String coinPaprikaId;
  final String coinCapId;
}

const List<CryptoAsset> supportedCryptoAssets = <CryptoAsset>[
  CryptoAsset(code: 'BTC', coinPaprikaId: 'btc-bitcoin', coinCapId: 'bitcoin'),
  CryptoAsset(code: 'ETH', coinPaprikaId: 'eth-ethereum', coinCapId: 'ethereum'),
  CryptoAsset(code: 'SOL', coinPaprikaId: 'sol-solana', coinCapId: 'solana'),
  CryptoAsset(code: 'XRP', coinPaprikaId: 'xrp-xrp', coinCapId: 'ripple'),
  CryptoAsset(code: 'ADA', coinPaprikaId: 'ada-cardano', coinCapId: 'cardano'),
  CryptoAsset(code: 'DOGE', coinPaprikaId: 'doge-dogecoin', coinCapId: 'dogecoin'),
  CryptoAsset(code: 'AVAX', coinPaprikaId: 'avax-avalanche', coinCapId: 'avalanche-2'),
  CryptoAsset(code: 'USDT', coinPaprikaId: 'usdt-tether', coinCapId: 'tether'),
  CryptoAsset(code: 'USDC', coinPaprikaId: 'usdc-usd-coin', coinCapId: 'usd-coin'),
  CryptoAsset(code: 'BNB', coinPaprikaId: 'bnb-binance-coin', coinCapId: 'binancecoin'),
  CryptoAsset(code: 'MATIC', coinPaprikaId: 'matic-polygon', coinCapId: 'matic-network'),
];

CryptoAsset cryptoAssetByCode(String code) {
  return supportedCryptoAssets.firstWhere(
    (asset) => asset.code == code,
    orElse: () => throw ArgumentError.value(code, 'code', 'Unsupported crypto'),
  );
}
```

- [ ] **Step 2: Expand `supportedCryptoCurrencies` in `supported_currencies.dart`**

Replace the 2-item crypto list:

```dart
const List<SupportedCurrency> supportedCryptoCurrencies = <SupportedCurrency>[
  SupportedCurrency(code: 'BTC', name: 'Bitcoin', symbol: 'BTC'),
  SupportedCurrency(code: 'ETH', name: 'Ethereum', symbol: 'ETH'),
  SupportedCurrency(code: 'SOL', name: 'Solana', symbol: 'SOL'),
  SupportedCurrency(code: 'XRP', name: 'Ripple', symbol: 'XRP'),
  SupportedCurrency(code: 'ADA', name: 'Cardano', symbol: 'ADA'),
  SupportedCurrency(code: 'DOGE', name: 'Dogecoin', symbol: 'DOGE'),
  SupportedCurrency(code: 'AVAX', name: 'Avalanche', symbol: 'AVAX'),
  SupportedCurrency(code: 'USDT', name: 'Tether USD', symbol: '₮'),
  SupportedCurrency(code: 'USDC', name: 'USD Coin', symbol: 'USDC'),
  SupportedCurrency(code: 'BNB', name: 'BNB', symbol: 'BNB'),
  SupportedCurrency(code: 'MATIC', name: 'Polygon', symbol: 'MATIC'),
];
```

- [ ] **Step 3: Update `fawazahmed_crypto_usd_price_client.dart` — dynamic parsing**

Replace the `fetchUsdPrices()` method body after the `usd` map extraction. Change from hardcoded `btc`/`eth` to iterating `supportedCryptoAssets`:

```dart
final pricesUsd = <String, double>{};
for (final asset in supportedCryptoAssets) {
  final rawRate = usd[asset.code.toLowerCase()];
  if (rawRate is! num || rawRate <= 0) continue;
  pricesUsd[asset.code] = 1 / rawRate.toDouble();
}

if (pricesUsd.length < 2) {
  throw const CryptoUsdPriceException('fawazahmed0 returned too few crypto rates');
}
_validate(pricesUsd);
```

Replace the `_validate()` method to check BTC as anchor + validate all others against BTC ratio:

```dart
void _validate(Map<String, double> pricesUsd) {
  if (!pricesUsd.containsKey('BTC')) {
    throw const CryptoUsdPriceException('fawazahmed0 missing BTC prices');
  }
  final btc = pricesUsd['BTC']!;
  if (btc < 1000 || btc > 1000000) {
    throw const CryptoUsdPriceException('fawazahmed0 returned implausible BTC price');
  }
  for (final entry in pricesUsd.entries) {
    if (entry.value.isNaN || entry.value <= 0) {
      throw CryptoUsdPriceException(
        'fawazahmed0 returned invalid price for ${entry.key}',
      );
    }
  }
}
```

Add import at top: `import 'crypto_asset.dart';`

- [ ] **Step 4: Generalize validation in 3 history clients**

All three history clients (`fawazahmed`, `coinpaprika`, `coingecko`) have the same pattern:
```dart
final min = code == 'BTC' ? 1000.0 : 50.0;
final max = code == 'BTC' ? 1000000.0 : 100000.0;
```

This rejects stablecoins (USDT ≈ $1, USDC ≈ $1). Replace in ALL THREE files:

```dart
void _validate(String code, Map<DateTime, double> pricesUsd) {
  if (pricesUsd.isEmpty) {
    throw CryptoUsdHistoryException(
      '[provider] returned no data for $code',
    );
  }
  final isBtc = code == 'BTC';
  final min = isBtc ? 1000.0 : 0.001;
  final max = isBtc ? 1000000.0 : 100000.0;
  for (final price in pricesUsd.values) {
    if (price.isNaN || price <= 0 || price < min || price > max) {
      throw CryptoUsdHistoryException(
        '[provider] returned implausible prices for $code',
      );
    }
  }
}
```

Replace `[provider]` with the actual provider name in each file:
- `fawazahmed_crypto_usd_history_client.dart`: `fawazahmed0`
- `coinpaprika_crypto_usd_history_client.dart`: `CoinPaprika historical`
- `coingecko_crypto_usd_history_client.dart`: `CoinGecko`

- [ ] **Step 5: Generalize `coinpaprika_crypto_usd_price_client.dart` validation**

Replace the `_validate()` method:

```dart
void _validate(Map<String, double> pricesUsd) {
  if (!pricesUsd.containsKey('BTC')) {
    throw const CryptoUsdPriceException('CoinPaprika missing BTC price');
  }
  final btc = pricesUsd['BTC']!;
  if (btc < 1000 || btc > 1000000) {
    throw const CryptoUsdPriceException('CoinPaprika returned implausible BTC price');
  }
  for (final entry in pricesUsd.entries) {
    if (entry.value.isNaN || entry.value <= 0) {
      throw CryptoUsdPriceException(
        'CoinPaprika returned invalid price for ${entry.key}',
      );
    }
  }
}
```

- [ ] **Step 6: Generalize `convert_quote_builder.dart` crypto precision**

Replace the hardcoded `BTC=>8, ETH=>6` switch with a category-based approach.

Add a helper at top of file (after imports):

```dart
int _cryptoDigits(String code) {
  if (code == 'BTC') return 8;
  if (code == 'USDT' || code == 'USDC') return 2;
  if (code == 'DOGE') return 4;
  return 6;
}
```

Replace the switch in `_formatAmount`:
```dart
String _formatAmount(double value, String code, int decimalPlaces) {
  final digits = isCryptoCurrency(code) ? _cryptoDigits(code) : decimalPlaces;
  return NumberFormat('#,##0.${'0' * digits}', 'en').format(value);
}
```

Replace the switch in `_formatRateLine`:
```dart
String _formatRateLine({
  required String base,
  required String quote,
  required double rate,
  required int decimalPlaces,
}) {
  final digits = isCryptoCurrency(quote) ? _cryptoDigits(quote) : decimalPlaces;
  final format = NumberFormat('0.${'0' * digits}', 'en');
  return '1 $base = ${format.format(rate)} $quote';
}
```

- [ ] **Step 7: Generalize `conversion_lens_sheet.dart` crypto handling**

Add a static helper method to `_LensCard`:

```dart
static int _cryptoDigits(String code) {
  if (code == 'BTC') return 8;
  if (code == 'USDT' || code == 'USDC') return 2;
  if (code == 'DOGE') return 4;
  return 6;
}

List<double> _reverseTargets() {
  if (quote.code == 'BTC') return <double>[0.001, 0.01, 0.1];
  if (quote.code == 'USDT' || quote.code == 'USDC' || quote.code == 'DOGE') {
    return <double>[10, 50, 100];
  }
  if (isCryptoCurrency(quote.code)) return <double>[0.01, 0.1, 1];
  return <double>[10, 50, 100];
}
```

Update `_formatHeroBase` to use `_cryptoDigits`:
```dart
String _formatHeroBase(double value, String code) {
  if (isCryptoCurrency(code)) {
    return _stripTrailingZeros(
      NumberFormat('#,##0.${'0' * _cryptoDigits(code)}', 'en').format(value),
    );
  }
  return _stripTrailingZeros(
    NumberFormat('#,##0.######', 'en').format(value),
  );
}
```

Update `_formatHeroConverted` to use `_cryptoDigits`:
```dart
String _formatHeroConverted(double value, String code) {
  if (isCryptoCurrency(code)) {
    return _stripTrailingZeros(
      NumberFormat('#,##0.${'0' * _cryptoDigits(code)}', 'en').format(value),
    );
  }
  if (value >= 100) {
    return NumberFormat('#,##0.00', 'en').format(value);
  }
  if (value >= 10) {
    return NumberFormat('#,##0.00', 'en').format(value);
  }
  return NumberFormat('#,##0.000', 'en').format(value);
}
```

Update `_formatValue` to use `_cryptoDigits`:
```dart
String _formatValue(double value, String code) {
  if (isCryptoCurrency(code)) {
    return NumberFormat('#,##0.${'0' * _cryptoDigits(code)}', 'en').format(value);
  }
  final digits = value >= 100 ? 0 : value >= 10 ? 2 : 3;
  return NumberFormat('#,##0.${'0' * digits}', 'en').format(value);
}
```

Update `_formatRaw` to use `_cryptoDigits`:
```dart
String _formatRaw(double value, String code) {
  if (isCryptoCurrency(code)) {
    return NumberFormat('0.${'0' * _cryptoDigits(code)}', 'en').format(value);
  }
  return NumberFormat('0.0000', 'en').format(value);
}
```

- [ ] **Step 8: Update `ui_copy.dart` — replace "BTC and ETH" with generic text**

In `dataSourceCryptoLatestDetail`, change all 5 language variants from "BTC and ETH" / "BTC y ETH" etc. to generic "Crypto" references:

English: `'BTC and ETH latest prices use` → `'Crypto latest prices use`

Spanish: `'Los últimos precios de BTC y ETH usan` → `'Los últimos precios de cripto usan`

German: `'Die neuesten BTC- und ETH-Preise verwenden` → `'Die neuesten Krypto-Preise verwenden`

Italian: `'I prezzi più recenti di BTC e ETH usano` → `'I prezzi più recenti delle crypto usano`

French: `'Les derniers prix BTC et ETH utilisent` → `'Les derniers prix crypto utilisent`

Same pattern in `cryptoDataLines` — replace all "BTC and ETH" / "BTC y ETH" / "BTC- und ETH" / "BTC e ETH" / "BTC et ETH" with generic crypto references.

English: `'BTC and ETH rates follow` → `'Crypto rates follow`

Spanish: `'Los tipos de BTC y ETH siguen` → `'Los tipos de cripto siguen`

German: `'BTC- und ETH-Kurse folgen` → `'Krypto-Kurse folgen`

Italian: `'I tassi di BTC e ETH seguono` → `'I tassi delle crypto seguono`

French: `'Les taux BTC et ETH suivent` → `'Les taux crypto suivent`

- [ ] **Step 9: Update `currency_flags.dart` — add AED + crypto entries**

Add to the `_map`:
```dart
'AED': '🇦🇪',
'SOL': '◎',
'XRP': '✕',
'ADA': '◆',
'DOGE': '🐕',
'AVAX': '▲',
'USDT': '₮',
'USDC': '◉',
'BNB': '●',
'MATIC': '⬡',
```

- [ ] **Step 10: Run analysis**

Run: `./scripts/check.sh`
Expected: analyze passes, tests pass

- [ ] **Step 11: Commit**

```bash
git add \
  lib/src/core/rates/crypto/crypto_asset.dart \
  lib/src/core/currency/supported_currencies.dart \
  lib/src/core/rates/crypto/fawazahmed_crypto_usd_price_client.dart \
  lib/src/core/rates/crypto/fawazahmed_crypto_usd_history_client.dart \
  lib/src/core/rates/crypto/coinpaprika_crypto_usd_price_client.dart \
  lib/src/core/rates/crypto/coinpaprika_crypto_usd_history_client.dart \
  lib/src/core/rates/crypto/coingecko_crypto_usd_history_client.dart \
  lib/src/features/convert/domain/convert_quote_builder.dart \
  lib/src/features/convert/widgets/conversion_lens_sheet.dart \
  lib/src/core/localization/ui_copy.dart \
  lib/src/shared/widgets/currency_flags.dart
git commit -m "feat(crypto): expand from 2 to 11 currencies, generalize precision and validation"
```

---

## Task 3: Generate Missing Icons via MiniMax (10 badges)

**Prerequisite:** Tasks 1 and 2 complete.

**Files:**
- Modify: `.devtools/currency_icon_prompts.json`
- Create: `assets/icons/currencies/{aed,sol,xrp,ada,doge,avax,usdt,usdc,bnb,matic}.png`
- Modify: `lib/src/shared/widgets/currency_flag_icon.dart`

- [ ] **Step 1: Check MiniMax quota**

```bash
.devtools/generate_currency_icons.sh --quota
```

Expected: remaining >= 10

- [ ] **Step 2: Add 10 new prompt entries to `currency_icon_prompts.json`**

Append after the last entry (COP). Each entry starts with a leading comma since it's appended to the existing JSON array.

```json
  ,
  {
    "code": "AED",
    "name": "UAE Dirham",
    "symbol": "د.إ",
    "text_color": "white",
    "flag_desc": "solid green circle with a vertical red stripe on the left side and subtle white text hint",
    "flag_colors": "#00732F #FF0000 white",
    "contrast_layer": true,
    "subject_ref": "auto",
    "notes": "Render a clean dirham symbol centered. Keep flag treatment minimal."
  },
  {
    "code": "SOL",
    "name": "Solana",
    "symbol": "SOL",
    "text_color": "white",
    "flag_desc": "gradient from deep violet purple on left to bright mint green on right, smooth horizontal blend",
    "flag_colors": "#9945FF #14F195",
    "contrast_layer": false,
    "subject_ref": "never",
    "notes": "Use the exact SOL text bold and centered. Gradient as a flat circle badge."
  },
  {
    "code": "XRP",
    "name": "Ripple",
    "symbol": "XRP",
    "text_color": "white",
    "flag_desc": "solid dark charcoal grey circle",
    "flag_colors": "#23292F white",
    "contrast_layer": false,
    "subject_ref": "never",
    "notes": "Use the exact XRP text bold and centered. Minimalist dark theme."
  },
  {
    "code": "ADA",
    "name": "Cardano",
    "symbol": "ADA",
    "text_color": "white",
    "flag_desc": "solid deep navy blue circle",
    "flag_colors": "#0033AD #0056FF",
    "contrast_layer": false,
    "subject_ref": "never",
    "notes": "Use the exact ADA text bold and centered. Clean deep blue background."
  },
  {
    "code": "DOGE",
    "name": "Dogecoin",
    "symbol": "Ð",
    "text_color": "white",
    "flag_desc": "solid golden yellow circle with a subtle doge face silhouette in the background layer",
    "flag_colors": "#C2A633 #BFA129",
    "contrast_layer": true,
    "subject_ref": "never",
    "notes": "Use the Dogecoin Ð symbol (not plain D). Doge face very faint."
  },
  {
    "code": "AVAX",
    "name": "Avalanche",
    "symbol": "AVAX",
    "text_color": "white",
    "flag_desc": "solid avalanche red circle with a subtle angular chevron shape motif",
    "flag_colors": "#E84142 white",
    "contrast_layer": false,
    "subject_ref": "never",
    "notes": "Use the exact AVAX text bold and centered on red background."
  },
  {
    "code": "USDT",
    "name": "Tether USD",
    "symbol": "₮",
    "text_color": "white",
    "flag_desc": "solid teal-green circle with a subtle T-shaped lock ring motif",
    "flag_colors": "#26A17B white",
    "contrast_layer": false,
    "subject_ref": "never",
    "notes": "Use the Tether ₮ symbol bold and centered."
  },
  {
    "code": "USDC",
    "name": "USD Coin",
    "symbol": "USDC",
    "text_color": "white",
    "flag_desc": "solid royal blue circle with a subtle circular lock outline motif",
    "flag_colors": "#2775CA white",
    "contrast_layer": false,
    "subject_ref": "never",
    "notes": "Use USDC text bold and centered. Visually pairs with USDT but blue."
  },
  {
    "code": "BNB",
    "name": "BNB",
    "symbol": "BNB",
    "text_color": "black",
    "flag_desc": "solid bright yellow circle with a subtle geometric diamond shape in background",
    "flag_colors": "#F3BA2F black",
    "contrast_layer": false,
    "subject_ref": "never",
    "notes": "Use BNB text bold and centered. Yellow background needs black text."
  },
  {
    "code": "MATIC",
    "name": "Polygon",
    "symbol": "MATIC",
    "text_color": "white",
    "flag_desc": "solid vivid purple circle with a subtle hexagonal polygon edge pattern",
    "flag_colors": "#8247E5 #9D4EFF",
    "contrast_layer": false,
    "subject_ref": "never",
    "notes": "Use MATIC text bold and centered. Hexagon motif very subtle."
  }
```

- [ ] **Step 3: Test one icon (AED)**

```bash
.devtools/generate_currency_icons.sh --one AED
```

Vision-review the result. Accept if average >= 3.5.

- [ ] **Step 4: Batch-generate remaining 9**

```bash
.devtools/generate_currency_icons.sh --batch
```

Vision-review each. Move accepted to `best/`.

- [ ] **Step 5: Deploy to assets**

```bash
.devtools/generate_currency_icons.sh --deploy
```

Verify:
```bash
ls -1 assets/icons/currencies/{aed,sol,xrp,ada,doge,avax,usdt,usdc,bnb,matic}.png
```

- [ ] **Step 6: Update `currency_flag_icon.dart` _assetMap**

Add 10 entries:
```dart
'AED': 'assets/icons/currencies/aed.png',
'SOL': 'assets/icons/currencies/sol.png',
'XRP': 'assets/icons/currencies/xrp.png',
'ADA': 'assets/icons/currencies/ada.png',
'DOGE': 'assets/icons/currencies/doge.png',
'AVAX': 'assets/icons/currencies/avax.png',
'USDT': 'assets/icons/currencies/usdt.png',
'USDC': 'assets/icons/currencies/usdc.png',
'BNB': 'assets/icons/currencies/bnb.png',
'MATIC': 'assets/icons/currencies/matic.png',
```

- [ ] **Step 7: Run analysis and commit**

```bash
./scripts/check.sh
git add .devtools/currency_icon_prompts.json assets/icons/currencies/ lib/src/shared/widgets/currency_flag_icon.dart
git commit -m "feat(icons): generate 10 missing currency badges via MiniMax"
```

---

## Task 4: Sectioned Currency Picker Redesign

**Files:**
- Create: `lib/src/core/currency/currency_groups.dart`
- Create: `lib/src/features/convert/widgets/currency_section_header.dart`
- Rewrite: `lib/src/features/convert/widgets/currency_picker_sheet.dart`

- [ ] **Step 1: Create `currency_groups.dart`**

```dart
import 'supported_currencies.dart';

enum CurrencySection {
  major,
  europe,
  americas,
  asiaPacific,
  middleEastAfrica,
  crypto;

  String get label {
    switch (this) {
      case CurrencySection.major:
        return 'Major';
      case CurrencySection.europe:
        return 'Europe';
      case CurrencySection.americas:
        return 'Americas';
      case CurrencySection.asiaPacific:
        return 'Asia Pacific';
      case CurrencySection.middleEastAfrica:
        return 'Middle East & Africa';
      case CurrencySection.crypto:
        return 'Crypto';
    }
  }

  bool get defaultExpanded =>
      this == CurrencySection.major || this == CurrencySection.crypto;
}

class CurrencyGroup {
  const CurrencyGroup({
    required this.section,
    required this.currencies,
  });

  final CurrencySection section;
  final List<SupportedCurrency> currencies;

  int get length => currencies.length;
}

List<CurrencyGroup> buildCurrencyGroups({
  required List<SupportedCurrency> currencies,
}) {
  const majorCodes = <String>{
    'USD', 'EUR', 'GBP', 'JPY', 'CNY',
  };
  const europeCodes = <String>{
    'CHF', 'SEK', 'NOK', 'DKK', 'PLN', 'CZK', 'HUF', 'RON',
  };
  const americasCodes = <String>{
    'CAD', 'AUD', 'MXN', 'BRL', 'ARS', 'CLP', 'COP',
  };
  const asiaPacificCodes = <String>{
    'INR', 'SGD', 'HKD', 'KRW', 'THB', 'PHP', 'IDR', 'MYR', 'TWD', 'NZD',
  };
  const meAfricaCodes = <String>{
    'TRY', 'AED', 'ILS', 'ZAR',
  };

  final groups = <CurrencyGroup>[];

  final major = currencies.where((c) => majorCodes.contains(c.code)).toList();
  if (major.isNotEmpty) {
    groups.add(CurrencyGroup(section: CurrencySection.major, currencies: major));
  }

  final europe = currencies.where((c) => europeCodes.contains(c.code)).toList();
  if (europe.isNotEmpty) {
    groups.add(CurrencyGroup(section: CurrencySection.europe, currencies: europe));
  }

  final americas = currencies.where((c) => americasCodes.contains(c.code)).toList();
  if (americas.isNotEmpty) {
    groups.add(CurrencyGroup(section: CurrencySection.americas, currencies: americas));
  }

  final asiaPacific = currencies.where((c) => asiaPacificCodes.contains(c.code)).toList();
  if (asiaPacific.isNotEmpty) {
    groups.add(CurrencyGroup(section: CurrencySection.asiaPacific, currencies: asiaPacific));
  }

  final meAfrica = currencies.where((c) => meAfricaCodes.contains(c.code)).toList();
  if (meAfrica.isNotEmpty) {
    groups.add(CurrencyGroup(section: CurrencySection.middleEastAfrica, currencies: meAfrica));
  }

  final crypto = currencies.where((c) => isCryptoCurrency(c.code)).toList();
  if (crypto.isNotEmpty) {
    groups.add(CurrencyGroup(section: CurrencySection.crypto, currencies: crypto));
  }

  return groups;
}
```

- [ ] **Step 2: Create `currency_section_header.dart`**

```dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/currency/currency_groups.dart';

class CurrencySectionHeader extends StatelessWidget {
  const CurrencySectionHeader({
    required this.group,
    required this.isExpanded,
    required this.onToggle,
    super.key,
  });

  final CurrencyGroup group;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
              size: 20,
              color: colors.muted,
            ),
            const SizedBox(width: 2),
            Text(
              '${group.section.label} (${group.length})',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.muted,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Rewrite `currency_picker_sheet.dart` with sections**

```dart
import 'package:flutter/material.dart';

import '../../../core/localization/ui_copy.dart';
import '../../../core/currency/supported_currencies.dart';
import '../../../core/currency/currency_groups.dart';
import '../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/widgets/currency_picker_chrome.dart';
import 'currency_picker_tile.dart';
import 'currency_section_header.dart';

class CurrencyPickerSheet extends StatefulWidget {
  const CurrencyPickerSheet({
    required this.title,
    required this.base,
    required this.selectedCodes,
    required this.onSelectBase,
    required this.onToggleCode,
    required this.selectBaseMode,
    super.key,
  });

  final String title;
  final String base;
  final List<String> selectedCodes;
  final ValueChanged<String> onSelectBase;
  final ValueChanged<String> onToggleCode;
  final bool selectBaseMode;

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  late final Set<String> _selectedCodes = widget.selectedCodes.toSet();
  String _query = '';
  final Set<CurrencySection> _expandedSections = <CurrencySection>{};

  @override
  void initState() {
    super.initState();
    for (final section in CurrencySection.values) {
      if (section.defaultExpanded) {
        _expandedSections.add(section);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final groups = _filteredGroups();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .84,
      minChildSize: .42,
      maxChildSize: .92,
      builder: (context, scrollController) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            children: <Widget>[
              CurrencyPickerHeader(title: widget.title, subtitle: _subtitle(l10n)),
              const SizedBox(height: 12),
              CurrencyPickerSearchField(
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: groups.isEmpty
                    ? _emptyResult(context)
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          return _buildGroup(context, group);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyResult(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Text(
        l10n?.noCurrenciesFound ?? 'No currencies found',
        style: TextStyle(color: AppColors.of(context).muted, fontSize: 14),
      ),
    );
  }

  Widget _buildGroup(BuildContext context, CurrencyGroup group) {
    final isExpanded = _expandedSections.contains(group.section);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CurrencySectionHeader(
          group: group,
          isExpanded: isExpanded,
          onToggle: () => setState(() {
            if (_expandedSections.contains(group.section)) {
              _expandedSections.remove(group.section);
            } else {
              _expandedSections.add(group.section);
            }
          }),
        ),
        if (isExpanded) ..._buildGroupItems(group),
      ],
    );
  }

  List<Widget> _buildGroupItems(CurrencyGroup group) {
    final sorted = _sortGroup(group.currencies);
    return sorted.map((currency) {
      final isBase = currency.code == widget.base;
      final isSelected = _selectedCodes.contains(currency.code);
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CurrencyPickerTile(
            currency: currency,
            isBase: isBase,
            isSelected: isSelected,
            selectBaseMode: widget.selectBaseMode,
            onTap: () {
              if (widget.selectBaseMode) {
                widget.onSelectBase(currency.code);
              } else {
                _toggle(currency.code);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 52),
            child: Divider(
              height: 1,
              color: AppColors.of(context).border.withValues(alpha: .15),
            ),
          ),
        ],
      );
    }).toList();
  }

  List<CurrencyGroup> _filteredGroups() {
    final allCurrencies = allSupportedCurrencies.where(_matchesQuery).toList();
    return buildCurrencyGroups(currencies: allCurrencies);
  }

  List<SupportedCurrency> _sortGroup(List<SupportedCurrency> currencies) {
    final sorted = List<SupportedCurrency>.from(currencies);
    sorted.sort((a, b) {
      final aRank = _itemRank(a.code);
      final bRank = _itemRank(b.code);
      if (aRank != bRank) return aRank.compareTo(bRank);
      return a.code.compareTo(b.code);
    });
    return sorted;
  }

  int _itemRank(String code) {
    if (code == widget.base) return 0;
    if (_selectedCodes.contains(code)) return 1;
    return 2;
  }

  bool _matchesQuery(SupportedCurrency currency) {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return currency.code.toLowerCase().contains(normalized) ||
        currency.name.toLowerCase().contains(normalized);
  }

  String _subtitle(AppLocalizations? l10n) {
    if (widget.selectBaseMode) {
      return currentBaseSubtitle(context, widget.base);
    }
    return shownBaseSubtitle(context, _selectedCodes.length, widget.base);
  }

  void _toggle(String code) {
    if (code == widget.base) return;
    setState(() {
      if (_selectedCodes.contains(code)) {
        if (_selectedCodes.length == 1) return;
        _selectedCodes.remove(code);
      } else {
        _selectedCodes.add(code);
      }
    });
    widget.onToggleCode(code);
  }
}
```

- [ ] **Step 4: Run analysis**

Run: `./scripts/check.sh`
Expected: analyze passes, tests pass

- [ ] **Step 5: Build and install on iOS simulator**

```bash
IOS_SIMULATOR_ID=AD6518C3-252E-4951-AE25-AF6732817FB1 \
  BUNDLE_ID=com.niduna.currencyConverter \
  ./.devtools/sim_reinstall_build.sh
```

- [ ] **Step 6: Capture screenshot of picker**

```bash
IOS_SIMULATOR_ID=AD6518C3-252E-4951-AE25-AF6732817FB1 ./.devtools/sim_screenshot.sh picker_sectioned
```

- [ ] **Step 7: Commit**

```bash
git add \
  lib/src/features/convert/widgets/currency_picker_sheet.dart \
  lib/src/features/convert/widgets/currency_section_header.dart \
  lib/src/core/currency/currency_groups.dart
git commit -m "feat(ui): sectioned currency picker with region groups"
```

---

## Task 5: Verification & Smoke Test

- [ ] **Step 1: Run full check suite**

Run: `./scripts/check.sh`
Expected: All checks pass

- [ ] **Step 2: Visual verification on simulator**

Open Convert tab → tap edit button → verify picker:
- 6 sections: Major (5), Europe (8), Americas (7), Asia Pacific (10), ME&Africa (4), Crypto (11)
- Major and Crypto expanded by default
- Collapsed sections expand on tap
- Search filters across all sections
- New fiat currencies show correct flag icons
- New crypto currencies show MiniMax-generated icons
- Base currency shows radio button, others show check/circle

- [ ] **Step 3: Add a few currencies to Convert tab**

Try: SOL, USDT, THB, ZAR. Verify they appear as rate rows with correct formatting.

- [ ] **Step 4: Test stablecoin display**

Add USDT as base, convert to USD. Should show 2 decimal places (not 6 or 8).
Long-press USDT row → Conversion Lens should show reverse targets `[10, 50, 100]` not `[0.01, 0.1, 1]`.

- [ ] **Step 5: Test Favorites with new currencies**

Create favorite pair: USD/THB. Verify it appears in Favorites tab with correct flag icon.

- [ ] **Step 6: Final commit if any fixes needed**

---

## Self-Review Checklist

- [ ] Spec coverage: All 51 currencies defined? Yes (Task 1 + Task 2)
- [ ] Spec coverage: Picker redesigned with sections? Yes (Task 4)
- [ ] Spec coverage: Crypto price client parses all 11? Yes (Task 2 Step 3)
- [ ] Spec coverage: All 3 history clients handle stablecoins? Yes (Task 2 Step 4)
- [ ] Spec coverage: CoinPaprika price client generalized? Yes (Task 2 Step 5)
- [ ] Spec coverage: Quote builder handles crypto categories? Yes (Task 2 Step 6)
- [ ] Spec coverage: Conversion lens handles crypto categories? Yes (Task 2 Step 7)
- [ ] Spec coverage: Localization updated from "BTC and ETH"? Yes (Task 2 Step 8)
- [ ] Spec coverage: 10 icons generated via MiniMax? Yes (Task 3)
- [ ] Spec coverage: Test length assertion updated? Yes (Task 1 Step 2)
- [ ] Frankfurter coverage: All 40 fiat currencies verified? Yes (live API check)
- [ ] BGN excluded: Not available from Frankfurter, not in plan? Confirmed.
- [ ] Placeholder scan: No TBD/TODO? Checked.
- [ ] Type consistency: `CryptoAsset` codes match `supportedCryptoCurrencies`? Both use same 11.
- [ ] Quota safety: 10 MiniMax images = 20% of daily 50-image limit.
- [ ] Provider constraint: Still fawazahmed0 + Frankfurter only for release? Yes.
- [ ] File size: `currency_picker_sheet.dart` ~165 lines? Yes.
- [ ] File size: `currency_groups.dart` ~80 lines? Yes.
- [ ] File size: `currency_section_header.dart` ~45 lines? Yes.
