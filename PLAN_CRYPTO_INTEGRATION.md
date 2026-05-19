# Executable Plan: No-Key Crypto Latest And Charts

> Last reviewed: 2026-05-19
> Purpose: make BTC/ETH latest rates and daily charts work with free providers
> that require no account and no API key, while preserving the app's
> privacy-first, no-backend posture and avoiding duplicate provider calls.

## Execution Status

- `DONE` Phase 0: product docs updated for the no-key Phase 1.x crypto scope
- `DONE` Phase 1: fiat/crypto catalog split and cache hygiene shipped
- `DONE` Phase 2: daily Convert refresh policy shipped
- `DONE` Phase 3: crypto provider clients and cache shipped
- `DONE` Phase 4: rate normalization and Convert integration shipped
- `DONE` Phase 5: Convert quote exposure and formatting shipped
- `PARTIAL` Phase 6: guardrails are effectively in place, but provider attribution
  and final manual UX verification remain
- `DONE` Phase 7: crypto historical charts up to 1 year shipped

## Read This First

This plan is intentionally self-contained so another agent can execute it in a
fresh conversation.

Before coding, read these repo files:

- `AGENTS.md`
- `DEFINITIONS.md`
- `ROADMAP.md`
- `PLAN.md`
- `agent/README.md`
- `lib/src/app.dart`
- `lib/src/core/currency/supported_currencies.dart`
- `lib/src/core/preferences/app_preferences.dart`
- `lib/src/core/rates/rates_client.dart`
- `lib/src/core/rates/rates_service.dart`
- `lib/src/core/rates/clients/frankfurter_client.dart`
- `lib/src/core/rates/cache/shared_preferences_rates_cache.dart`
- `lib/src/core/rates/models/rates_snapshot.dart`
- `lib/src/features/convert/data/latest_rates_repository.dart`
- `lib/src/features/convert/data/latest_rates_cache.dart`
- `lib/src/features/convert/data/frankfurter_latest_rates_client.dart`
- `lib/src/features/convert/domain/latest_rates_snapshot.dart`
- `lib/src/features/convert/presentation/convert_controller.dart`
- `lib/src/features/convert/presentation/convert_controller_loading.dart`
- `lib/src/features/convert/domain/convert_quote_builder.dart`
- `lib/src/features/charts/presentation/charts_controller.dart`

Relevant skills/guides for future agents:

- `.agent-local/skills/_shared/problem-shaping.SKILL.md`
- `.agent-local/skills/_shared/implementation-plan-writing.SKILL.md`
- `.agent-local/skills/_shared/app-architecture-bootstrap.SKILL.md`
- `.agent-local/skills/mobile/mobile-architecture-boundaries.SKILL.md`
- `.agent-local/skills/mobile/flutter/flutter-architecture-boundaries.SKILL.md`
- `.agent-local/skills/mobile/flutter/flutter-verification.SKILL.md`
- repo-local `.agent/skills/product-scope-check/SKILL.md`
- repo-local `.agent/skills/flutter-verification/SKILL.md`

If `.agent-local/skills` is missing, restore it first:

```bash
./agent/sync-shared-skills.sh
```

## Scope Gate

Scope decision is now explicit.

- `DEFINITIONS.md`, `ROADMAP.md`, and `PLAN.md` were updated to approve the
  constrained no-key Phase 1.x crypto slice.
- BTC/ETH latest rates in Convert are in scope.
- BTC/ETH and mixed fiat/crypto daily charts up to 1 year are in scope.
- No backend, no accounts, no tracking, and no embedded API keys remain hard
  constraints.

## Target

Add BTC and ETH latest conversion rates and daily charts using multiple free
no-key providers. The app must:

- make no backend calls
- require no user account
- require no provider API key
- add no analytics or tracking
- update crypto at most once per local day
- not call fallback providers after a primary provider succeeds
- preserve cached crypto rates when crypto refresh fails but fiat refresh succeeds
- keep Frankfurter as canonical fiat provider
- avoid asking Frankfurter for BTC or ETH
- support BTC/ETH chart pairs with daily history up to 1 year
- support mixed fiat/crypto chart pairs with daily history up to 1 year
- keep 2-year charts fiat-only

Non-goals for this no-key crypto scope:

- no metals
- no new top-level tab
- no backend/proxy
- no provider API key support
- no realtime/intraday crypto refresh
- no crypto charts beyond 1 year

## Current Architecture Facts

The app has two separate rates pipelines.

| Area | Convert tab | Charts tab |
|---|---|---|
| Controller | `ConvertController` | `ChartsController` |
| Repository/service | `LatestRatesRepository` | `RatesService` |
| Client | `FrankfurterLatestRatesClient` | `FrankfurterClient` |
| Snapshot | `LatestRatesSnapshot` | `RatesSnapshot`, `HistoricalSnapshot` |
| Cache | `LatestRatesCache` | `SharedPreferencesRatesCache` |
| Cache key | `latest_rates_$base` | `latest_rates_$base`, `historical_rates_${base}_$quote` |

Important code behavior:

- `ConvertControllerLoading.load()` now respects `refreshOnOpen` and same-day
  freshness.
- `RatesService.getLatestRates()` defaults to a 1-hour max age, not daily.
- `LatestRatesRepository.fetchLatest()` writes the fresh snapshot wholesale.
- `AppPreferences.clearAllCaches()` now removes latest, historical, and crypto
  cache keys.
- `currencyByCode()` now resolves fiat and crypto currencies.
- `FrankfurterClient` and `FrankfurterLatestRatesClient` must never build quote
  lists from a crypto-inclusive catalog.
- `RatesService._shouldFetchNewerGap()` currently assumes fiat weekend behavior.
  Crypto trades every day, so crypto historical routing needs crypto-aware gap
  logic.

## Provider Decision

### Use

Primary crypto provider: **CoinPaprika Free API**

- Base URL: `https://api.coinpaprika.com/v1/`
- No API key required for Free plan.
- Free plan limit documented as 20,000 calls/month.
- Latest endpoint for specific coins:
  - `GET /tickers/btc-bitcoin?quotes=USD,EUR,GBP`
  - `GET /tickers/eth-ethereum?quotes=USD,EUR,GBP`
- Response includes `symbol`, `last_updated`, and `quotes.<CODE>.price`.

Fallback provider: **fawazahmed0/exchange-api**

- CDN URL: `https://cdn.jsdelivr.net/npm/@fawazahmed0/currency-api@latest/v1/currencies/usd.json`
- Cloudflare fallback URL: `https://latest.currency-api.pages.dev/v1/currencies/usd.json`
- No API key.
- No provider rate limit advertised.
- Daily static JSON.
- CC0 license.
- Response uses lowercase currency codes.
- Example: `usd.btc` means BTC per 1 USD; `usd.eur` means EUR per 1 USD.

Historical chart provider: **CoinPaprika historical ticks**

- Endpoint: `GET /tickers/{coin_id}/historical?start=YYYY-MM-DD&end=YYYY-MM-DD&interval=1d`
- No API key required on free plan.
- Free plan supports daily history for the last 1 year.
- Free plan hourly history is only suitable for the last 1 day and is out of
  scope here.
- `quote=usd` works and should be the canonical historical quote for the app.

Optional BTC-only fallback: **Blockchain.com ticker**

- Endpoint: `https://blockchain.info/ticker`
- No API key.
- BTC only.
- Use only if BTC fallback is useful without ETH.

### Do Not Use For No-Key Phase

CoinCap must not be primary for this plan. Current CoinCap 3.0 docs point to
`rest.coincap.io`, and no-key requests return `401`. Treat CoinCap as an
optional future provider only if the app later accepts account/API-key setup.

CoinGecko must not be used in this no-key phase because its stable Demo API
requires an account/API key.

## Rate Semantics

The app snapshot contract is:

```text
snapshot.rates[quote] = amount of quote currency for 1 unit of snapshot.base
```

This is enforced in `convert_quote_builder.dart`:

```dart
amount * snapshot.rates[currency.code]
```

Never merge provider crypto prices directly without normalizing them to this
contract.

## Conversion Math

Use USD as the canonical cross-rate layer for crypto. Store crypto prices as:

```text
cryptoUsdPrice[BTC] = USD per 1 BTC
cryptoUsdPrice[ETH] = USD per 1 ETH
```

Use fiat rates as:

```text
usdToFiat[EUR] = EUR per 1 USD
baseToUsd = USD per 1 base fiat
```

Formulas:

```text
fiat base -> fiat quote:
  from Frankfurter snapshot directly

fiat base -> crypto quote:
  rates[crypto] = baseToUsd / cryptoUsdPrice[crypto]

crypto base -> fiat quote:
  rates[fiat] = cryptoUsdPrice[baseCrypto] * usdToFiat[fiat]

crypto base -> crypto quote:
  rates[quoteCrypto] = cryptoUsdPrice[baseCrypto] / cryptoUsdPrice[quoteCrypto]
```

Examples:

```text
1 EUR -> BTC:
  baseToUsd = 1.16
  BTC = 76920 USD
  rates[BTC] = 1.16 / 76920 = 0.00001508 BTC

1 BTC -> EUR:
  BTC = 76920 USD
  usdToEur = 0.862
  rates[EUR] = 76920 * 0.862 = 66294. + EUR

1 BTC -> ETH:
  BTC = 76920 USD
  ETH = 2116 USD
  rates[ETH] = 76920 / 2116 = 36.35 ETH

1 ETH -> GBP:
  ETH = 2116 USD
  usdToGbp = 0.75
  rates[GBP] = 2116 * 0.75 = 1587 GBP
```

## Historical Chart Math

Use the same USD canonical layer for charts. Compose daily pair values per date.

```text
crypto/crypto:
  rate[date] = baseCryptoUsd[date] / quoteCryptoUsd[date]

fiat/crypto:
  rate[date] = fiatToUsd[date] / quoteCryptoUsd[date]

crypto/fiat:
  rate[date] = baseCryptoUsd[date] * usdToFiat[date]

fiat/fiat:
  existing Frankfurter path
```

Weekend and holiday policy for mixed fiat/crypto pairs:

- crypto trades daily
- fiat closes on business days only
- for mixed fiat/crypto charts, carry forward the last available fiat close to
  the next missing weekend or holiday date

Example:

```text
EUR -> BTC on Saturday:
  eurToUsd[Saturday] = eurToUsd[Friday] carry-forward
  btcUsd[Saturday] = live historical crypto value for Saturday
  eurToBtc[Saturday] = eurToUsd[Saturday] / btcUsd[Saturday]
```

## Cache And Refresh Policy

### Product Rule

Latest fiat and crypto data refresh at most once per local day unless the user
manually clears cache. Provider update frequency does not matter.

### Required Code Change

Convert currently refreshes every app open. Fix this before adding crypto.

Implement a shared daily freshness helper, for example:

```text
lib/src/core/rates/rate_refresh_policy.dart
```

Rules:

- Fresh if `savedAt` is on the same local calendar day.
- Stale if local date changed.
- Optional safety: stale if older than 24 hours even if device date is odd.

Use it in Convert so `fetchLatest()` does not hit the network when cached data
is fresh for today.

Respect `AppPreferences.refreshOnOpen`:

- if false and cache exists: return cache, do not refresh on app open
- if true and cache is stale: refresh
- if no cache: fetch

### Cache Keys

Keep existing final snapshot keys:

- `latest_rates_USD`
- `latest_rates_EUR`
- etc.

Add one source cache for crypto canonical prices:

- `crypto_usd_prices_v1`

Suggested JSON:

```json
{
  "provider": "coinpaprika",
  "savedAt": "2026-05-19T10:00:00.000",
  "pricesUsd": {
    "BTC": 76920.0,
    "ETH": 2116.0
  }
}
```

Do not store provider-specific raw payloads as the primary app cache. Normalize
once, cache normalized USD prices, then compose app snapshots.

### Partial Failure Rule

Never overwrite a complete fiat+crypto cached snapshot with a fiat-only snapshot
just because crypto providers failed.

If fiat refresh succeeds and crypto refresh fails:

- read existing `crypto_usd_prices_v1`
- if it is fresh for today, use it
- else read existing final `latest_rates_$base`
- preserve existing BTC/ETH rates only if the final snapshot is fresh enough for
  the product rule
- if no acceptable cached crypto exists, return fiat-only but do not delete the
  crypto source cache

Also fix Settings cache clearing:

- `AppPreferences.clearAllCaches()` must remove `latest_rates_` and
  `crypto_usd_prices_` keys in addition to existing prefixes.

## Architecture

Follow feature-first boundaries. Put reusable provider and rate-normalization
logic in `core/rates`; keep Convert-specific repository behavior in
`features/convert/data`.

### Currency Catalog

Modify `lib/src/core/currency/supported_currencies.dart` carefully.

Recommended shape:

```dart
const List<SupportedCurrency> supportedFiatCurrencies = <SupportedCurrency>[
  // current 16 fiat currencies
];

const List<SupportedCurrency> supportedCryptoCurrencies = <SupportedCurrency>[
  SupportedCurrency(code: 'BTC', name: 'Bitcoin', symbol: 'BTC'),
  SupportedCurrency(code: 'ETH', name: 'Ethereum', symbol: 'ETH'),
];

const List<SupportedCurrency> supportedCurrencies = supportedFiatCurrencies;

List<SupportedCurrency> get allSupportedCurrencies => <SupportedCurrency>[
  ...supportedFiatCurrencies,
  ...supportedCryptoCurrencies,
];

bool isFiatCurrency(String code) => supportedFiatCurrencies.any(...);
bool isCryptoCurrency(String code) => supportedCryptoCurrencies.any(...);

SupportedCurrency currencyByCode(String code) {
  return allSupportedCurrencies.firstWhere(...);
}
```

Then update Frankfurter clients to use `supportedFiatCurrencies`, not
`supportedCurrencies`.

### New Core Files

Create small files. Keep each under repo size rules.

```text
lib/src/core/rates/rate_refresh_policy.dart
lib/src/core/rates/crypto/crypto_asset.dart
lib/src/core/rates/crypto/crypto_usd_price_snapshot.dart
lib/src/core/rates/crypto/crypto_usd_price_client.dart
lib/src/core/rates/crypto/coinpaprika_crypto_usd_price_client.dart
lib/src/core/rates/crypto/fawazahmed_crypto_usd_price_client.dart
lib/src/core/rates/crypto/fallback_crypto_usd_price_client.dart
lib/src/core/rates/crypto/crypto_usd_price_cache.dart
lib/src/core/rates/crypto/rate_normalizer.dart
```

`CryptoUsdPriceClient` should return normalized USD prices:

```dart
abstract class CryptoUsdPriceClient {
  Future<CryptoUsdPriceSnapshot> fetchUsdPrices();
}
```

`FallbackCryptoUsdPriceClient` should:

- call CoinPaprika first
- if CoinPaprika succeeds with all required assets, stop
- if CoinPaprika fails, call fawazahmed0 CDN
- if CDN fails, call Cloudflare fallback
- never call fallback providers after primary success
- use 10 second timeout per provider
- reject malformed, zero, negative, NaN, or implausible prices

Suggested sanity ranges for MVP:

```text
BTC/USD: 1,000 to 1,000,000
ETH/USD: 50 to 100,000
BTC/ETH ratio: 1 to 200
```

### Convert Pipeline

Add:

```text
lib/src/features/convert/data/latest_rates_client.dart
lib/src/features/convert/data/multi_provider_latest_rates_repository.dart
```

Make `FrankfurterLatestRatesClient` implement `LatestRatesClient`.

Prefer a repository-level coordinator over a thin composite client, because cache
freshness, `refreshOnOpen`, partial failure, in-flight request de-duplication,
and cache preservation are repository concerns.

`MultiProviderLatestRatesRepository implements ConvertRatesRepository` should:

- use `LatestRatesCache` for final app snapshots
- use `CryptoUsdPriceCache` for canonical crypto USD prices
- use `FrankfurterLatestRatesClient` for fiat latest rates
- use `FallbackCryptoUsdPriceClient` for crypto USD prices
- use `RateNormalizer` to compose the final `LatestRatesSnapshot`
- maintain an `_inFlightByBase` map so concurrent calls for the same base share
  one request
- return cached snapshot without network when daily-fresh
- handle fiat base and crypto base separately

Behavior by base type:

```text
Base is fiat:
  1. Read final latest_rates_$base.
  2. If fresh today, return it.
  3. Fetch Frankfurter for that fiat base.
  4. Get crypto USD prices from crypto cache if fresh, otherwise provider chain.
  5. Normalize and merge fiat + crypto quotes.
  6. Write final latest_rates_$base.

Base is crypto:
  1. Read final latest_rates_$base.
  2. If fresh today, return it.
  3. Get crypto USD prices from crypto cache if fresh, otherwise provider chain.
  4. Fetch Frankfurter USD base once for fiat quote rates.
  5. Normalize crypto base to fiat and crypto quotes.
  6. Write final latest_rates_$base.
```

If this first slice should not allow crypto as a base, explicitly block crypto in
base pickers and only show BTC/ETH as quote rows. Do not leave crypto base
half-supported.

### Charts Pipeline

Crypto charts are allowed in a constrained first slice.

Validated facts:

- CoinPaprika historical ticks free plan supports daily history for the last 1
  year, not 2 years.
- CoinPaprika historical OHLC free plan only gives the last 24 hours.
- fawazahmed0 supports historical by date URL, but not range queries; 2 years
  would require hundreds of daily requests per pair, which violates the app's
  "calls justas" goal.
- CoinCap is not acceptable for no-key phase.

Therefore:

- keep fiat pairs unchanged up to 2 years
- allow BTC/ETH chart pairs up to 1 year
- allow mixed fiat/crypto chart pairs up to 1 year
- disable 2-year range whenever a chart pair includes crypto
- implement pair-type routing:
  - fiat/fiat: existing Frankfurter path
  - crypto/fiat: crypto USD history + same-day USD/fiat history
  - fiat/crypto: fiat/USD history + crypto USD history
  - crypto/crypto: baseCrypto/USD divided by quoteCrypto/USD per date

Also note: `RatesService._shouldFetchNewerGap()` assumes fiat weekend behavior.
Crypto trades every day, so crypto historical needs a crypto-aware gap policy.

## UI Surface To Update

Files that currently assume fiat-only and must be handled intentionally:

- `lib/src/features/convert/widgets/currency_picker_sheet.dart`
- `lib/src/features/settings/widgets/base_currency_picker.dart`
- `lib/src/features/charts/widgets/chart_currency_picker_sheet.dart`
- `lib/src/features/charts/widgets/pair_selector.dart`
- `lib/src/features/charts/widgets/chart_header.dart`
- `lib/src/features/convert/widgets/amount_base_button.dart`
- `lib/src/features/convert/widgets/amount_input_sheet.dart`
- `lib/src/features/settings/widgets/base_currency_tile.dart`
- `lib/src/features/convert/domain/convert_quote_builder.dart`
- `lib/src/core/preferences/app_preferences.dart`
- `lib/src/shared/widgets/currency_flag_icon.dart`

First-slice UI decision:

- Convert picker may show BTC/ETH as quote currencies.
- Settings default base picker should either support BTC/ETH fully or keep it
  fiat-only. Prefer keeping Settings default base fiat-only in first slice to
  reduce risk.
- Charts picker should include BTC/ETH once crypto historical routing ships.

Formatting:

- Keep user decimal preference for fiat.
- Add per-currency display precision for crypto in `convert_quote_builder.dart`.
- Do not expand the global Settings decimal preference beyond 6 yet.

Suggested display precision:

```text
BTC quote amount: up to 8 decimals
ETH quote amount: up to 6 decimals
fiat quote amount: user preference
rate line for very small rates: significant digits, not fixed 2 decimals
```

Freshness labels:

- Fiat-only rows can keep ECB language.
- When crypto rows are visible, show app-level language such as
  `Rates refresh once daily` instead of implying ECB crypto updates.

## Implementation Phases

### Phase 0 - Product Scope And Safety Gate

Status: `DONE`

Files:

- `DEFINITIONS.md`
- `ROADMAP.md`
- `PLAN.md`
- `PLAN_CRYPTO_INTEGRATION.md`

Tasks:

1. Decide whether direct no-key crypto latest rates are allowed before backend.
2. Update product docs if approved.
3. Keep explicit non-goals: no metals, no API keys, no backend.

Verification:

- Product docs no longer contradict the implementation slice.

Current state:

- Root docs now align with the implemented no-key Phase 1.x crypto scope.
- The scope gate is no longer blocking implementation.

Stop condition:

- If crypto remains out of scope, do not code.

### Phase 1 - Currency Catalog And Cache Hygiene

Status: `DONE`

Files:

- `lib/src/core/currency/supported_currencies.dart`
- `lib/src/core/preferences/app_preferences.dart`
- tests for preferences/cache clearing if present

Tasks:

1. Add fiat/crypto catalog split and helpers.
2. Make `currencyByCode()` find both fiat and crypto.
3. Keep Frankfurter quote lists fiat-only.
4. Fix `clearAllCaches()` to remove `latest_rates_` and `crypto_usd_prices_`.

Verification:

- `./scripts/check.sh`
- Unit test or focused test that cache clear removes `latest_rates_USD`.

Completed:

- Added `supportedFiatCurrencies`, `supportedCryptoCurrencies`,
  `allSupportedCurrencies`, `isFiatCurrency()`, and `isCryptoCurrency()`.
- Updated `currencyByCode()` to resolve fiat and crypto.
- Kept Frankfurter request lists fiat-only.
- Fixed `clearAllCaches()` to remove `latest_rates_` and `crypto_usd_prices_`.

Stop condition:

- If changing `currencyByCode()` breaks existing fiat UI tests, fix catalog
  consumers before continuing.

### Phase 2 - Daily Refresh Policy For Convert

Status: `DONE`

Files:

- `lib/src/core/rates/rate_refresh_policy.dart`
- `lib/src/features/convert/domain/latest_rates_snapshot.dart`
- `lib/src/features/convert/data/latest_rates_repository.dart`
- `lib/src/features/convert/presentation/convert_controller_loading.dart`

Tasks:

1. Add daily freshness helper.
2. Make Convert avoid network when cache is fresh for today.
3. Respect `AppPreferences.refreshOnOpen`.
4. Add in-flight de-duplication for same-base latest requests.

Verification:

- Test: cached same-day snapshot returns without client call.
- Test: stale previous-day snapshot triggers one client call.
- Test: `refreshOnOpen=false` returns cache without client call.
- `./scripts/check.sh`

Completed:

- Added `lib/src/core/rates/rate_refresh_policy.dart`.
- `ConvertControllerLoading.load()` now respects `refreshOnOpen` and same-day
  freshness.
- Convert no longer refreshes on every app open.
- In-flight de-duplication was implemented in the multi-provider repository.

### Phase 3 - Crypto Provider Clients

Status: `DONE`

Files:

- `lib/src/core/rates/crypto/crypto_asset.dart`
- `lib/src/core/rates/crypto/crypto_usd_price_snapshot.dart`
- `lib/src/core/rates/crypto/crypto_usd_price_client.dart`
- `lib/src/core/rates/crypto/coinpaprika_crypto_usd_price_client.dart`
- `lib/src/core/rates/crypto/fawazahmed_crypto_usd_price_client.dart`
- `lib/src/core/rates/crypto/fallback_crypto_usd_price_client.dart`
- `lib/src/core/rates/crypto/crypto_usd_price_cache.dart`

Tasks:

1. Implement CoinPaprika client with exact coin IDs:
   - BTC: `btc-bitcoin`
   - ETH: `eth-ethereum`
2. Implement fawazahmed0 fallback from USD endpoint.
3. Implement CDN then Cloudflare fallback for fawazahmed0.
4. Add sanity checks.
5. Cache normalized USD prices once per local day.

Verification:

- Test CoinPaprika JSON parsing.
- Test fawazahmed0 lowercase-code parsing.
- Test fallback does not call fawazahmed0 after CoinPaprika success.
- Test malformed/zero/implausible prices are rejected.
- `./scripts/check.sh`

Completed:

- Added CoinPaprika BTC/ETH client.
- Added fawazahmed0 CDN + Cloudflare fallback client.
- Added fallback coordinator and normalized USD crypto cache.
- Added sanity checks for malformed and implausible prices.

### Phase 4 - Latest Rate Normalization And Convert Integration

Status: `DONE`

Files:

- `lib/src/core/rates/crypto/rate_normalizer.dart`
- `lib/src/features/convert/data/latest_rates_client.dart`
- `lib/src/features/convert/data/frankfurter_latest_rates_client.dart`
- `lib/src/features/convert/data/multi_provider_latest_rates_repository.dart`
- `lib/src/features/convert/data/latest_rates_repository.dart`
- `lib/src/app.dart`

Tasks:

1. Extract `LatestRatesClient` interface.
2. Make `FrankfurterLatestRatesClient` implement it.
3. Build `RateNormalizer` for all pair types.
4. Build `MultiProviderLatestRatesRepository`.
5. Wire the new repository in `app.dart`.
6. Ensure existing test injection via `CurrencyConverterApp(convertRepository:)`
   still works.

Verification:

- Unit tests for formulas:
  - EUR -> BTC
  - BTC -> EUR
  - BTC -> ETH
  - ETH -> GBP
- Test fiat refresh + crypto failure preserves cached crypto.
- Test first install with crypto failure still returns fiat-only without crash.
- Test no duplicate provider calls for same base during concurrent loads.
- `./scripts/check.sh`

Completed:

- Extracted `LatestRatesClient`.
- Made `FrankfurterLatestRatesClient` implement it.
- Added `RateNormalizer` using USD cross-rate math.
- Added `MultiProviderLatestRatesRepository` with cache preservation and
  in-flight request sharing.
- Wired the repository in `lib/src/app.dart`.

Intentional first-slice behavior:

- Crypto base is blocked in repository and UI for now.
- BTC/ETH are quote-only in Convert.

### Phase 5 - Convert UI Exposure And Formatting

Status: `DONE`

Files:

- `lib/src/features/convert/widgets/currency_picker_sheet.dart`
- `lib/src/features/convert/domain/convert_quote_builder.dart`
- `lib/src/features/convert/presentation/convert_controller.dart`
- `lib/src/features/convert/presentation/convert_controller_editing.dart`
- `lib/src/features/convert/widgets/amount_base_button.dart`
- `lib/src/features/convert/widgets/amount_input_sheet.dart`
- `lib/src/shared/widgets/currency_flag_icon.dart`

Tasks:

1. Show BTC/ETH in Convert quote picker.
2. Decide whether Convert base picker allows BTC/ETH in this slice.
3. If crypto base is not supported yet, block it in UI and code.
4. Add per-currency formatting for quote amount and rate line.
5. Keep favorite toggles local-only.

Verification:

- Manual: USD base shows BTC/ETH rows when selected.
- Manual: EUR -> BTC amount is small and not rounded to zero.
- Manual: offline mode still shows cached crypto rows.
- `./scripts/check.sh`

Completed:

- `CurrencyPickerSheet` now shows `allSupportedCurrencies` in quote-selection
  mode and `supportedFiatCurrencies` in base-selection mode.
- `convert_quote_builder.dart` now formats crypto with higher precision.
- Base picker remains fiat-only by design in this slice.

Important UI note:

- There is currently no direct "change this row into BTC/ETH" action on an
  existing rate row.
- BTC/ETH are exposed through `Convert -> Add -> Visible currencies`, not
  through the base picker.
- If the quote picker still shows only fiat currencies in runtime, treat that as
  a bug and verify the exact interaction path.

### Phase 6 - Settings And Charts Guardrails

Status: `DONE`

Files:

- `lib/src/features/settings/widgets/base_currency_picker.dart`
- `lib/src/features/settings/widgets/base_currency_tile.dart`
- `lib/src/features/charts/widgets/chart_currency_picker_sheet.dart`
- `lib/src/features/charts/widgets/pair_selector.dart`
- `lib/src/features/charts/widgets/chart_header.dart`

Tasks:

1. Keep Settings default base fiat-only unless crypto base is fully implemented.
2. Keep Charts picker stable with BTC/ETH and crypto-aware range gating.
3. Add provider attribution in Settings/About if required by provider terms.

Verification:

- Manual: Settings base picker does not offer unsupported crypto base.
- Manual: Charts picker remains stable with BTC/ETH exposed.
- `./scripts/check.sh`

Current state:

- Settings default base remains fiat-only, which matches the first-slice plan.
- Charts picker now exposes BTC/ETH and works with crypto-aware range gating.
- Provider attribution is now exposed through `Settings -> About -> Data sources`.
- Manual UX verification across picker paths and offline/cache behavior passed.

### Phase 7 - Crypto Charts Up To 1 Year

Status: `DONE`

Files:

- `lib/src/core/rates/crypto/crypto_usd_history_snapshot.dart`
- `lib/src/core/rates/crypto/crypto_usd_history_client.dart`
- `lib/src/core/rates/crypto/coinpaprika_crypto_usd_history_client.dart`
- `lib/src/core/rates/crypto/crypto_usd_history_cache.dart`
- `lib/src/core/rates/crypto/historical_rate_composer.dart`
- `lib/src/core/rates/multi_provider_rates_client.dart`
- `lib/src/core/rates/rates_service.dart`
- `lib/src/features/charts/domain/chart_range.dart`
- `lib/src/features/charts/presentation/charts_controller.dart`
- `lib/src/features/charts/widgets/chart_currency_picker_sheet.dart`
- `lib/src/features/charts/widgets/pair_selector.dart`
- `lib/src/features/charts/widgets/range_selector.dart`

Tasks:

1. Add a crypto USD historical client backed by CoinPaprika daily historical
   ticks.
2. Cache source crypto USD history by asset and date span.
3. Add a historical composer for crypto/crypto, fiat/crypto, and crypto/fiat.
4. Add a multi-provider historical routing client for Charts.
5. Carry forward missing fiat dates for mixed fiat/crypto weekend and holiday
   continuity.
6. Keep fiat-only charts on the current Frankfurter path.
7. Disable `2Y` whenever a selected chart pair includes crypto.
8. Auto-fallback `2Y` to `1Y` when the user switches into a crypto-involved
   pair.
9. Expose BTC/ETH in the Charts pair picker.

Verification:

- Manual: `BTC -> ETH` loads for `1W`, `1M`, `3M`, `6M`, `1Y`.
- Manual: `EUR -> BTC` loads for `1W`, `1M`, `3M`, `6M`, `1Y`.
- Manual: fiat `2Y` still works.
- Manual: crypto pair makes `2Y` unavailable.
- Manual: offline chart cache still works after one successful fetch.
- `./scripts/check.sh`

Acceptance criteria:

- BTC/ETH and mixed fiat/crypto charts work with no backend and no API key.
- 2-year charts remain fiat-only.
- Frankfurter is never called with BTC or ETH.
- CoinPaprika historical is not replaced with per-day fallback calls.
- Mixed fiat/crypto weekend continuity is stable and predictable.

Completed:

- Added CoinPaprika USD historical client and crypto USD history cache.
- Added historical composition for crypto/crypto, fiat/crypto, and
  crypto/fiat.
- Added multi-provider historical routing for Charts.
- Added weekend and holiday carry-forward for mixed fiat/crypto pairs.
- Kept fiat-only charts on the Frankfurter path.
- Disabled `2Y` for crypto-involved pairs and auto-fallback to `1Y`.
- Exposed BTC/ETH in the Charts pair picker.
- Added chart tests covering parsing, composition, range fallback, and crypto
  weekend gap fetching.

Stop condition:

- If product requires crypto history beyond 1 year, do not extend this no-key
  path without a new product and provider decision.

## Testing Matrix

Unit tests:

- `RateRefreshPolicy` same-day and previous-day behavior.
- Convert repository returns cache without network when fresh.
- Convert repository respects `refreshOnOpen=false`.
- Cache clear removes `latest_rates_` and `crypto_usd_prices_`.
- CoinPaprika parses BTC/ETH response.
- fawazahmed0 parses lowercase `usd.btc` and `usd.eth`.
- Provider fallback order and short-circuiting.
- Provider timeout fallback.
- Provider sanity rejection.
- Normalizer formulas for fiat/crypto and crypto/fiat pairs.
- Partial crypto failure preserves cached crypto.
- First-run crypto failure returns fiat-only without crash.
- CoinPaprika historical daily parsing works for BTC and ETH.
- Historical composer formulas work for `BTC -> ETH`, `ETH -> BTC`,
  `EUR -> BTC`, and `BTC -> EUR`.
- Mixed fiat/crypto weekend carry-forward is deterministic.
- Crypto-involved chart pairs disable `2Y`.
- Selecting a crypto pair while `2Y` is active falls back to `1Y`.

Manual tests:

- Fresh install online: fiat rows still load.
- Select BTC/ETH as quote rows in Convert.
- Relaunch app same day: no network refresh for latest rates.
- Turn off `refreshOnOpen`: cache is used without refresh.
- Airplane mode with cache: fiat and crypto cached rows show stale/offline state.
- Airplane mode without cache: no-cache state still works.
- Clear cache in Settings: latest and crypto caches are removed.
- Charts still work for fiat pairs.
- `BTC -> ETH` and `EUR -> BTC` load in Charts.
- Charts do not expose unsupported crypto ranges beyond `1Y`.

Verification command:

```bash
./scripts/check.sh
```

If Flutter is not on `PATH`:

```bash
FLUTTER_BIN=/path/to/flutter ./scripts/check.sh
```

## Final Acceptance Criteria

- BTC and ETH can be displayed in Convert latest rates.
- No provider API key or account is required.
- Frankfurter is never called with BTC or ETH.
- CoinPaprika is not called more than needed for one daily crypto refresh.
- fawazahmed0 is not called when CoinPaprika succeeds.
- Cached crypto survives a temporary crypto provider outage.
- Convert no longer refreshes every app open when cache is fresh for today.
- Settings clear cache actually clears latest-rate cache.
- BTC/ETH and mixed fiat/crypto charts work up to `1Y`.
- 2-year charts remain fiat-only.
- `./scripts/check.sh` passes.
