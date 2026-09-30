# Favorites tab redesign — design

**Date:** 2026-09-30 · **Status:** approved by owner (mockup "Option A refined")
**Scope:** UI/UX only. Storage, limits (3 free / +3 rewarded / 16 Pro),
hidden-pairs rule, ads, purchases, open-in-Convert and refresh logic stay as
they are. Starter pairs (USD→EUR, USD→GBP, USD→BTC) are still seeded once.

## Why

Current tab uses tall bordered cards (breaks DESIGN.md "rate rows: no card,
no border, no shadow"), repeats each rate three times, shows × and drag
handles on every card and fits only ~2 pairs on a 360×640 phone.

## Layout (mirrors Convert: one card on top, plain rows below)

1. **Header** — `ScreenTitle("Favorites")` left; round toolbar pill on the
   right with a refresh button (same look as Convert's toolbar), calling the
   existing refresh callback.
2. **Hero card = first pair** (index 0). Same card language as Convert's
   amount card. Content: stacked flags + "USD → EUR" + trend pill (right);
   big rate in the leaf-green favorites colour; reverse rate line
   "1 EUR = 1.1370 USD"; status line "● 1× daily · Rates from Sep 29" + info
   icon (reuse the existing freshness label/status styles). Tap opens the pair
   in Convert (existing `onOpen`).
3. **Section header** — small caps label "MORE PAIRS · 3 OF 3"
   (visible count OF effective limit), styled like Convert's "RATES".
4. **Rows (pairs 2..n)** — Convert-style rate rows on the canvas with 0.5px
   dividers, no card. Left: overlapping flag pair (32px circles, second
   offset). Middle: "USD → GBP" (title) and reverse rate "1 GBP = 1.3263 USD"
   (supporting text). Right: the existing green value pill (DESIGN.md reserves
   it for favorites) with the trend (↑/↓ %) under it. Tap opens in Convert.
5. **Empty slot** — when visible pairs < effective limit, a dashed rounded
   row "+ Add a pair" after the list; tap = existing `onAdd` (open Convert).
6. **Upgrade line** — replaces the limit note block with one quiet row:
   lock icon + "Want more pairs?" + two small outline pills "Watch ad +3"
   (only when a boost is available) and "16 forever" (only without Pro).
   Same callbacks as today. The hidden-pairs note ("N pairs hidden") keeps its
   logic, restyled to match this row.
7. **Empty state** (0 pairs) — overlapping $/€ flags with a small star,
   title "Pin the pairs you check most", body "Swipe left on any currency in
   Convert and tap Favorite. Up to 3 pairs, free." (use the effective limit),
   primary pill "Open Convert", then a dashed preview slot "Your first pair
   shows here".

## Interactions

- **Remove:** swipe left on a row (and on the hero) reveals a coral
  "Remove" action; tapping it calls the existing `onRemove`. Same gesture
  language as Convert rows. No always-visible × any more.
- **Reorder:** long-press and drag (delayed drag start) across hero + rows in
  one reorderable list; dropping a row at the top makes it the hero. No
  always-visible drag handle.
- Semantics: rows/hero expose open, remove and reorder actions for screen
  readers (custom semantics actions), since the visible controls are gone.

## Formatting

- Reverse rate = 1 / rate, shown with the same smart decimals as the forward
  rate (≥100 → 2, ≥0.1 → 4, else up to 8 significant decimals); for crypto
  quotes the reverse line reads naturally ("1 BTC = 83,195 USD").
- Missing rate → "—" everywhere, no reverse line.

## Constraints

- Layering per ARCHITECTURE.md / CLAUDE.md: widgets render only; no
  cross-feature imports (anything reused from Convert must move to
  `lib/src/shared/widgets/`); file budgets (shared widgets ≤60 lines, split at
  200, build() ≤30 lines).
- Strings in en/de/es/it/fr.
- No overflow at 360×640 and at text scale 2.0; light + dark.

## Verification

Widget tests (hero vs rows, reverse rate, empty slot, upgrade line variants,
empty state, swipe-remove, reorder-to-top, no overflow at 2.0),
`./scripts/check.sh`, and the Android UX tour on all 3 AVDs.
