# UI Typography Consistency Plan

## Goal

Align the visible typography hierarchy across `Convert`, `Charts`, and `Settings`
so the app feels like one coherent product on both iOS and Android, including
Spanish-localized Android builds.

## Trigger

Manual emulator review found the same pattern on both platforms:

- `Convert` top-left header reads like metadata instead of a real screen title
- `Charts` top-left header is too small relative to the chart card content
- `Settings` feels larger and more conventionally structured than the other tabs
- secondary utility text is often near the lower limit of comfortable readability
- Spanish strings make the small-text problem more obvious on Android

Reference screenshots captured during review:

- iOS: `.tmp/screens/ios/01-convert-221232.png`
- iOS: `.tmp/screens/ios/02-charts-221234.png`
- iOS: `.tmp/screens/ios/03-settings-221237.png`
- Android: `.tmp/screens/android/convert-review.png`
- Android: `.tmp/screens/android/charts-review.png`
- Android: `.tmp/screens/android/settings-review.png`

## Desired Outcome

- all three tabs use the same title pattern and visual rhythm
- freshness and update text remains visible but is clearly secondary
- small supporting text is readable without zooming or effort
- chart labels remain legible on smaller phones
- localized strings fit without making the layout feel cramped

## Implementation Plan

### 1. Normalize page headers

- introduce one shared tab-header pattern for `Convert`, `Charts`, and `Settings`
- give each screen a real title instead of relying on metadata-style copy
- move freshness/update text into a subtitle or status row below the title
- keep the top-right actions aligned with the shared header structure

### 2. Define a tighter type scale

- set one primary title size and weight for all tab screens
- set one secondary metadata size for freshness and status copy
- set one section-label style for rows like `Amount`, `3 shown currencies`, and
  settings section headings
- set one small-body style for exchange-rate helper text and chart support text

Suggested starting point for review, not a hard contract:

- page title: `20-24`
- subtitle / metadata: `13-14`
- section label: `12-14` with stronger contrast than today
- helper text / exchange-rate detail: increase by one visual step from current

### 3. Reduce cross-screen visual drift

- make `Settings` follow the same title and spacing rules as the other tabs
- preserve section grouping in `Settings`, but keep typography tokens shared
- ensure buttons and chips do not visually overpower informational labels

### 4. Check small-screen and localization fit

- verify the updated hierarchy on a small iPhone simulator
- verify the updated hierarchy on the Android emulator in Spanish
- confirm longer labels still fit in headers, rows, and chart summaries
- watch for truncation, crowded wraps, or tighter-than-intended spacing

### 5. Re-capture and compare

- rebuild the running iOS simulator app after the changes
- rebuild the running Android emulator app after the changes
- capture fresh screenshots for `Convert`, `Charts`, and `Settings`
- compare old vs new images for hierarchy, readability, and consistency

## Verification

Before calling the work complete:

1. run `./scripts/check.sh`
2. hot restart or reinstall the app on both emulators
3. capture fresh screenshots for all visible tabs
4. compare iOS and Android outputs side by side
5. confirm the top-left header no longer looks undersized on `Convert` and `Charts`
6. confirm `Settings` no longer feels like a separate typography system

## Out Of Scope

- new navigation structure
- new monetization flows
- chart feature changes
- content rewrites outside of clarity adjustments needed by the new header pattern

## Risks

- larger text can crowd the top area and reduce content density
- chart labels may require separate tuning from general app text
- localized strings may wrap differently across iOS and Android
- shared typography changes can expose spacing problems in unrelated widgets

## Recommended Execution Order

1. update shared typography tokens or shared header widget
2. apply the new header pattern to `Convert`
3. apply the same pattern to `Charts`
4. align `Settings` to the same title scale and spacing rules
5. tune the smallest helper text only after the main hierarchy is stable
6. verify on both emulators and re-capture screenshots
