# UI Typography Consistency Plan

> Status: implemented on 2026-05-24.
> Scope: shared typography roles, Settings hierarchy tuning, Convert/Charts
> kicker alignment, supporting text normalization, and localized premium
> subtitles found during Spanish Android verification.

## Goal

Keep the visible typography hierarchy across `Convert`, `Charts`, and
`Settings` feeling like one coherent Niduna product on iOS and Android,
including localized Spanish Android builds.

The app has changed since this plan was first written. `Convert` and `Charts`
now use a more intentional hero/micro-label pattern, while `Settings` still
uses the heavier conventional screen-title pattern. The plan below replaces the
older "all screens need a new shared title" assumption with a narrower current
review.

## Review Method

- Read `AGENTS.md`, `DESIGN.md`, `DEFINITIONS.md`, `ROADMAP.md`, `PLAN.md`,
  and `agent/README.md`.
- Followed repo guidance to use local scripts and simulator tooling.
- Avoided `.devtools/capture_tabs.sh` and `.devtools/sim_tap.sh` for this
  review because they use `cliclick`, which moves the real laptop pointer.
- Captured iOS screenshots through the Flutter integration-test screenshot
  driver:
  - command shape:
    `IOS_SIMULATOR_ID=AD6518C3-252E-4951-AE25-AF6732817FB1 SCREEN_OUTPUT_DIR=.tmp/screens/typography-review-ios CAPTURE_TARGET_PATH=integration_test/typography_review_capture_test.dart ./.devtools/capture_ios_screens.sh`
  - simulator: `iPhone 17 Pro`
  - result: all integration screenshot tests passed

Current review screenshots:

- Convert: `.tmp/screens/typography-review-ios/01-convert.png`
- Charts: `.tmp/screens/typography-review-ios/02-charts.png`
- Settings: `.tmp/screens/typography-review-ios/03-settings.png`

Implementation verification screenshots:

- iOS Convert: `.tmp/screens/typography-implementation-ios/01-convert.png`
- iOS Charts: `.tmp/screens/typography-implementation-ios/02-charts.png`
- iOS Settings: `.tmp/screens/typography-implementation-ios/03-settings.png`
- Android ES Convert:
  `.tmp/screens/typography-implementation-android-es/01-convert.png`
- Android ES Charts:
  `.tmp/screens/typography-implementation-android-es/02-charts.png`
- Android ES Settings:
  `.tmp/screens/typography-implementation-android-es/03-settings.png`

Older reference screenshots from the first review are now historical context
only:

- iOS: `.tmp/screens/ios/01-convert-221232.png`
- iOS: `.tmp/screens/ios/02-charts-221234.png`
- iOS: `.tmp/screens/ios/03-settings-221237.png`
- Android: `.tmp/screens/android/convert-review.png`
- Android: `.tmp/screens/android/charts-review.png`
- Android: `.tmp/screens/android/settings-review.png`

## Current Findings

### Convert

- The original issue, "Convert top-left header reads like metadata instead of a
  real screen title", is partly obsolete.
- Current `Convert` uses a compact green kicker label, an action pill, and a
  dominant amount instrument panel. It reads as a product surface, not as a
  normal list page.
- The hierarchy is strong: amount first, base currency second, freshness third,
  rates list fourth.
- The tiny kicker is acceptable if this remains the intended instrument-style
  design, but it should be treated as a deliberate pattern shared with `Charts`,
  not as a standalone one-off.
- Non-typography note: the current screenshot shows placeholder-looking green
  currency circles in the Convert list while Charts shows flag artwork. Verify
  separately before treating this as a real asset bug, because it may be a
  screenshot-driver or test-data artifact.

### Charts

- The original issue, "Charts top-left header is too small relative to the chart
  card content", is also mostly obsolete.
- Current `Charts` has a clear hierarchy: green kicker, large Fraunces pair
  title, metric row, freshness copy, range rail, chart, pair selector, metrics.
- The header now feels closer to the Niduna editorial direction than the older
  screenshots.
- The chart range labels and metric rail are readable on the captured iPhone
  17 Pro screen. Smaller phones still need verification.

### Settings

- `Settings` is now the main remaining typography drift.
- It uses `ScreenTitle` (`AppTheme.screenTitleStyle`) with a large Fraunces title
  and conventional list rows. This is readable, but it feels heavier and more
  separate from the Convert/Charts instrument language.
- The `Premium unlocks` subsection also uses a large Fraunces title, creating a
  second strong display moment inside a settings list.
- Row typography is clear, but some rows use local `TextStyle` values instead of
  shared typography tokens, so future consistency changes may be uneven.

### Shared Footer

- `Convert` and `Charts` now both use `BottomTabFrame` plus `AdSupportShelf`.
- The current captures show the banner, Remove Ads button, and floating nav
  using the same vertical system in both tabs.
- If overlap or spacing regressions return, fix them in the shared footer frame
  or shelf instead of making per-tab spacing guesses.

## Updated Desired Outcome

- `Convert` and `Charts` keep their high-density instrument feel.
- `Convert` and `Charts` share the same small green kicker style and top rhythm.
- `Settings` keeps list clarity but no longer feels like a separate typography
  system.
- Section labels, helper text, row subtitles, and CTA labels use shared tokens
  instead of scattered local font sizes.
- Localized strings fit without cramped wraps, especially Spanish Android.

## Updated Implementation Plan

### 1. Formalize the two allowed top patterns

Do not force every tab into the same literal title layout. The app currently
has two legitimate screen types:

- instrument tabs: `Convert` and `Charts`
- list/settings tabs: `Settings`

Create or document shared tokens/widgets for:

- green kicker label used by `Convert` and `Charts`
- editorial hero title used by `Charts`
- settings/list title used by `Settings`
- metadata/freshness text below hero content

Likely code touchpoints:

- `lib/src/features/convert/widgets/amount_header_row.dart`
- `lib/src/features/charts/widgets/chart_header.dart`
- `lib/src/shared/widgets/screen_title.dart`
- `lib/src/core/theme/app_theme.dart`

### 2. Tune Settings to match the current app

- Reduce the visual jump between the `Settings` title and the Convert/Charts
  kicker/hero rhythm.
- Consider making `ScreenTitle` slightly less dominant or reducing the top
  spacing on `Settings`.
- Audit large inner Fraunces headings like `Premium unlocks`; they should not
  compete with the page title.
- Keep row labels readable, but route local row typography through shared tokens
  where practical.

Likely code touchpoints:

- `lib/src/features/settings/settings_screen.dart`
- `lib/src/features/settings/widgets/premium_section.dart`
- `lib/src/shared/widgets/settings_tile.dart`
- `lib/src/core/theme/app_theme.dart`

### 3. Normalize supporting text

- Keep metadata/freshness text clearly secondary, but not tiny.
- Use one readable helper style for exchange-rate detail, settings subtitles,
  and chart support text where the visual role is the same.
- Keep tab labels and CTA text stable when text scaling is enabled.

### 4. Preserve the shared footer system

- Keep `BottomTabFrame` and `AdSupportShelf` as the shared bottom ad/CTA/nav
  layout contract for `Convert` and `Charts`.
- Do not tune Convert and Charts footer spacing independently unless the shared
  component cannot express the needed layout.

### 5. Re-verify platform and localization fit

- Re-capture iOS screenshots for all visible tabs.
- Re-capture Android screenshots in Spanish for all visible tabs.
- Check a smaller iPhone simulator, not only iPhone 17 Pro.
- Compare the current review screenshots against the post-change screenshots.

## Verification Checklist

Before calling implementation complete:

1. run `./scripts/check.sh`
2. rebuild or reinstall the app on the target simulator/emulator
3. capture fresh screenshots for `Convert`, `Charts`, and `Settings`
4. verify `Convert` and `Charts` still share the same kicker/top rhythm
5. verify `Settings` no longer feels visually heavier than the other tabs
6. verify Spanish Android strings fit in headers, rows, and chart summaries
7. verify ad shelf and Remove Ads spacing remains shared between `Convert` and
   `Charts`

## Out Of Scope

- new navigation structure
- new monetization flows
- chart feature changes
- changing tab count or restoring Favorites navigation
- fixing flag/icon assets unless the placeholder-looking Convert capture is
  reproduced outside the typography review

## Risks

- reducing Settings title weight too much may make Settings feel less polished
- larger helper text can crowd rows and chart metrics
- localized strings may need per-widget layout tuning after token changes
- shared typography changes can expose spacing problems in unrelated widgets

## Recommended Execution Order

1. keep the current iOS screenshots as the "before" set
2. define the shared top-pattern and text-role tokens
3. tune `Settings` first, because it is the clearest remaining drift
4. extract/align the Convert and Charts kicker styles only if duplication blocks
   consistent tuning
5. normalize helper/subtitle text where screenshots show readability problems
6. run checks and re-capture iOS plus Android Spanish screenshots
