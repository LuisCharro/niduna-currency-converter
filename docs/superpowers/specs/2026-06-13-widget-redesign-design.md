# Widget Redesign Design

> **Created:** 2026-06-13
> **Status:** Draft for review
> **Branch:** `main`
> **Scope:** Redesign the home-screen widget as a real product surface, replacing the current placeholder-style layout.

---

## 1. Goal

Turn the current widget from a large mostly-empty card into a useful, glanceable medium-size widget that reflects the app's privacy-first, warm, editorial design system.

This redesign is for the **medium widget size first**. The design should be shared conceptually across Android and iOS, while the rendering remains native per platform.

This work is intentionally limited to a **no-account, local-only** widget. It must not require backend data, user authentication, cloud sync, or widget-specific account setup.

---

## 2. Product Definition

### Primary job

The widget's primary job is **quick glance**. The user should be able to read useful conversion information without opening the app.

### Secondary job

The widget's secondary job is **quick launch**. Tapping the widget should open the app directly to `Convert`.

### What the widget is not

- Not a miniature chart
- Not a standalone configuration UI
- Not a reskinned app screen
- Not an empty branded tile with one large number

---

## 3. Shared v1 Rules

These rules apply to both Android and iOS versions of the widget.

### Widget size

- **Only medium widget size is in scope for v1**

### Information model

- Show **3 quick pairs**
- Widget is **favorites-driven**
- Use the **last amount used in the app**
- Show **flags for fiat** and **logos for crypto**
- Show **trend arrow + percent** for each row
- Tap anywhere on the widget opens the app to **Convert**

### User control model

The widget will **not** have its own independent configuration flow in v1.

The widget content is derived from app state the user already understands:

- current amount
- current convert context
- favorites list

This avoids duplicate configuration logic and keeps the first version simple, predictable, and fast to ship.

---

## 4. Content Sourcing Rules

### Normal state

When favorites exist:

- use the current app amount
- show **3 pairs sourced from favorites**

### Initial starter state

On first-run only, the app may seed starter favorites so the widget is useful immediately.

Recommended starter set:

- `USD -> EUR`
- `USD -> GBP`
- `USD -> BTC`

These give a mix of mainstream travel use, finance familiarity, and one crypto differentiator.

### After the user edits favorites

Once the user makes a real favorites choice, starter mode ends.

The widget must then reflect actual user-owned state.

### If the user deletes all favorites

Do **not** silently re-seed the starter favorites.

Instead, use fallback mode:

- row 1: current Convert pair
- row 2: backup pair 1
- row 3: backup pair 2

This respects user intent while keeping the widget useful.

Recommended backup pairs:

- `USD -> EUR`
- `USD -> GBP`
- `USD -> BTC`

If current Convert pair already matches one of the backups, de-duplicate and fill with the next sensible candidate.

---

## 5. Widget Layout

### Overall layout

The widget is a compact information panel with:

1. a **header row**
2. **three conversion rows**

### Header row

- left: amount, e.g. `100 USD`
- right: freshness label, e.g. `Updated today`

The header should feel compact and balanced, not stretched or ornamental.

### Conversion rows

Each of the three rows contains:

- left: flag/logo + currency code
- center/right: converted value
- far right: trend arrow + percent

Rows are separated by **thin dividers**, not boxed mini-cards.

### Density target

The widget should feel like a small financial instrument panel:

- dense enough to justify the home-screen space
- calm enough to remain glanceable
- warmer and more crafted than a generic stock widget

---

## 6. Visual Language

Use `DESIGN.md` as the visual source of truth.

### Required design signals

- warm paper background
- dark forest text
- muted olive metadata
- moss green for positive trend
- coral for negative trend
- real currency flags / crypto logos
- dividers instead of boxes
- compact, editorial spacing

### Explicitly avoid

- giant empty card areas
- top-left-only composition
- generic white utility-card styling
- developer-like timestamps such as raw ISO dates as the primary freshness expression
- fake browser/phone chrome

### Freshness copy

Preferred copy:

- `Updated today`
- `Updated 16:04`

Avoid raw strings like:

- `Updated 2026-06-13`

unless no better formatting information exists.

---

## 7. Platform Adaptation

### Android

Implementation stays on the current `AppWidgetProvider` + `RemoteViews` path.

Why:

- already integrated
- no Compose/Glance dependency risk
- avoids the Kotlin inliner bug already documented in the repo

Android should render the same shared hierarchy:

- header row
- 3 data rows
- thin dividers

The XML layout should be redesigned completely rather than lightly tweaked.

### iOS

Implementation stays on the current WidgetKit target.

The same shared information hierarchy applies, but the final spacing and row polish should feel native to iOS WidgetKit.

The current blocker is not layout design. The blocker is that the embed phase is disabled on `main` to preserve simulator install stability. Real-device testing remains the right verification path.

---

## 8. States

The widget must support these states explicitly.

### A. Normal

- favorites exist
- top 3 relevant pairs shown

### B. Fallback

- no favorites exist
- current Convert pair + 2 backup pairs shown

### C. Loading / no data yet

- first launch or no stored snapshot yet
- should not show a giant blank card
- should show a compact helpful state with minimal text

### D. Stale data

- still show rates
- freshness line communicates staleness clearly

---

## 9. Interaction Rules

### v1 tap behavior

- tapping anywhere on the widget opens the app to `Convert`

### Explicitly out of scope for v1

- row-specific tap actions
- widget-level pair picker
- widget-level amount picker
- widget resizing variants beyond the medium baseline

These can be revisited after the medium widget proves useful.

---

## 10. Verification Plan

### Android

1. Add the widget from the launcher
2. Verify the normal state renders 3 useful pairs
3. Verify flags/logos render correctly
4. Verify trend arrows + percent are visible and legible
5. Verify tapping opens `Convert`
6. Delete all favorites and verify fallback mode
7. Refresh rates in-app and verify widget updates

### iOS

1. Decide whether testing is worth doing now
2. If yes, restore the embed phase
3. Verify on a real iPhone rather than sim-first
4. Check that the shared hierarchy still feels native in WidgetKit

---

## 11. Out of Scope

- multi-pair chart comparison
- widget-specific configuration UI
- account/cloud-backed widget state
- home-screen charts in the widget
- large/small widget redesign in the same implementation pass

---

## 12. Recommended Implementation Order

1. Redesign Android medium widget layout first
2. Verify launcher/runtime behavior on Android
3. Decide whether to proceed with iOS widget re-enable + real-device testing
4. Only after that, consider additional widget sizes or per-widget configuration

---

## 13. Decision Summary

- Medium widget only first
- Shared product design, native platform rendering
- 3 quick pairs
- Favorites-driven
- Last app amount
- Flags for fiat, logos for crypto
- Trend arrow + percent
- Header = amount left + updated time right
- Tap opens Convert
- Starter favorites allowed only on first-run
- Deleting all favorites uses fallback mode, not silent re-seeding
