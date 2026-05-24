# UI Motion Polish Plan

> Status: partially implemented on 2026-05-24  
> Scope: subtle animation and interaction polish for `Convert`, `Charts`, and
> `Settings` without changing product scope, data model, or navigation

Implemented so far:

- Phase 1: shared motion tokens
- Phase 1: shared `PressScale` primitive
- Phase 1: shared `FadeSlideSwitcher` primitive
- Phase 2: floating nav active-pill motion
- Phase 2: shell tab-body fade/slide transition

Still pending:

- Convert-specific motion polish
- Charts-specific motion polish
- Settings / premium flow motion polish

## Goal

Make the app feel more premium and intentionally designed through restrained
motion, feedback, and state transitions.

This plan is not about adding flashy animation. It is about making existing
interactions feel more alive, legible, and professional:

- clearer tap feedback
- smoother state changes
- more tactile controls
- better continuity between user action and UI response

The target result is: the app still feels calm and utility-first, but no longer
static.

## Design Constraints

All changes should respect the current Niduna direction from
`/Users/luis/Niduna/apps/currency-converter/DESIGN.md`.

Rules:

1. motion must support comprehension, not decoration
2. no animation should delay core tasks like typing, switching currencies, or
   scanning rates
3. avoid springy playful motion that makes the product feel toy-like
4. motion must remain subtle on repeated use
5. honor reduced-motion platform settings where practical

## Motion Language

Use one consistent motion system instead of per-widget improvisation.

### Core timings

- micro feedback: `90ms` to `140ms`
- small surface transitions: `160ms` to `220ms`
- panel or sheet emphasis: `220ms` to `280ms`
- avoid anything above `320ms` in the main tabs

### Core curves

- enter: `Curves.easeOutCubic`
- exit: `Curves.easeInCubic`
- emphasis / scale settle: `Curves.easeOutBack` only in very small amounts
- standard state changes: `Curves.easeInOutCubic`

### Reusable motion tokens to add

Likely home:
- `lib/src/core/theme/app_theme.dart`

Proposed tokens:

- `motionFast = Duration(milliseconds: 120)`
- `motionMedium = Duration(milliseconds: 180)`
- `motionSlow = Duration(milliseconds: 240)`
- `curveEnter = Curves.easeOutCubic`
- `curveExit = Curves.easeInCubic`
- `curveStandard = Curves.easeInOutCubic`

## Highest-Value Changes

### 1. Improve tab switching continuity

Current risk: the bottom nav is visually custom, but tab changes can still feel
binary.

Change:

- animate the active nav pill position and icon/text emphasis as one system
- fade/slide the tab body content very slightly on tab switch
- keep the transition short so the app still feels immediate

Target widgets:

- `lib/src/shared/widgets/floating_pill_nav.dart`
- `lib/src/shared/widgets/floating_pill_nav_item.dart`
- `lib/src/shared/widgets/bottom_tab_frame.dart`

Implementation detail:

- keep the nav pill movement as the primary visual cue
- body transition should be subtle: around `8px` vertical offset plus fade
- do not animate whole-screen large parallax

Acceptance:

- switching `Convert` <-> `Charts` <-> `Settings` feels connected, not abrupt
- active tab state becomes obvious without extra color noise

### 2. Make the amount instrument feel reactive

Current opportunity: `Convert` has a strong amount panel, but it can feel too
static after edits or refreshes.

Change:

- animate amount value changes with a soft `AnimatedSwitcher`
- lightly animate the base currency pill when base changes
- pulse or fade the freshness bar when rates refresh completes

Target widgets:

- `lib/src/features/convert/widgets/amount_panel.dart`
- `lib/src/features/convert/widgets/amount_value_row.dart`
- `lib/src/features/convert/widgets/amount_base_button.dart`
- `lib/src/features/convert/widgets/amount_status_bar.dart`

Implementation detail:

- amount transition should be fade + small upward settle, not counter-style
  digit spinning
- base pill change can use scale from `0.98` to `1.0` plus fade
- refresh confirmation should be brief and only happen on actual new data

Acceptance:

- changing amount or base gives immediate visual acknowledgment
- the instrument feels responsive without looking busy

### 3. Upgrade rate row interaction polish

Current opportunity: rate rows are useful, but their press/select/base-change
states can still feel utilitarian.

Change:

- unify row press feedback with a soft surface tint and tiny scale response
- animate the value badge and supporting rate text when a row becomes active
- animate row removal and reorder events cleanly

Target widgets:

- `lib/src/features/convert/widgets/currency_rate_row.dart`
- `lib/src/features/convert/widgets/visible_rates_list.dart`
- `lib/src/features/convert/widgets/currency_row_swipe_actions.dart`
- `lib/src/features/convert/widgets/quote_value.dart`

Implementation detail:

- use `AnimatedContainer` / `TweenAnimationBuilder` before introducing more
  complex custom animation
- activation cue should be visible but still calm on repeated taps
- when a row becomes the base currency, the transition should visually explain
  the change better than the old arrow affordance did

Acceptance:

- row activation feels intentional
- row-to-base promotion feels understandable even without helper text

### 4. Make chart range and pair changes feel premium

Current opportunity: `Charts` is the flagship visual surface and should carry
the strongest polish.

Change:

- animate range selection pill movement and text emphasis
- crossfade chart data and header metrics on range or pair change
- give the touched chart indicator a slightly richer overlay behavior

Target widgets:

- `lib/src/features/charts/widgets/range_selector.dart`
- `lib/src/features/charts/widgets/chart_header.dart`
- `lib/src/features/charts/widgets/rate_chart.dart`
- `lib/src/features/charts/widgets/chart_touch_overlay.dart`
- `lib/src/features/charts/widgets/chart_pair_strip.dart`
- `lib/src/features/charts/widgets/chart_pair_pill.dart`

Implementation detail:

- avoid expensive chart redraw theatrics; prefer fade/opacity continuity around
  data swaps
- selected range pill should glide, not pop
- chart touch overlay can use slightly stronger opacity and subtle label fade-in

Acceptance:

- changing range feels premium and legible
- chart inspection feels more deliberate, not just technically functional

### 5. Improve sheet and picker presentation

Current opportunity: sheets do the job, but many Flutter sheets feel generic by
default.

Change:

- standardize sheet entrance, handle, top spacing, and internal staged fade
- make currency pickers and the conversion lens feel like part of the same
  design family

Target widgets:

- `lib/src/features/convert/widgets/currency_picker_sheet.dart`
- `lib/src/features/convert/widgets/amount_input_sheet.dart`
- `lib/src/features/convert/widgets/conversion_lens_sheet.dart`
- `lib/src/features/charts/widgets/chart_currency_picker_sheet.dart`
- `lib/src/features/charts/widgets/locked_pair_action_sheet.dart`
- `lib/src/shared/widgets/currency_picker_chrome.dart`

Implementation detail:

- use a shared sheet chrome component if repeated structure is diverging
- content can fade in after sheet rise by `40ms` to avoid everything appearing
  at once
- do not animate list items one by one in long pickers; that becomes tiring

Acceptance:

- sheets feel cohesive across the app
- modal interactions feel more intentional than stock Flutter defaults

### 6. Add restrained premium emphasis in Settings

Current opportunity: monetization now lives more correctly in `Settings`, but it
can still feel static.

Change:

- give the upgrade shelf and premium rows clearer hover/press/emphasis states
- animate purchase result confirmation and entitlement state changes
- use motion to communicate unlock success, not just text replacement

Target widgets:

- `lib/src/features/settings/widgets/upgrade_shelf.dart`
- `lib/src/features/settings/widgets/premium_section.dart`
- `lib/src/features/settings/widgets/iap_purchase_player.dart`
- `lib/src/shared/widgets/settings_tile.dart`

Implementation detail:

- success state can use soft highlight wash or icon transition
- keep paid surfaces restrained; avoid casino-like pulsing or shimmer

Acceptance:

- premium controls feel polished and trustworthy
- paid actions feel integrated, not bolted on

## Reusable Primitives To Introduce

To avoid motion drift, add a small shared layer instead of ad hoc animation in
every file.

### Proposed shared widgets/helpers

- `PressScale` or `InteractiveScale`
  - wraps pills, icon buttons, and selected surfaces
  - very small scale range like `1.0 -> 0.985`

- `FadeSlideSwitcher`
  - reusable for metric changes, titles, freshness labels, and badges
  - fade + `Offset(0, 0.04)` or `Offset(0, 0.02)`

- `MotionTokens`
  - durations and curves in theme/constants

- optional `AnimatedSectionReveal`
  - for sheet internals or empty/error states
  - use sparingly

Likely home:

- `lib/src/shared/widgets/`
- `lib/src/core/theme/app_theme.dart`

## Things To Avoid

Do not implement these unless a later review proves they are needed:

- hero background particles or decorative ambient motion
- bouncing list rows
- per-character number rolling
- continuous shimmer on premium surfaces
- long stagger animations on every screen load
- animations that block data refresh or interaction

These would make the app feel less serious and more template-like.

## Implementation Order

### Phase 1: shared motion foundation

1. add motion tokens to theme/constants
2. add one reusable press-scale primitive
3. add one reusable fade-slide switcher
4. verify no regressions with text scale and golden-like screenshot review

### Phase 2: navigation and shell

1. polish floating nav active state motion
2. add subtle tab-body transition in `BottomTabFrame`
3. verify transitions do not cause layout jump at the footer

### Phase 3: Convert polish

1. animate amount value updates
2. animate base pill changes
3. polish rate-row active/base/remove transitions
4. verify repeated use does not feel noisy

### Phase 4: Charts polish

1. animate range selector
2. animate pair/header/data swaps
3. improve chart touch overlay presentation
4. verify performance on simulator and a physical device if available

### Phase 5: Settings and purchase flow

1. polish premium row interactions
2. animate entitlement success states
3. verify calmness and trustworthiness of the final tone

## Verification Plan

Before calling this work complete:

1. run `./scripts/check.sh`
2. rebuild and install on the iOS simulator
3. manually test repeated tap behavior in `Convert` and `Charts`
4. verify no animation causes accidental delay in amount entry
5. verify chart interaction still feels precise under finger
6. verify sheets remain readable and stable at larger text scales
7. capture before/after screenshots and short screen recordings

## Success Criteria

The work is successful if:

- the app feels more premium in motion, not just in static screenshots
- repeated use still feels calm after one minute of tapping around
- no animation becomes the center of attention
- the user notices the app feels better without necessarily naming one effect

## Recommended Next Step

Implement only Phase 1 and Phase 2 first, then rebuild and review on the iOS
simulator before touching every feature surface.

Reason:

- it creates a shared system before local polish
- it avoids inconsistent one-off animation styles
- it lets us judge whether the app needs more motion at all, or just better
  shell continuity
