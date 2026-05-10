# Chart Cache and Range Expansion Plan (Reviewed)

> Status: approved for implementation
> Date: 2026-05-10

## Goals

- Add future intraday ranges (`1H`, `6H`, `1D`) as locked "Coming soon" controls.
- Avoid repeated historical downloads when moving between ranges (for example, `1Y -> 2Y`).
- Add TTL behavior to historical cache so chart data can refresh over time.
- Keep current Phase 1 behavior for active ranges (`1W`, `1M`, `3M`, `6M`, `1Y`, `2Y`).

## Scope Decision

- Active data ranges remain Phase 1 scope: `1W`, `1M`, `3M`, `6M`, `1Y`, `2Y`.
- New intraday controls are visual placeholders only:
  - `1H`, `6H`, `1D` are locked.
  - They show a "Coming soon" message and do not trigger network or state changes.

## Key Design Choices

### 1) Chart ranges UI

- Extend `ChartRange` enum with locked ranges:
  - `oneHour('1H', 0, locked: true)`
  - `sixHours('6H', 0, locked: true)`
  - `oneDay('1D', 0, locked: true)`
- Keep existing day-based ranges unlocked.
- `fromDate()` returns `null` for locked ranges.
- `RangeSelector` remains horizontally scrollable and now renders lock state.

### 2) Historical cache model moves from per-range to per-pair

Before:

- key: `historical_rates_{base}_{quote}_{rangeKey}`
- six independent caches per pair

After:

- key: `historical_rates_{base}_{quote}`
- one merged cache per pair

`HistoricalSnapshot` fields:

- `base`
- `quote`
- `coveredFrom` (date-only)
- `coveredTo` (date-only)
- `data: Map<DateTime, double>`
- `savedAt`

Rationale:

- `coveredFrom/coveredTo` avoids false gap detection caused by weekends/holidays.
- one-pair cache allows reuse when switching between ranges.

### 3) Date handling rules

- Normalize all comparison boundaries to date-only (`yyyy-mm-dd`) before logic.
- Never compare raw `DateTime.now()` (with time-of-day) against market-day coverage.

### 4) Merge rules

- Existing cache and fetched data are merged by date key.
- Newer fetched points win on collisions.
- Coverage is expanded to min/max of both snapshots.
- New snapshot `savedAt` becomes merged `savedAt`.

## Historical Request Strategy

For `getHistoricalRates(base, quote, from, to)`:

1. Normalize `from` and `to` to date-only.
2. Read pair cache.
3. If no cache: fetch full `[from..to]`, save, return.
4. If cache exists:
   - If range is not fully covered, fetch only missing gaps:
     - older gap: `[from..coveredFrom-1d]`
     - newer gap: `[coveredTo+1d..to]`
   - Merge fetched gaps into cache.
5. If cache is stale (TTL) or `forceRefresh`:
   - refresh recent segment from `coveredTo` to `to` (date-only safe path)
   - merge and save
6. Return filtered snapshot for requested `[from..to]`.

## TTL Policy

- Historical cache TTL: `4 hours`.
- If stale, refresh recent segment while preserving cached history.
- If refresh fails, return cached result with cached status and message.

## Concurrency and Freshness Guards

### Service dedup

- Historical request dedup key includes pair + exact requested date window.
- Prevents accidental sharing between incompatible windows.

### Controller stale-response guard

- `ChartsController` increments request version on each `_load()`.
- Applies response only if response version matches latest active request.
- Prevents late responses from older selections overwriting current range.

## Cache Storage Operations

### SharedPreferences cache

- Uses per-pair historical key.
- `writeHistorical` merges with existing pair snapshot before writing.
- Maintains tracked-cache-key registry for `clear()` because sync `SharedPreferences` has no key enumeration.

## Expected Behavior Examples

- `1W -> 1M`: fetches only missing older days; already-cached week reused.
- `6M -> 1Y`: fetches only missing older 6 months; existing 6 months reused.
- `1Y -> 2Y`: fetches only missing older year; existing 1Y reused.
- `2Y -> 1Y`: no network fetch; filter from pair cache.

## Risks and Mitigations

- Weekend/holiday holes causing false fetch loops
  - mitigated by explicit `coveredFrom/coveredTo`, not raw key min/max assumptions.
- Merge overwrite direction bugs
  - mitigated by explicit "new data wins" merge rule + tests.
- Stale response race after quick range taps
  - mitigated by controller request-version guard.
- Clear cache no-op
  - mitigated by tracked cache key registry.

## Verification Plan

- Run `./scripts/check.sh`.
- Build and run iOS simulator app.
- Manual checks:
  - locked pills show and do not change selected range
  - `1Y -> 2Y` transition does not redownload whole 2Y repeatedly
  - `2Y -> 1Y` uses filtered cache without fetch
  - stale cache path still returns usable chart data
