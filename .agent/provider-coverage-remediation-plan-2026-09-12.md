# Provider coverage remediation — executable handoff plan

> **Created:** 2026-09-12
>
> **Status:** approved investigation; implementation not started
>
> **Priority:** P0 before Closed testing
>
> **Target candidate after implementation:** `1.0.0+5` or the next unused
> version code, but only after local and device acceptance
>
> **Audience:** an implementation agent starting with no conversation context

## 1. Mission

Repair two release-blocking currency-coverage defects without redesigning the
app or changing its provider strategy:

1. Fiat conversion works for all 34 advertised currencies, but historical
   charts and previous-day trend badges still use Frankfurter v1. Five supported
   fiat currencies are absent from that legacy dataset, so charts involving
   them fail even though Convert works.
2. The app still advertises Polygon as `MATIC`, while the release-safe crypto
   provider now exposes Polygon as `POL`. Latest rates and charts for Polygon
   therefore have no data.

The required outcome is one internally tested Android candidate in which:

- every supported fiat code uses Frankfurter v2 for latest, previous-day and
  historical data;
- Polygon is represented consistently as `POL` in the catalog, providers,
  persisted user state, icon and active product documentation;
- upgrades from the existing `1.0.0+4` Internal build cannot crash because
  local state still contains `MATIC`;
- normal unit/widget tests stay deterministic and do not call the network;
- live provider coverage is verified separately before the version bump;
- no release is promoted to Closed or Production without Luis's explicit
  approval.

This is a provider/catalog correctness task. It is not a general UI refresh.

## 2. Required orientation for a fresh agent

Before editing anything:

1. Confirm the repository root and current branch:

   ```bash
   pwd
   git branch --show-current
   git status --short
   git log -5 --oneline --decorate
   ```

2. Read, in this order:

   - when this checkout is inside the Honest Fern monorepo, read
     `../../AGENTS.md`, `../../README.md` and
     `../../docs/strategy/Honest_Fern_First_Play_Release_Context.md`
   - `AGENTS.md`
   - `AGENTS.local.md` if present; do not print or copy credential values
   - `RELEASE_CHECKLIST.md`, starting with **Latest operational truth**
   - `.agent/release-next-steps.md`
   - this plan in full
   - `DEFINITIONS.md`
   - `DESIGN.md` only before changing the POL badge asset
   - `.agent/ICON_GENERATION_KNOWLEDGE.md` and
     `.agent/skills/icon-generation/SKILL.md` before generating or editing that
     badge

3. Treat `main` as canonical. At plan creation, `HEAD` and `origin/main` are
   `727b518` and the worktree is clean. Recheck rather than assuming this is
   still current.

4. Preserve all unrelated user changes. If the worktree is dirty, identify
   ownership and overlap before editing.

5. Run the baseline before implementation:

   ```bash
   ./scripts/check.sh
   git diff --check
   ```

   At the last accepted candidate, `./scripts/check.sh` passed with 258 tests
   and clean analysis. A different baseline is not automatically wrong, but it
   must be explained before proceeding.

## 3. Product and release context

- Product: **Currency Converter Honest Fern**.
- Package: `com.honestfern.currency_converter`.
- Framework: Flutter, Android-first for this release.
- Current source version: `1.0.0+4`.
- Google Play Internal testing contains `versionCode 4`.
- Closed testing has not started and Internal testers do not count toward the
  12-testers-for-14-days production-access requirement.
- The catalog currently contains 34 fiat and 11 crypto currencies.
- Release-safe fiat provider: Frankfurter.
- Release-safe crypto latest/history provider: fawazahmed0 currency-api.
- Development-only provider paths may include CoinPaprika/CoinGecko, but this
  task must not make them production dependencies.
- There is no backend, account system or first-party analytics in scope.

The newly found coverage defects supersede the earlier intention to promote
`1.0.0+4` directly to Closed. Do not promote code 4. The next valid path is:

1. implement and verify this plan locally;
2. create a new signed candidate using an unused code, expected `1.0.0+5`;
3. upload only to Internal after explicit approval;
4. accept the Play-distributed build on device;
5. only then create/promote a Closed release with separate approval.

## 4. User-visible reproduction

### 4.1 Confirmed fiat symptom

1. Open **Charts**.
2. Select `USD → CLP`.
3. Conversion in **Convert** works, but the chart has no data and reaches the
   chart error state.
4. The same class of failure occurs for pairs involving `AED`, `ARS`, `CLP`,
   `COP` or `TWD`.

The visible message currently suggests checking the network. That diagnosis is
misleading: the network can be healthy while the legacy endpoint has no
coverage for the requested currency.

### 4.2 Confirmed Polygon symptom

1. Select Polygon (`MATIC`) in Convert or Charts in a release-safe build.
2. The fawazahmed0 payload does not contain a `matic` key.
3. Latest parsing silently omits the currency; historical parsing produces no
   points and eventually throws a no-data error.

This is not a transient outage. Polygon migrated its native token from MATIC to
POL, and the provider's current key is `pol`.

## 5. Root-cause evidence

### 5.1 Frankfurter has two code paths with different API generations

Current/latest conversion already uses v2:

- `lib/src/core/rates/clients/frankfurter_client.dart`
  - `fetchLatest()` calls `/v2/rates`
- `lib/src/features/convert/data/frankfurter_latest_rates_client.dart`
  - `fetchLatest()` calls `/v2/rates`

Historical and trend comparison still use v1:

- `lib/src/core/rates/clients/frankfurter_client.dart`
  - `fetchHistorical()` calls `/v1/{from}..{to}` with `symbols`
- `lib/src/features/convert/data/frankfurter_latest_rates_client.dart`
  - `fetchPreviousRates()` calls `/v1/{from}..{to}` with `symbols`

Frankfurter v2 time series instead uses:

```text
GET /v2/rates?from=YYYY-MM-DD&to=YYYY-MM-DD&base=USD&quotes=CLP
```

and returns a list of rows:

```json
[
  {
    "date": "2026-09-10",
    "base": "USD",
    "quote": "CLP",
    "rate": 934.12
  }
]
```

The v1 parser expects a different map-shaped payload, so changing only the URL
is insufficient.

Official reference: <https://frankfurter.dev/>

### 5.2 Measured fiat coverage

The investigation on 2026-09-12 compared the app's exact 34-code fiat catalog
against both API generations.

Legacy v1 returned rows from USD for these 29 quote currencies:

```text
AUD BRL CAD CHF CNY CZK DKK EUR GBP HKD HUF IDR ILS INR JPY KRW
MXN MYR NOK NZD PHP PLN RON SEK SGD THB TRY ZAR
```

The five supported fiat currencies missing from the v1 quote dataset were:

```text
AED ARS CLP COP TWD
```

Frankfurter v2 returned all 34 supported fiat codes for a recent range.

Impact of retaining v1:

- 310 directional fiat/fiat pairs involve at least one of those five codes;
- 110 directional fiat/crypto routes use one of those five fiat codes as a
  bridge to or from one of 11 crypto currencies;
- total affected chart routes from this coverage mismatch: 420 directional
  pair routes, before counting the separate Polygon issue.

Do not claim that all 1,122 directional fiat pairs fail today. Twenty-nine fiat
currencies still exist in v1. The reason to migrate all historical callers is
consistency, deprecation risk and complete advertised coverage.

### 5.3 MATIC no longer maps to the release-safe provider

Current declarations:

- `lib/src/core/currency/supported_currencies.dart` publishes `MATIC`.
- `lib/src/core/rates/crypto/crypto_asset.dart` publishes `MATIC` with legacy
  CoinPaprika/CoinGecko IDs.
- `FawazahmedCryptoUsdPriceClient` looks up
  `usd[asset.code.toLowerCase()]`, therefore `matic`.
- `FawazahmedCryptoUsdHistoryClient` performs the same lookup for every day.

Provider evidence:

- current fawazahmed0 data has `pol`, not `matic`;
- monthly samples through the app's supported rolling one-year chart window
  (`2025-09-12` through `2026-09-11`) contained `pol` at every sampled point
  and no `matic`;
- older provider history used `matic`, then had a transition gap, then adopted
  `pol`. The app exposes at most one year for crypto, so the transition gap is
  outside the supported UI range for this release.

Official Polygon reference:
<https://docs.polygon.technology/pos/concepts/tokens/pol>

Product decision: replace the visible currency `MATIC` with `POL`. Do not add a
twelfth crypto entry, keep both names, or stitch unsupported pre-POL history
into the current one-year product range.

Verified provider identifiers for the new catalog entry:

| Surface | Required value |
|---|---|
| Public code | `POL` |
| Display name | `Polygon` |
| Display symbol | `POL` |
| fawazahmed0 key | `pol` |
| CoinPaprika ID | `pol-polygon-ecosystem-token` |
| CoinGecko ID | `polygon-ecosystem-token` |

`CryptoAsset.coinCapId` is currently a misleading field name used for the
CoinGecko identifier. Do not rename that field in this P0 unless a failing test
shows it is necessary; a broad naming refactor is not part of the fix.

## 6. Architecture and data flow to preserve

### Fiat latest and trend badges

```text
FrankfurterLatestRatesClient
  ├─ fetchLatest(base)          -> Frankfurter v2
  └─ fetchPreviousRates(base)   -> currently Frankfurter v1; migrate to v2
          ↓
Convert controller / rate-card mapping
          ↓
daily up/down trend badges
```

### Charts

```text
ChartsController
  -> RatesServiceChartRepository
  -> RatesService / HistoricalFetcher
  -> MultiProviderRatesClient
       ├─ fiat/fiat: FrankfurterClient.fetchHistorical
       ├─ fiat/crypto: Frankfurter fiat-to-USD bridge + crypto USD history
       ├─ crypto/fiat: crypto USD history + Frankfurter USD-to-fiat bridge
       └─ crypto/crypto: two crypto USD histories
```

The mixed-pair formulas and cache orchestration already exist. Fix the provider
inputs rather than duplicating chart calculations in UI code.

### Polygon state surfaces

Changing the catalog constant is not sufficient. Existing Internal testers may
have `MATIC` in:

- selected Convert currency codes (`pref_selected_codes`);
- default base currency (`pref_default_base`);
- Favorites (`favorite_pairs`);
- temporary chart unlock registry (`temp_unlocks_registry`);
- latest/history cache keys and serialized snapshots.

Every state entry that enters `currencyByCode()` must be canonicalized or
discarded safely before it can cause an unsupported-code exception.

## 7. Fixed implementation decisions

These decisions are already made; do not reopen them without contradictory
source evidence:

1. Use Frankfurter v2 for all fiat latest, historical and previous-day calls.
2. Keep the existing direct-device provider architecture; no backend.
3. Replace MATIC with POL and keep the catalog at 11 crypto / 45 total.
4. Map persisted `MATIC` user choices to `POL` where the intent is durable:
   selected codes, default base and Favorites.
5. For a live, unexpired temporary unlock involving MATIC, map it to the same
   pair with POL if this can be done deterministically. If the registry's
   existing encoding makes safe migration impossible, remove only the affected
   MATIC unlock entry and document that choice; do not clear all entitlements.
6. Do not reuse a cached MATIC market price/history as POL data. POL must fetch
   under its own cache key. Remove or ignore legacy MATIC-specific cache entries.
7. Preserve current date-range limits: fiat up to two years, crypto up to one
   year.
8. Keep normal tests offline with mocked HTTP.
9. Add an opt-in live coverage diagnostic; do not put live HTTP in
   `./scripts/check.sh` or the normal Flutter test suite.
10. Do not promote or publish from this implementation task.

## 8. Non-goals

- No chart layout redesign, axis redesign or new interaction.
- No new currencies beyond the MATIC→POL replacement.
- No migration to OXR, CoinGecko, CoinPaprika or a custom backend for release.
- No self-hosted Frankfurter.
- No intraday data or websocket pricing.
- No changes to ads, billing products, UMP or purchase entitlements except the
  exact temporary-unlock currency-code migration.
- No iOS release work.
- No broad cache rewrite.
- No rewrite of historical design/spec documents that accurately describe an
  older decision at the time. Update active truth documents only.
- No Play upload, Closed-test release, review submission or Production action.

## 9. Implementation sequence

Use test-driven development. Each production change begins with a focused
failing test that reproduces the defect.

### Phase A — Establish failing coverage tests

#### A1. Add direct Frankfurter historical-client tests

Create `test/frankfurter_client_test.dart` or the closest existing focused
equivalent. Use `MockClient`; never make a live request.

Required tests:

- `fetchHistorical` sends path `/v2/rates`.
- It sends `base`, `quotes`, `from`, and `to` query parameters.
- It does not send v1's `symbols` parameter or encode the range in the path.
- It parses multiple v2 row objects for `USD → CLP` into date/value points.
- It computes `coveredFrom` and `coveredTo` from valid parsed rows.
- It ignores malformed rows without discarding valid rows.
- It throws the existing domain exception for a non-list payload.
- It throws when no valid rows remain.
- It rejects a fiat/crypto request at this concrete client boundary as before.
- It behaves correctly when `base == quote` if that path can reach the client;
  preserve the existing MultiProvider USD/USD identity shortcut rather than
  inventing a network request.

The first path/payload tests must fail against the current v1 implementation.

#### A2. Update previous-day trend tests

In `test/convert_real_rates_test.dart`, replace the v1 fixture with v2 rows and
assert:

- `/v2/rates` path;
- `from` is ten calendar days before the reference;
- `to` equals the reference date;
- all supported quote codes are requested through `quotes`;
- the latest row strictly before `referenceDate` is selected;
- rows on the reference date are excluded;
- weekend gaps choose the previous available business day;
- malformed/empty/non-200 responses return `null`, preserving graceful trend
  degradation;
- `CLP`, `AED`, `ARS`, `COP` and `TWD` can be returned in the map.

Clarify the existing stale comment that assumes ECB-only publication. v2 blends
public provider data by default.

#### A3. Add POL provider tests

Extend focused tests in `test/crypto_charts_test.dart` and/or
`test/crypto_latest_rates_test.dart`:

- latest fawazahmed0 parsing maps provider key `pol` to public code `POL`;
- one-day and multi-day history parse/invert `pol` correctly;
- no production test fixture still requires a `matic` provider key;
- the release-safe provider factory remains fawazahmed0;
- `supportedCryptoAssets` and `supportedCryptoCurrencies` contain identical
  code sets and contain `POL`, not `MATIC`;
- the crypto group remains exactly 11 entries.

Do not make the whole latest snapshot fail only because one non-BTC asset is
temporarily absent unless the existing product contract explicitly requires
an all-or-nothing snapshot. Preserve graceful partial-provider behavior and use
the opt-in coverage diagnostic for the stronger catalog-wide assertion.

#### A4. Add persistence migration tests

Add focused tests to existing files or a new
`test/currency_code_migration_test.dart` for:

- selected codes `['EUR', 'MATIC', 'BTC']` become
  `['EUR', 'POL', 'BTC']`;
- duplicates collapse deterministically if both `MATIC` and `POL` exist;
- unsupported garbage codes do not reach `currencyByCode()`;
- default base `MATIC` becomes `POL`;
- favorite `MATIC-USD` becomes the equivalent POL pair and remains ordered;
- favorites containing both old and new equivalent pairs deduplicate;
- malformed favorite keys remain safely ignored;
- a MATIC temporary unlock is mapped or narrowly discarded according to the
  implementation decision in Phase C4;
- unrelated preferences, favorites and unlocks remain unchanged;
- migration is idempotent across repeated app launches.

### Phase B — Migrate Frankfurter historical data to v2

#### B1. Introduce one small v2 row parser if it reduces duplication

`FrankfurterClient.fetchLatest`,
`FrankfurterLatestRatesClient.fetchLatest`, historical parsing and
previous-day parsing all consume the same row shape. A small internal helper is
acceptable, for example under:

```text
lib/src/core/rates/clients/frankfurter_v2_parser.dart
```

It should parse typed facts, not return UI models. Keep its responsibility
narrow:

- accept decoded JSON;
- validate that the top level is a list;
- extract valid `date`, `base`, `quote`, `rate` rows;
- let callers decide whether empty data throws or degrades to `null`.

Do not merge the two client classes or refactor the full rates architecture in
this task. If a helper adds more complexity than it removes, use small private
parsers in each client and keep tests explicit.

#### B2. Change `FrankfurterClient.fetchHistorical`

File:
`lib/src/core/rates/clients/frankfurter_client.dart`

Required request:

```dart
Uri.https('api.frankfurter.dev', '/v2/rates', {
  'from': fromStr,
  'to': toStr,
  'base': base,
  'quotes': quote,
});
```

Required response behavior:

- accept only rows matching the requested quote;
- parse dates as date-only `DateTime` keys;
- accept numeric integer or floating-point rates;
- skip malformed/nonmatching rows;
- throw `RatesClientException` on non-200, invalid top level or zero valid
  points;
- derive coverage boundaries from actual points, not requested boundaries;
- preserve `savedAt: DateTime.now()` and the existing snapshot domain model.

#### B3. Change `fetchPreviousRates`

File:
`lib/src/features/convert/data/frankfurter_latest_rates_client.dart`

Required request:

```text
/v2/rates?from=<reference-10d>&to=<reference>&base=<base>&quotes=<all quotes>
```

Group valid rows by date. Select the latest available date strictly before the
reference date, then return all quote rates from that date. If no date exists,
return `null` as today.

Important edge cases:

- the response contains one row per date/quote, not one map per date;
- row order is not a contract; sort/compare parsed dates explicitly;
- do not combine quote rates from different dates into one previous snapshot;
- do not include the reference date even if present;
- one malformed quote row must not erase the rest of that day's valid rates.

#### B4. Verify mixed-pair composition without changing formulas

In `test/crypto_charts_test.dart`, add representative tests that the
`MultiProviderRatesClient` can compose:

- `CLP → BTC` using CLP/USD v2 fiat history and BTC/USD crypto history;
- `BTC → CLP` using the inverse direction;
- one ordinary unaffected pair such as `EUR → BTC` to guard regression.

Use fakes/snapshots at this layer. Do not duplicate HTTP fixtures here.

### Phase C — Replace MATIC with POL safely

#### C1. Change the public catalog and provider IDs

Required files:

- `lib/src/core/currency/supported_currencies.dart`
- `lib/src/core/rates/crypto/crypto_asset.dart`

Replace the single MATIC entry with:

```dart
SupportedCurrency(code: 'POL', name: 'Polygon', symbol: 'POL')
```

and provider metadata using the verified IDs in Section 5.3. Preserve the
crypto order unless a product reason requires otherwise. Preserve 11 entries.

#### C2. Update visual fallbacks and the asset map

Required files:

- `lib/src/shared/widgets/currency_flags.dart`
- `lib/src/shared/widgets/currency_flag_icon.dart`

Replace MATIC lookup/fallback with POL and point it at:

```text
assets/icons/currencies/pol.png
```

Do not leave a public MATIC entry in either map.

#### C3. Create the POL currency badge as a separate asset subtask

Use the accepted currency-badge visual language already in the repository:
round crop, clean silhouette, readable at small size, no rectangular white
background, correct transparency and no brand/style drift.

Before generation/editing, follow:

- `DESIGN.md`
- `.agent/ICON_GENERATION_KNOWLEDGE.md`
- `.agent/skills/icon-generation/SKILL.md`

Output requirements:

- final file: `assets/icons/currencies/pol.png`;
- exact pixel dimensions and color mode consistent with neighboring crypto
  badges;
- alpha outside the round badge where that is the current convention;
- legible at the actual app radii, not only at source resolution;
- visually inspected on both light and dark app themes;
- no generation metadata or scratch images under version control.

Remove `assets/icons/currencies/matic.png` only after all live references are
gone. `rg -n "MATIC|matic" lib test assets` should return no active product
reference except deliberate migration aliases/tests.

This asset subtask must not trigger regeneration of the other 44 badges or the
launcher icon.

#### C4. Add one canonical legacy-code migration boundary

Prefer a small pure helper in the currency domain, for example:

```text
lib/src/core/currency/currency_code_migration.dart
```

Conceptual contract:

```dart
String canonicalCurrencyCode(String raw) {
  final code = raw.trim().toUpperCase();
  return code == 'MATIC' ? 'POL' : code;
}
```

Validation/deduplication should happen at the storage boundaries, not every
time a widget renders. Apply it to:

- `AppPreferences.selectedCodes`;
- `AppPreferences.defaultBaseCurrency`;
- setters for those values, so legacy codes are not persisted again;
- `FavoritesStore._load()` and additions;
- temporary unlock serialization/load/registry cleanup.

Persist the migrated representation back once when practical so future
launches do not redo work. Keep migration idempotent.

The current `TemporaryUnlockStore` has custom registry encoding and its key
prefix behavior deserves a focused test before modification. Do not combine a
general serialization rewrite with this currency migration. Choose the
narrowest proven behavior:

1. decode the current registry fixture used by the shipped build;
2. migrate only entries whose base/quote is MATIC;
3. save them under the existing canonical storage-key convention as POL;
4. leave unrelated entries byte-equivalent where feasible;
5. if the shipped format cannot be safely decoded, drop only MATIC-related
   temporary entries and preserve unrelated registry state.

Paid lifetime products are not currency-specific and must not be altered.

#### C5. Isolate stale MATIC caches

Locate keys generated by:

- `CryptoUsdPriceCache` or equivalent latest-price cache;
- `CryptoUsdHistoryCache`;
- `RatesCache` historical pair keys.

POL must use new POL keys. Do not rename old MATIC values into POL market data.
It is acceptable to ignore orphaned MATIC keys or remove only those keys during
migration. Do not clear all cached rates on upgrade.

### Phase D — Add an opt-in live provider coverage diagnostic

Add a small read-only script following the repository's devtools convention.
Prefer `.devtools/check_provider_coverage.sh` unless the existing scripts layout
at implementation time clearly favors a `scripts/` entry point.

The diagnostic should:

1. derive or explicitly mirror the supported 34 fiat and 11 crypto codes;
2. request a recent weekday/range from Frankfurter v2;
3. report missing fiat codes, invalid/non-positive rates and HTTP errors;
4. request current fawazahmed0 data from the release-safe endpoints;
5. assert all expected crypto provider keys including `pol` are present;
6. optionally sample the current one-year boundary for POL history;
7. print a concise pass/fail matrix and exit non-zero on missing advertised
   coverage;
8. use no credentials and mutate no local/provider state.

If importing Dart catalog constants into a shell script would create brittle
duplication, implement a small Dart executable under `.devtools/` instead.
Whichever route is selected, document that it uses live network and is not a
deterministic CI/unit test.

Do not add it to `./scripts/check.sh` unless the normal check already has an
explicit opt-in environment flag for network tests.

### Phase E — Error semantics, documentation and store truth

#### E1. Chart error wording

First verify the current path:

```text
FrankfurterClient exception
  -> HistoricalFetcher / RatesService result
  -> ChartsController ChartStatus.error
  -> ChartsErrorState
```

The current generic subtitle says to check the connection even when a provider
returns no data. P0 is provider repair, not a large error-taxonomy redesign.
Make one of these bounded changes:

- preferred: distinguish network failure from no-data/provider-data failure if
  the existing domain result already preserves that distinction cleanly;
- fallback: use neutral copy such as “Historical data is unavailable for this
  pair right now. Try again later.”

Update localization source ARB files and regenerate generated localization
files through the project's normal Flutter tooling. Do not hand-edit generated
localization Dart files.

Acceptance: airplane-mode/network failure must not be mislabeled as unsupported
currency, and provider no-data must not instruct the user that their connection
is necessarily broken.

#### E2. Update active provider/product truth

Required active documents:

- `README.md`
- `DEFINITIONS.md`
- `docs/providers/frankfurter.md`
- `docs/providers/currency_coverage.md`
- `docs/release-prep/play-store-listing.md`
- `RELEASE_CHECKLIST.md`
- `.agent/release-next-steps.md`
- `AGENTS.md` current-state/version notes after the candidate is actually made

Required corrections:

- MATIC → POL in the active 11-crypto catalog;
- 34 fiat, not stale references to 40;
- historical and previous-day fiat paths use v2;
- Frankfurter v2 blends public central-bank/provider data by default;
- Play listing must not claim the data is ECB-only;
- record live coverage verification date and command;
- record the exact new version/artifact only after it exists.

Do not rewrite archived files under `docs/superpowers/plans/` merely because
they mention the historical MATIC or 40-fiat decision. Historical records may
remain historical unless another active document links to them as current
truth.

#### E3. Store assets

The launcher icon and current six screenshots do not automatically need to be
regenerated. Inspect them for visible MATIC text/icon:

- if POL/MATIC is not visible, keep the accepted screenshots;
- if MATIC is visible, recapture only the affected canonical screenshots after
  device acceptance;
- changing a currency badge does not authorize Play Console asset upload.

## 10. Expected file scope

### Required production code

```text
lib/src/core/rates/clients/frankfurter_client.dart
lib/src/features/convert/data/frankfurter_latest_rates_client.dart
lib/src/core/currency/supported_currencies.dart
lib/src/core/rates/crypto/crypto_asset.dart
lib/src/shared/widgets/currency_flags.dart
lib/src/shared/widgets/currency_flag_icon.dart
lib/src/core/preferences/app_preferences.dart
lib/src/features/favorites/data/favorites_store.dart
lib/src/core/monetization/models/temporary_unlock.dart
lib/src/core/monetization/temporary_unlock_store.dart
```

### Conditional/new production code

```text
lib/src/core/rates/clients/frankfurter_v2_parser.dart
lib/src/core/currency/currency_code_migration.dart
relevant chart error-state/controller/localization source files
```

Only add helper files if they materially reduce duplication and remain within
the repository's file-size/modularity rules.

### Required asset changes

```text
assets/icons/currencies/pol.png             # add
assets/icons/currencies/matic.png           # remove after references migrate
```

### Required/focused tests

```text
test/frankfurter_client_test.dart            # recommended new focused test
test/convert_real_rates_test.dart
test/crypto_charts_test.dart
test/crypto_latest_rates_test.dart
test/currency_groups_test.dart
test/favorites_test.dart
test/temporary_unlock_test.dart
test/currency_code_migration_test.dart       # conditional new focused test
```

### Active documentation/tooling

```text
.devtools/check_provider_coverage.sh         # or justified Dart equivalent
README.md
DEFINITIONS.md
docs/providers/frankfurter.md
docs/providers/currency_coverage.md
docs/release-prep/play-store-listing.md
RELEASE_CHECKLIST.md
.agent/release-next-steps.md
AGENTS.md
```

### Files that should not need behavioral changes

```text
lib/src/core/rates/multi_provider_rates_client.dart
lib/src/core/rates/provider_config.dart
lib/src/core/rates/provider_factory.dart
```

Add/adjust tests around them, but changing pair-composition formulas or provider
selection requires an explicit, evidenced reason in the implementation report.

## 11. Detailed acceptance criteria

### Fiat provider

- No active runtime Frankfurter history/trend call uses `/v1/`.
- `rg -n "api\.frankfurter\.dev|/v1/|symbols" lib/src` shows no legacy
  Frankfurter v1 call; unrelated provider v1 URLs may remain.
- USD/CLP and CLP/USD historical snapshots parse from v2 fixtures.
- AED, ARS, CLP, COP and TWD appear in the previous-day rates fixture/result.
- Mixed CLP/crypto composition works in both directions.
- Existing ordinary pairs such as USD/EUR and EUR/BTC still work.
- Empty, malformed and non-200 responses preserve current safe error/cache
  behavior.

### Polygon

- The user-facing catalog contains POL and no MATIC.
- The catalog remains 34 fiat + 11 crypto = 45 total.
- fawazahmed0 latest/history parse the `pol` key.
- CoinPaprika/CoinGecko metadata IDs are current even though those providers
  remain non-release fallbacks/dev paths.
- Existing stored MATIC selections/default/favorites cannot crash the app and
  become POL deterministically.
- No stale MATIC market data is relabeled as POL.
- The POL badge is legible, correctly cropped and visually consistent in light
  and dark mode.

### Reliability and architecture

- Unit/widget tests do not make real HTTP requests.
- The opt-in coverage check fails clearly if an advertised provider key is
  absent.
- No backend, account, analytics, billing, ad or broad UI change is introduced.
- No file violates the repository's modularity limits without explicit
  justification.
- Cached/offline chart behavior still returns valid existing data where
  available.

### Documentation/release

- Active docs say 34 fiat + 11 crypto and list POL.
- Active docs accurately describe Frankfurter v2 and blended public data.
- `1.0.0+4` is not described as the candidate to promote to Closed.
- No Play Console/API mutation occurs during implementation or review.

## 12. Verification protocol

### 12.1 Static and automated checks

Run from the app repository root:

```bash
dart format --output=none --set-exit-if-changed lib test
./scripts/check.sh
git diff --check
rg -n "MATIC|matic" lib test assets README.md DEFINITIONS.md docs/providers \
  docs/release-prep/play-store-listing.md
rg -n "api\.frankfurter\.dev|/v1/|symbols" lib/src
```

Review every remaining MATIC hit. Deliberate migration aliases/tests are valid;
active catalog/provider/UI references are not. Review every `/v1/` hit by
provider: fawazahmed0 and CoinPaprika legitimately use versioned v1 paths, so
do not delete them mechanically.

### 12.2 Opt-in live provider check

Run the new diagnostic with network available. Record:

- timestamp/time zone;
- exact command;
- Frankfurter HTTP/result summary;
- missing fiat codes, expected zero;
- fawazahmed0 expected crypto keys, including POL;
- any transient failure separately from a true missing-code result.

Do not paste huge provider payloads into committed documentation.

### 12.3 Emulator/device matrix

Use both the existing small and large Android targets. Test a release-safe build
with test ads unless a separately approved store artifact is being accepted.

Required chart pairs:

| Pair | Why |
|---|---|
| USD → CLP | original bug |
| CLP → USD | inverse fiat direction |
| USD → AED | second formerly missing v1 code |
| USD → ARS | second region/coverage sample |
| USD → COP | second Americas sample |
| USD → TWD | Asia-Pacific sample |
| CLP → BTC | formerly missing fiat bridge to crypto |
| BTC → CLP | inverse mixed bridge |
| USD → POL | new Polygon latest/history |
| POL → USD | inverse Polygon direction |
| POL → BTC | crypto/crypto composition |
| USD → EUR | unaffected regression control |

For applicable pairs, verify chart ranges:

- 1W
- 1M
- 1Y
- 2Y only for fiat/fiat, because crypto remains capped at 1Y

Also verify:

- chart loading, empty, cached and retry states;
- daily trend badges immediately after a clean install/first successful fetch;
- daily trend badges after pull-to-refresh;
- light and dark themes;
- small and large layouts;
- offline launch with cache;
- no-cache offline launch;
- currency picker search for POL and absence of MATIC;
- Favorites display/open action with POL.

### 12.4 Upgrade migration matrix

Test both a clean install and an in-place upgrade from `1.0.0+4`.

Seed or reproduce old state before upgrading:

- default base = MATIC;
- selected codes includes MATIC;
- one favorite with MATIC as base;
- one favorite with MATIC as quote;
- both equivalent MATIC and POL favorites if possible through seeded prefs;
- one live temporary chart unlock involving MATIC;
- old MATIC crypto/history cache entries.

After upgrade:

- app reaches first frame without exception;
- base/selection/favorites show POL;
- duplicates are absent;
- unrelated favorites/preferences/unlocks are preserved;
- POL performs a fresh provider fetch rather than displaying renamed MATIC
  cache data;
- second launch produces the same state with no repeated migration damage.

### 12.5 Visual badge verification

Capture focused picker/row screenshots at actual device density in:

- light theme, small emulator;
- dark theme, small emulator;
- light or dark theme, large emulator.

Inspect the source PNG and rendered result for:

- transparent/clean outer corners;
- no white square or halo;
- centered mark/text;
- no clipping at `CircleAvatar` crop;
- readable POL identity at the smallest production radius;
- visual weight comparable to BTC, ETH, SOL and AVAX badges.

## 13. Versioning and release boundary

Do not bump the version at the start. First complete code, tests, live coverage
and emulator QA.

When all P0 acceptance criteria pass and Luis authorizes preparation of a new
Internal candidate:

1. verify the next unused Play version code through the existing publishing
   workflow; expected value is 5;
2. set `pubspec.yaml` to `1.0.0+5` only if code 5 is unused;
3. rerun `./scripts/check.sh`;
4. build the signed release-safe AAB using the documented build workflow;
5. record artifact path, byte size, SHA-256, version name/code, application ID
   and signing verification;
6. install/inspect the corresponding APK or Play-distributed build;
7. stop before upload unless upload was explicitly authorized;
8. upload only to Internal; do not create/promote Closed or Production.

The Play Publisher service account is app-scoped. Never broaden its scope or
commit credentials. Follow `AGENTS.local.md` and
`docs/release-prep/google-play-publishing-runbook.md` when release work is
separately authorized.

## 14. Suggested commit boundaries

Keep reviewable commits; do not mix generated store artifacts with provider
logic.

1. `test: cover fiat v2 history and POL migration`
2. `fix: migrate fiat history and trends to Frankfurter v2`
3. `fix: replace Polygon MATIC with POL`
4. `chore: add provider coverage diagnostic`
5. `docs: align provider coverage and release sequence`
6. optional separately authorized release commit:
   `chore: prepare internal candidate 1.0.0+5`

The exact split may change if tests and implementation are inseparable, but
each commit must be coherent and pass relevant checks. Stage only intended
files.

## 15. Stop conditions

Stop and report evidence instead of improvising if any of these occurs:

- Frankfurter v2 does not return one or more of the 34 supported fiat codes in
  a recent valid range.
- POL is absent from current fawazahmed0 latest data or from the app-supported
  rolling one-year history window.
- Provider payload shape contradicts the fixtures/official docs.
- Safe migration of shipped MATIC preferences/favorites cannot be made
  idempotent.
- Temporary-unlock migration would require clearing unrelated or paid
  entitlements.
- A fix requires changing mixed-pair formulas, provider profile, backend,
  billing, ads or purchase state.
- Normal tests require live network access to pass.
- The worktree contains overlapping changes whose ownership is unclear.
- Code 5 is already used in Play.
- Signing identity/artifact metadata cannot be verified.
- Any next step would upload, commit a Play edit, alter tester lists, submit for
  review, promote Closed or publish Production without explicit approval.

## 16. Required implementation report for the reviewing agent

When implementation is complete, provide the primary reviewer with:

1. concise root-cause confirmation;
2. final commit list and `git status`;
3. exact changed-file inventory grouped by:
   - Frankfurter v2;
   - POL/catalog/persistence;
   - badge asset;
   - tests/diagnostic;
   - active documentation;
4. test-first evidence: which tests failed before and passed after;
5. full `./scripts/check.sh` result and test count;
6. live provider coverage result with timestamp;
7. screenshots or paths for POL badge QA and representative charts;
8. clean-install and `+4` upgrade-migration results;
9. remaining risks or deviations from this plan;
10. explicit confirmation that no Play/AdMob/backend state changed.

Do not claim completion based only on green unit tests. The primary reviewer
will independently inspect the diff, rerun decisive tests, inspect live
coverage, verify the rendered badge and exercise the emulator matrix before any
release authorization.

## 17. Definition of done

The implementation work is done only when all are true:

- [ ] Frankfurter history uses v2 everywhere.
- [ ] Previous-day trend data uses v2 everywhere.
- [ ] All 34 fiat currencies pass the opt-in live coverage check.
- [ ] CLP and all four other formerly absent v1 currencies work in Charts.
- [ ] Mixed pairs involving those currencies work in both directions.
- [ ] POL replaces MATIC in active code, UI, providers, asset and docs.
- [ ] Existing MATIC local state migrates safely and idempotently.
- [ ] POL latest and one-year history pass live and mocked checks.
- [ ] POL badge passes light/dark, small/large visual inspection.
- [ ] Error copy no longer falsely assumes every no-data failure is network.
- [ ] `./scripts/check.sh` and `git diff --check` pass.
- [ ] No unrelated scope or secrets entered the diff.
- [ ] Active release docs block promotion of `1.0.0+4`.
- [ ] Primary-agent independent review passes.
- [ ] Luis approves any version bump/upload as a separate operational step.
