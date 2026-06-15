# Share Rate Card — Design Spec

> **Created:** 2026-06-15
> **Branch:** `main`
> **Status:** Draft for review
> **Plan item:** #5 from `docs/superpowers/plans/2026-06-13-session-summary-and-next.md`

## Overview

Add a **Share** action to the Convert screen that produces a clean, branded
**rate card** image (not a raw screen capture) and opens the OS share sheet.
The card is a snapshot of the current base amount against the currently-visible
pairs, rendered off-screen so it never includes the ad banner, nav bar, or
status bar.

Decisions captured during brainstorming:

- **Designed card**, not a raw screenshot.
- **Multi-pair**: base amount + all currently-visible pairs (no cap — the list
  is user-curated and small).
- **Always light / warm-paper** theme regardless of the app's theme, for
  consistent branding.
- **Both platforms** (iOS + Android) via `share_plus`; runtime-verified on
  Android this round, iOS shares the identical Dart path (unverified until run
  on a device).
- **v1 card content: name + value only** per row. Trend badges are an easy
  fast-follow (the data is already on the snapshot) but are out of scope for v1
  to keep the card uncluttered. *(Flag in review if you want them in v1.)*

## Card layout

```
┌─────────────────────────────────────┐
│  Niduna · Currency                    │   ← wordmark (Fraunces) + label
│                                       │
│  100 USD                              │   ← base amount (display weight)
│  ───────────────────────────────     │
│  Euro            € 86.34              │
│  British Pound   £ 74.57              │   ← currently-visible pairs
│  Japanese Yen    ¥ 16,029.00         │
│  Bitcoin         ₿ 0.00152276         │
│  ───────────────────────────────     │
│  Jun 15, 2026 · Rates by ECB          │   ← date + source footer
└─────────────────────────────────────┘
```

Warm paper background (`#F6F8EF`), forest-green wordmark, Manrope values with
tabular figures, thin dividers — all from `DESIGN.md` tokens. Fixed logical
width (~360dp); height grows with the number of pairs. Rendered at
`pixelRatio: 3` for crisp output.

## Architecture

Flow:

```
Convert header Share button
  → ConvertScreen builds RateCardData from ConvertState
  → RateCardShareService.share(data)
       → RateCardRenderer.toPng(RateCardImage(data))   (off-screen pipeline)
       → write PNG to temp dir (path_provider)
       → SharePlus.instance.share(files: [pngFile], text: caption)
```

### Units

1. **`RateCardData`** (model, `convert/models/`)
   Plain data the card needs: `baseAmountLabel` (e.g. "100 USD"), `rows`
   (list of `(name, valueLabel)`), `footerLabel` (e.g. "Jun 15, 2026 · Rates
   by ECB"). Pure data — keeps rendering independent of `ConvertState`.

2. **`rateCardDataFromState`** (pure mapper, `convert/presentation/`)
   `RateCardData Function(ConvertState)` — formats the base amount and maps the
   visible `CurrencyQuote`s to rows. Pure, unit-testable.

3. **`RateCardImage`** (StatelessWidget, `convert/widgets/share/`)
   Renders `RateCardData` into the branded card. Split into `RateCardImage`
   (shell, ≤60 lines) + `RateCardRow` (one pair line). Wraps content in
   `Theme(data: AppTheme.light, …)` so it's always light regardless of app
   theme.

4. **`RateCardRenderer`** (service, `core/share/`)
   `Future<Uint8List> toPng(Widget widget, {double pixelRatio, Size logicalSize})`.
   Lays the widget out in a detached `RenderRepaintBoundary` via a manual
   `BuildOwner` / `PipelineOwner` / `RenderView` pipeline and returns PNG bytes.
   No on-screen flash, no extra capture dependency. ~40 lines.

5. **`RateCardShareService`** (service, `core/share/`)
   `Future<ShareResult> share(RateCardData data)` — renders via
   `RateCardRenderer`, writes the bytes to a temp file (`path_provider`), and
   calls `share_plus`. Filename `niduna-rates-YYYYMMDD.png`, caption
   `"Exchange rates · {base amount} — via Niduna"`.

6. **Convert header button**
   Add `onShare` to `AmountHeaderRow` (beside refresh / more). `ConvertScreen`
   wires it: build `RateCardData` from `controller.state`, call the service.
   The button is disabled/hidden when there are no quotes yet.

## Dependencies

- `share_plus` — cross-platform share sheet.
- `path_provider` — temp directory for the PNG file.

Both are local and tracking-free, consistent with the privacy non-goals
(no backend, no accounts, no analytics).

## Error handling

- No quotes loaded → Share button disabled (nothing to share).
- Render or file-write failure → caught; show a SnackBar
  ("Couldn't create the image, try again"); never crash.
- User cancels the share sheet → no-op (normal `ShareResult`).

## Testing

- `rateCardDataFromState`: unit test — base amount + rows mapped from a sample
  `ConvertState`.
- `RateCardImage`: widget test — pumps with sample data (real Manrope loaded,
  as in `trend_badge_layout_test`), asserts the wordmark, base amount, a pair
  row, and footer render with no overflow.
- `RateCardRenderer.toPng`: returns non-empty bytes with a PNG header for a
  trivial widget.
- Device: tap Share on the emulator, confirm the OS share sheet opens with the
  PNG attached. (`share_plus` itself is a platform channel — not unit-tested.)

## Out of scope (v1)

- Trend badges on the card (fast-follow; data already available).
- Choosing a subset of pairs / reordering for the card.
- A logo image asset (use the text wordmark).
- Dark-theme card variant.
- Deep link / "Get Niduna" CTA in the caption.

## File budget

`RateCardImage` ≤60, `RateCardRow` ≤60, `RateCardRenderer` ≤100,
`RateCardShareService` ≤80, `RateCardData` ≤50, mapper small. New
`convert/widgets/share/` and `core/share/` folders.
