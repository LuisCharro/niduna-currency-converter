# Phase 3 UI/UX — reviewed implementation dossier

## Authoritative review — Astra, 2026-09-11

Read this section first. It supersedes the original observations retained below.
**Status: B1–B4 implemented and visually verified; B5 measured with no code change; B6 verified; B7 deferred.**
The batches below were the recommendations used for the Terra execution recorded
later in this document; the execution record is authoritative for their final status.
The current authorization covers this document and the companion badge document.
The brand refresh plan is the scope boundary; Phase 1 icon/splash and Luis's
website updates remain completed context.

Baseline: branch `codex/ui-freshness-and-brand-assets`, HEAD `f60ee97`.
The primary used Astra Medium, directly inspected code and images, and coordinated
two native Luna Medium workers: one for asset/tooling facts, one for UI code claims.
Workers were read-only. The primary owns these decisions and consolidated both docs.

### Why the previous work order changes

Several old observations came from code 1 and were promoted too quickly into bugs.
The preceding Luna summary also overstated confirmation of ad overlap and range
padlocks. Current evidence does not support implementing those fixes as written.
Preserving these corrections is part of the handoff: Terra must not repeat them.

Recommended order: **B1 chart unit clarity → B2 dark system chrome → B3 Lens
presentation → B4 chart readability → B5 measured action polish**, with B0
verification first. Stream A can proceed independently except during device use.
No P0 was established; distinguish correctness, readability and optional taste.

## Evidence and limits

- Source inspected at `f60ee97`; no app source was edited.
- Device: `Medium_Phone`, `emulator-5554`, API 36, 1080×2400 pixels, density
  420 (approximately 411×914 logical pixels), font scale not changed in this pass.
- Installed package `com.honestfern.currency_converter`: versionName `0.1.0`,
  versionCode `2`, lastUpdateTime `2026-09-11 12:02:14`.
- No APK hash/build-to-HEAD match was performed. Source findings and installed-app
  observations are separate evidence. Rebuild provenance is a B0 prerequisite for
  final implementation acceptance, not a claim already satisfied here.
- Historical `/tmp/openclaw/emu-shots-2/` captures are from code 1; useful history,
  not the current build or proof of current providers, consent or release status.
- Primary rechecked the four tabs across this conversation, including fresh dark
  Favorites, scrolling to final Favorites/Settings content, swipe rail, long-hold
  Lens and chart touch inspection. No purchases, ad clicks, cache clearing, favorite
  deletion, release submission or provider changes were used for this review.
- Empty/loading/error/offline states, TalkBack, small screen, enlarged text and all
  five locales remain implementation QA gates. Do not mark them passed from code.
- A worker reported 68 targeted tests passed; this is supplementary worker evidence,
  not a primary-verified full `scripts/check.sh` run for this documentation task.

Current evidence root: `.tmp/screens/android/`. Preserve selected captures if moving
the handoff; temporary files are not durable release artifacts.

| Capture | Observed result |
|---|---|
| `astra-convert-165411.png` | Current light Convert, readable SOL wordmark but weak badge; explicit daily source date |
| `astra-convert-scroll-165433.png` | Rates continue scrolling in their own viewport above the footer |
| `astra-favorites-bottom-165434.png` | Full limit block and upgrade action reachable above footer |
| `astra-settings-bottom-165435.png` | Restore/About/Version reachable above floating nav |
| `astra-swipe-165507.png` | Current saved-state rail: Remove / Saved / Base |
| `astra-dark-settings-verified-165617.png` | Black status icons on dark background; themed Clear control |
| `astra-dark-favorites-verified-165618.png` | Dark Favorites, value pills, limit block and ad footer |
| `astra-lens-longhold-165657.png` | Lens opens after long hold; `100.`/`1,000.` formatting; Use label |
| `astra-chart-held-165721.png` | Touch overlay works; wrong base symbol and unsigned negative absolute delta visible |
| Earlier `context-charts-164156.png` / `context-charts-dark-164214.png` | Both chart themes, six-decimal rate, no Y labels, normal 1W–2Y ranges |

Do not use `astra-settings-dark-165539.png` or `astra-favorites-dark-165539.png`
as app evidence: they captured the launcher after Back exited the app. The earlier
`astra-lens-*` attempts did not open the Lens; only the longhold capture above did.
The touch overlay disappears on release, so a post-tap screenshot alone cannot
prove absence of inspection.

## Adjudication of original findings

Numbers refer to the original issue list retained below. `Confirmed` describes
evidence, not automatic authorization to implement a preferred solution.

| Original claim | Current decision / action |
|---|---|
| #1 SOL broken | Confirmed weak visual treatment, not missing asset; Stream A owns it |
| #2 no Y values | Confirmed by `chart_line_plot.dart:145-149`; B4 readability improvement |
| #3 chart hardcodes six decimals / must obey Settings | Incorrect explanation: `formatChartValue()` adapts to magnitude; keep useful rate precision; B4 may improve trailing zeros |
| #4 no year | Confirmed: axis uses `d MMM`, tooltip `EEE d MMM`; B4 contextual year treatment |
| #5 intraday padlocks | Refuted: `range_selector.dart:24-30` filters those ranges; never reintroduce them |
| #6 small negative changes should lose coral | A design preference, not a defect; preserve directional semantics and thresholds |
| #7 banner overlaps all four screens | Not reproduced as final-content occlusion; footer occupies a separate Column child; Settings does not use that ad footer |
| #8 Settings final row hidden | Refuted in current large-device scroll; Version reachable |
| #9 remove decimal options 5/6 | Rejected in visual scope; cash minor units do not define useful exchange-rate precision; preserve stored preference domain 2–6 |
| #10 Clear black / lacks confirmation | Refuted: themed control; `requestClearCache` opens confirmation; optional target/style polish only |
| #11 feedback missing | Not part of selected scope; new support flow deferred |
| #12 Favorites hint clipped | Initial viewport clip is scroll boundary; full block reachable; no blanket padding fix |
| #13 currency chip needs hint | Existing chevron supplies affordance; defer extra copy |
| #14 chart inspection absent | Refuted by code and live held-point capture |
| #15 Pin quiet | Saved state is visibly green; re-test UNSAVED state before restyling; B5 |
| #16 no swipe discovery | Localized empty-state hint exists; discoverability still a UX question, not absent copy |
| #17 Convert remove lacks undo | Confirmed code; removing a displayed row is reversible through picker; new undo is interaction work, deferred |
| #18 reverse swipe unused | Refuted: closes open rail; do not assign a new gesture |
| #19 normal tap does not open Lens | Confirmed for visual touch; semantic action exists; altering tap behavior is deferred interaction change |
| #20 Use ambiguous | Confirmed editorial issue: it sets base amount then dismisses; B3 clearer localized label |
| #21 title wraps | Not reproduced on large device; B3 compact/enlarged-text verification, no automatic renaming |
| #22 all Lens precision must obey Settings | Rejected as automatic fix; specific dangling decimal and label consistency are B3 |
| #23 arbitrary targets | Source defines fiat 10/50/100, BTC .001/.01/.1 and other crypto .01/.1/1; keep presets |
| #24 long press is Android-only | Unsupported assertion; remove platform claim and proposed swipe-up behavior |
| #25 switch other currency in Lens | New interaction; deferred |
| #26 Pin shortcut in Lens | New interaction; deferred |
| #27 copy target looks 24 px | Icon pixels do not establish hit size; inspect actual IconButton bounds before changing |
| #28–31 fetch time/next update/Premium proposals | Old copy conflicts with current freshness work; preserve daily/provider-date semantics and no future-Premium upsell |
| #30 no manual refresh | Refuted: current Convert has refresh affordance; do not add fake Try now behavior |
| #32 drag-dismiss assumed | Lens uses `showGeneralDialog`; verify actual route's dismissal, do not generalize bottom-sheet behavior |
| #33 tooltip duplicate | Optional copy only after current string check; not a blocker |
| Add currencies vs Open Convert must match | Different action roles can legitimately use different emphasis; B5 only if same-role inconsistency reproduced |
| Favorites undo snackbar blocks empty state | Refuted in inspected current removal path: no undo snackbar there; empty-state test remains pending |
| Test ad proves production IDs unfinished | False inference; test creative is not release/configuration evidence |

`DESIGN.md` also mixes historical descriptions with current intent: floating-nav
clearance is shared metrics, not an extra hardcoded 100 px; accepted Favorites
cards/value pills and Convert amount panel should not be removed merely because
an older paragraph says no cards. Preserve intentional asymmetry. Update only
the design sections touched by an approved future batch.

## Visual direction for implementation

The primary job is reading/converting an amount quickly. Preserve warm paper,
forest/moss, Manrope body/numbers and Fraunces headings. Keep the four-tab order,
existing amount hierarchy, restrained separators and deliberate Favorites value
pills. Existing cards/panels are baseline, not permission for a structural rewrite.

Use spacing/type/color tokens and shared components; no decorative backgrounds,
new logo chrome, gradients added for novelty, or family-wide badge replacement.
Main amount remains dominant; chart labels explain the data without overwhelming
the plot. Use semantic currency codes where a symbol is ambiguous.
Design dials: low layout variance, restrained existing motion, medium data density.
Increase legibility before adding copy or shrinking text. No `DESIGN_GUIDELINES.md`
was found/created during this review; `DESIGN.md` remains the design reference.

## Executable batches for Terra

### B0 — provenance and acceptance setup

**Required before implementation QA.** Inspect status/HEAD, preserve unrelated
changes, and read the repo Flutter verification/emulator skills. Select the
approved batch explicitly; do not execute the historical issue queue.

Record installed version, device, theme, locale, font scale, base/amount, ads and
entitlement state. Rebuild current source using the repo Android wrapper with
`PROVIDER_PROFILE=release_safe` and `APP_DEV_MODE=false`; preserve existing app
data unless a fresh QA state is explicitly selected. Code 2 does not uniquely
identify local bytes. Record the artifact hash and source revision used.

Do not change providers or production ad configuration to obtain screenshots.
Use deterministic fixtures for data-sensitive widget checks. Do not claim a
running APK is a Play-accepted candidate. Stop on a source/build mismatch that
prevents reproducing the selected issue; resolve it before guessing at a fix.

### B1 — truthful chart units and signed change

**Priority P1; confirmed presentation defects. Dependency B0.**
Current USD/EUR chart shows `$ 0.862660`; the numeric value is EUR per one USD.
`chart_header.dart:32,62` selects the base symbol. `charts_chart_section.dart:134`
passes the base symbol into the touch overlay too. `chart_touch_overlay.dart`
uses `absoluteChange.abs()` but supplies an empty negative sign, so a falling
point can show a positive-looking absolute amount beside a down percentage.
Primary verified this in `astra-chart-held-165721.png`.

Proposed presentation: explicitly label the rate `1 USD = 0.862660 EUR`
(precision may be compacted in B4), or an equivalent localized layout with the
same unambiguous unit. Use quote code/unit for chart point values and absolute
deltas. Show `−0.003520 EUR` for a negative delta, `+…` for positive, neutral zero.
Keep pair selection, inversion, provider values and percentage math unchanged.

Expected files: `chart_header.dart`, `charts_chart_section.dart`,
`chart_touch_overlay.dart`, `rate_chart.dart` for the quote-unit presentation
parameter passed through to the overlay, `chart_metric_rail.dart` and its caller
`charts_tab_body.dart` if explicit High/Low unit context is added, and localization
files for any added sentence. Paths here and below
are under `lib/src/features/charts/widgets/` unless otherwise specified.

Acceptance: USD→EUR, EUR→USD, USD→JPY and fiat/crypto examples display the correct
quote unit; swapping updates unit and value consistently. Header, High/Low context
and tooltip agree. Positive/negative/zero delta cases read correctly; no numerical
data or entitlement changes. Add focused widget/unit assertions that would catch
the previous wrong symbol and missing minus sign. Capture both themes with a
touched point; confirm long number plus percent does not overflow compact width.
Stop if fixing the display would require changing rate calculation or repository
data. Escalate that as a separate logic task.

### B2 — Android system-bar and dark affordance legibility

**Priority P1; status-bar defect confirmed, other contrast concerns need measurement.**
Fresh dark captures show black time/network/battery icons against dark forest.
Current `app_shell.dart:180-210` switches a local Theme; no explicit
`SystemUiOverlayStyle` match was found in `lib`. Root `app.dart` supplies light
theme. This is a likely integration cause, not proof that every Android build
behaves identically.

Expected files: `lib/src/app_shell.dart`, `lib/src/app.dart` or a small focused
theme wrapper; `lib/src/core/theme/app_colors.dart` only for measured app-control
contrast issues. Choose one owner of system-bar style and follow Android edge-to-edge
behavior; do not introduce competing global setters on every tab.

Acceptance: readable system icons after launch, switching both ways, changing tabs,
opening/dismissing Lens and Settings detail. Preserve gesture inset/layout and
current system-bar backgrounds. Verify screenshots at native size on large and
small Android. Inspect moss-on-forest Add currencies/nav/muted labels separately;
measure token pairs before brightening the whole palette. Record results, not an
unmeasured accessibility-pass claim. No change to persisted theme semantics.
Stop if the remedy requires an SDK/target upgrade or platform migration.

### B3 — Lens numerical typography and action wording

**Priority P2; confirmed display polish. Dependency B0.**
`astra-lens-longhold-165657.png` shows `100.`, `1,000.` and `738. GBP`.
`conversion_lens_positioner.dart:67-76` derives fiat digits by magnitude
(`>=100`: zero; `>=10`: two; otherwise three), but constructs a decimal point
even for the zero-digit case. The current label `Use` sets the base
amount and dismisses, as shown by `conversion_lens_reverse_target.dart:44-53`.
The large-device title fits; no demonstrated title-overflow bug is asserted.

Expected files under `lib/src/features/convert/widgets/`: `conversion_lens_positioner.dart`,
`conversion_lens_reverse_target.dart`, `conversion_lens_quick_values.dart` only
for label layout. Wording route is `core/localization/ui_copy_convert.dart`
(`useActionLabel`) and its consumers; add consistent translations in the existing
localization system rather than editing generated files by hand.

Proposed result: zero-decimal display uses `100`/`1,000`, never dangling punctuation;
action says `Set amount` (with equivalent EN/DE/ES/IT/FR copy). Keep existing
precision thresholds, reverse presets, calculation and `formatLensInput` behavior.
Scope of this batch is presentation; input rounding is not silently changed.

Acceptance: fiat values below/above 10 and 100, including 100, 738 and 1000,
crypto and current
amount rows retain meaningful values; existing Use behavior remains unchanged.
Add a focused formatter regression for integer punctuation and preserve the
existing Lens amount-update test. Review large/compact, 1×/1.3×/2× text, long
German/French wording, copy/close target bounds, and internal scrolling. Make
controls wrap/reflow if needed, not tiny text. Verify long hold still opens Lens
and reverse swipe still closes a rail. Stop if label changes require a new route,
gesture, favorites shortcut or changed calculation.

### B4 — readable chart scale, date context and precision

**Priority P2; proposed design improvement. Dependencies B0 and B1.**
The chart reserves a large plot but omits numeric Y labels. X ticks and tooltip
omit the year even for 1Y/2Y. Current adaptive formatter is intentional and tested;
rounding all values to the Settings default of two decimals would collapse small
rates and conceal useful differences.

Expected files: `chart_line_plot.dart`, `chart_touch_overlay.dart`,
`chart_value_formatter.dart`, `chart_metric_rail.dart` if needed, and related tests.
Choose a bounded presentation strategy: 2–3 non-overlapping Y labels, consistently
in quote units; compact ticks for short ranges; a visible date-range year context
for multi-year views; full localized date including year in touch details. Do not
put a long year on every daily tick. Preserve useful plot width at 360 logical px.

Keep adaptive magnitude precision. Optional trailing-zero reduction is a distinct
substep: e.g. `0.862660 → 0.86266`, preserving `0.00001984` and nonzero tiny deltas.
Do not wire the cash-amount preference into every rate surface. Existing
`test/chart_value_formatter_test.dart` documents useful small-value precision;
update it only with explicit equivalent-information expectations.

Acceptance: 1W/1M/1Y/2Y, cross-year data, flat series, one/two points, very small
crypto, large fiat, positive/negative deltas; no division-by-zero interval, overlapping
ticks or misleading identical labels on distinct levels. Existing touch inspection
continues working. Test date/label policy and edge cases; inspect rendered large/
small charts in both themes and enlarged text. Stop if labels force reduced legibility
or a chart-library upgrade; revise the layout within current primitives instead.

### B5 — restrained actions and touch targets

**Priority P2, conditional on current reproduction. Dependency B0.**
Review UNSAVED Pin separately from Saved. Current saved-state rail is already
green and readable. Preserve Remove / Pin / Base order and gestures. If the
unsaved state is weak, give it a subtle semantic moss surface and clear outline;
do not make every action a competing primary button.

Expected files: `features/convert/widgets/swipe_action_widgets.dart`;
`features/settings/widgets/clear_cache_tile.dart` for a measured minimum target
issue; `shared/widgets/pill_action.dart` / `features/convert/widgets/rates_section_header.dart`
only if an actual same-role inconsistency warrants shared tokens.

Clear may remain a secondary themed control; confirm actual target dimensions,
aiming for 48×48 logical px without widening the whole tile or demoting Cancel in
the existing confirmation. Keep Open Convert's navigational/empty-state emphasis
distinct from Add currencies if their roles justify it. A plus icon on navigation
can be reconsidered as optional wording/icon polish, not evidence of a defect.

Acceptance: saved/unsaved, both themes, large/small, localized labels; no callback,
limit, purchase, removal or gesture behavior changes. Add targeted geometry tests
only when correcting measured target regressions. Stop if the proposed fix requires
new undo, tutorial, navigation or monetization behavior; put it in B7.

### B6 — bottom viewport and state verification

**Verification batch, not a pre-approved padding fix.**
`shared/widgets/bottom_tab_frame.dart:13-25` allocates body/footer separately;
`features/convert/widgets/ad_support_shelf.dart:15-31` reserves nav clearance.
Settings/Favorites also use `AppTheme.tabScrollBottomPadding` from
`core/theme/app_decorations.dart:44-50`. Padding in both places may warrant
measurement of wasted space, but does not justify another banner-height inset.

Test final item reachability, taps above gesture area, ad loaded/loading/no-fill/
hidden states, and compact/enlarged text. Current large Favorites and Settings
reach the bottom. A blank reserved ad slot is not proof of overlap or a mandate
to collapse the slot. Keep consent/ad requests and paid entitlements unchanged.
Expected inspection files: the shared frame/shelf/padding helpers plus actual tab
bodies. Only open an implementation task after recording a specific failing state
and geometry; change the owning shared layer, not four magic-number paddings.

Empty Favorites, loading, cached/offline, stale and error states need controlled
fixtures or an isolated QA state. Do not delete user data merely to reach them.
Report unavailable states explicitly; no false complete-audit checkmark.

### B7 — deferred product/interaction decisions

These require separate selection because the refresh plan preserves navigation,
storage and feature behavior: undo for Convert/Favorites removal; tap-to-open Lens;
first-use tutorial; new feedback/support entry; Lens Pin/swap shortcuts; new
refresh actions; changing decimal preference domain; trend thresholds; AUD grouping.
Do not bundle them into styling commits. Existing localized discovery copy,
chart inspection, reverse-swipe close, and clear confirmation must be preserved.

## Execution, acceptance and handoff protocol

1. Luis selects batch IDs. Terra executes one coherent batch at a time; A1/A2
   asset work can be independent of UI code. One agent controls the emulator.
2. Cheap read-only workers may locate files/tests or independently inspect a
   bounded concern. Primary owns visual direction, integration and final evidence.
   One writer per overlapping widget/document group; B1/B4 are sequential.
3. Before editing, list exact paths and baseline screenshots for that batch.
   The paths above are a starting scope, not permission to rewrite entire folders.
4. Preserve rates/providers, billing, consent/ads behavior, preferences/storage,
   four-tab navigation, supported codes and feature limits. No backend, SDK upgrade,
   icon/splash regeneration, website work, version bump or store submission.
5. Follow existing module boundaries and repo size rules; avoid opportunistic
   refactors. B1 unit labels and B3 punctuation are presentation changes only.
6. Run relevant focused tests and required `./scripts/check.sh` after code work.
   Rebuild/restart the selected Android app and inspect actual before/after images.
   Do not infer visual acceptance from a passing test or worker summary.
7. Minimum visual matrix for selected changes: Medium_Phone and
   Small_Screen_API_36; light/dark; 1× and enlarged text; EN plus long translated
   labels and EN/DE/ES/IT/FR copy review; ad visible/hidden where relevant. Preserve
   current device/preferences or record intentional QA-state changes.
8. Each batch closeout records ID/status, files, tests, source/artifact provenance,
   screenshots, acceptance criteria passed, remaining concerns and rollback scope.
   Update this authoritative section, never append contradictory unchecked claims.

Stop on unrelated state changes, a need for business-logic edits, unavailable
evidence for a claimed defect, or a visual regression in the compact/theme matrix.
Document the specific blocker and retain the last accepted behavior. Completion
means the selected batch is verified, not that every optional idea was implemented.

## Execution record — 2026-09-11

**Source closure.** The approved B1–B6 implementation and its regression tests
are committed as `c08ec70` (`feat: polish chart presentation and system UI`).
The documentation closeout remains separate so that the implementation SHA is
an explicit, stable provenance reference.

**B0 — completed.** Source revision was `f60ee97`; the verified debug artifact
was built with `PROVIDER_PROFILE=release_safe` and `APP_DEV_MODE=false` (APK
SHA-256 `e64f8e7a924245391696339f08441c59a32ba9a8f4b2b567b04265602b168620`).
No provider, billing, consent implementation, feature limit, version or release
configuration changed. The fresh local emulator selected “Do not consent” only to
dismiss the test-consent screen for UI inspection.

**B1 — completed.** `ChartHeader` now states `1 USD = 0.862660 EUR`; chart
touch overlays and High/Low values use the quote code, and a falling absolute
delta includes a real unicode minus (`−0.008840 EUR` in the verified touch
capture). Focused regression tests cover the prior wrong-unit and missing-minus
cases. Pair math, range values and percentage calculation remain unchanged.

**B2 — completed.** `AppTheme.systemOverlayFor` and the shell's annotated region
set dark icons over light surfaces and light icons over dark surfaces. The large
dark Settings capture shows readable white status icons after a live theme switch.
No app palette token was globally brightened.

**B3 — completed.** Integer Lens values now render `100` and `1,000`, not
`100.`/`1,000.`, while the existing magnitude precision remains. Reverse-target
actions now read “Set amount” through the existing EN/DE/ES/IT/FR copy route.
The long-hold Lens was inspected live in dark mode; its existing set-amount
behavior was preserved.

**B4 — completed.** The plot has a restrained left Y scale (three compact labels)
with a vertical quote-code axis title, date ticks include a year only when the
visible data crosses years, and touched dates now carry their full year. This keeps
the unit explicit without putting a long code beside every tick. Cross-year/date
and Y-label coverage is in `test/chart_axis_labels_test.dart`; the large 1M
USD/EUR captures show readable Y ticks and `EUR` unit context without reducing plot
usability. Adaptive rate precision was intentionally retained.

**B4 Tetris refinement — completed.** Following live review on Medium_Phone,
the redundant vertical `EUR` title was removed because the header, pair controls
and metric rail already establish the quote unit. `Checked Sep 11` now occupies
the free space to the right of `Charts`, preserving freshness without consuming a
separate row. The Y axis hides its boundary labels and retains two internal
reference values, so the upper label cannot collide with the range selector.
The rate/trend row uses a wrapping layout to prevent a compact-width overflow;
focused tests cover the compact English header, hidden bounds and missing unit.

**B4 crypto-density refinement — completed.** The title/freshness row now spans
the full available header width, so `Checked Sep 11` is truly right-aligned rather
than stopping before the swap control. Full adaptive precision remains in the
header and touched value. High/Low use a separate three-significant-digit compact
formatter and omit the redundant quote suffix because both adjacent selectors
already establish the unit. Small Y labels use a one-line, clipped layout with
tighter type/padding, preventing the prior two-line crypto tick in the layout
path. The same final APK was installed and hash-matched on both Android emulators;
the user-owned live EUR/BTC visual review remains the final acceptance check.

**B4 temporary-unlock badge correction — completed.** A chart pair's 24-hour
rewarded entitlement remains pair-level and canonical, but its `24h` indicator
is now rendered once beside the restricted currency when exactly one side is
restricted, regardless of whether it is base or quote. This prevents a free USD
or EUR selector from incorrectly appearing time-limited beside a temporarily
unlocked BTC pair, including after inversion. When both currencies are
restricted, one deterministic quote-side marker represents the pair rather than
duplicating it. The controller, persisted entitlement and picker access rules
were unchanged. Widget regression tests grant real temporary USD/BTC and
BTC/USD unlocks through the controller and assert the badge remains with BTC in
both directions. `./scripts/check.sh` passed; the debug `release_safe` APK with
`APP_DEV_MODE=false` (SHA-256
`4952ff640318bf010791346d2f0ceb002e038f93ad504ab65be5054c2bd8a92c`) was
installed over the existing app data on both Android emulators. Small-screen
USD/EUR visual verification confirms neither free default selector shows `24h`.

**B4 header action consolidation — completed.** The redundant swap action was
removed from the chart masthead; the single remaining swap stays between the
base and quote selectors where its effect is local and explicit. The header rate
and trend chip now fill the available row: on wide layouts the chip aligns to
the trailing content edge, while `Wrap` moves it below the rate when a compact
viewport cannot fit both. Widget coverage asserts the masthead has no swap icon
and the wide trend chip reaches the content edge. `./scripts/check.sh` passed;
the replacement debug `release_safe` APK with `APP_DEV_MODE=false` (SHA-256
`bf9c21a938d2f27205de7b8d98d0a7ac25edf3498aace3f8153e881377d1e11c`) was
installed over existing data on both emulators. Visual captures confirm the
large and small Chart layouts preserve a single swap and readable trend chip.

**B5 — completed with no change.** Source and live inspection show the unsaved
action is already an outlined star labelled Pin, while the saved action is a
filled star labelled Saved with the semantic primary/moss treatment. This meets
the conditional criterion without competing action treatments. No Clear geometry
failure was reproduced.

**B6 — completed.** `Medium_Phone` (`emulator-5554`, 1080×2400 at 420 dpi) was
checked in light Convert, light Chart/touch, dark Settings and dark Lens states.
`Small_Screen_API_36` (`emulator-5556`, 720×1280 at 320 dpi) was checked in light
Convert. The navigation/gesture area and reserved ad shelf did not obscure the
reachable content in those inspected states. The compact emulator initially
needed an explicit Activity launch after install, but its final top-resumed
Activity and capture were the installed app; this was an emulator launch quirk,
not a product crash. Uncontrolled empty/loading/offline/ad-no-fill states remain
explicitly unverified.

**Evidence and checks.** New focused tests are
`test/chart_presentation_test.dart`, `test/chart_axis_labels_test.dart`,
`test/app_system_ui_test.dart` and `test/conversion_lens_format_test.dart`, plus
updated existing widget coverage. `./scripts/check.sh` completed with no analysis
issues and its full test suite green. Key captures are:
`terra-release-safe-convert-light-171915.png`,
`terra-release-safe-final-chart-units-214042.png`,
`terra-release-safe-final-chart-touch-year-214044.png`,
`terra-release-safe-settings-dark-172009.png`,
`terra-release-safe-lens-dark-held-172034.png`, and
`terra-release-safe-small-active-213654.png`, plus the restored state in
`terra-release-safe-closeout-light-convert-214146.png`, under `.tmp/screens/android/`.

**B7 — deferred unchanged.** Undo, tutorials, new Lens shortcuts, support,
refresh, trend or navigation work remains outside this completed presentation
batch. No commit, push, version bump, store submission or website change follows
from this execution record.

The following is historical closeout context from the planning review, not a
claim about the execution record above: the prior emulator review had restored
light Convert with USD/100 (`astra-final-light-170311.png`). This execution also
restored `Medium_Phone` to light Convert, USD base and amount 100
(`terra-release-safe-final-light-convert-213840.png`). The documents preserve
historical observations below so corrections remain traceable without becoming
future instructions.

## Historical audit — retained for provenance, not execution

The original findings and proposed order below are superseded by the adjudication
and batches above. In particular, do not implement old blanket padding, intraday
padlock, decimal trimming, missing-inspection or missing-confirmation proposals.

### Original title: Phase 3 UI/UX remarks — 2026-09-11

> **Status:** observations only. Pairs with `brand-and-ui-refresh-plan.md`
> Phase 3 ("UI polish"). **This is Stream B** — the UI/UX work stream.
> Stream A (icons / currency badges) lives in
> `phase2-currency-badge-audit-2026-09-11.md`.
>
> **Method:** six passes.
>
> **Branch (2026-09-11):** `codex/ui-freshness-and-brand-assets` @ `f60ee97`.
> 1. **Light pass** — four screens via `adb screencap` (Pixel 7 AVD).
> 2. **Dark pass** — same four screens (toggle located via `uiautomator`).
> 3. **Sub-state pass** — Add currencies sheet scrolled into crypto
>    section, base-currency picker, "About" section revealed on Settings
>    scroll, developer/debug section discovered.
> 4. **Code pass** — `convert_quote_builder.dart` formatter, the
>    `app_preferences.dart` store, the chart's
>    `chart_value_formatter.dart` + `chart_header.dart`, and the badge
>    widget `currency_flag_icon.dart`.
> 5. **Discoveries pass** — Settings scrolled to the bottom revealed
>    developer/debug section + About section; Favorites Pro cap (16
>    pairs) confirmed; SOL badge observed broken at picker size.
> 6. **Convert row interactions pass** — swipe-left reveals
>    **Remove · Pin · Base**; long-press opens **Conversion Lens**
>    sheet. SOL badge observed broken in both states.

## What the plan mandates (verbatim)

> *Phase 3 — UI polish.*
> *Capture Convert, Favorites, Charts, and Settings in light/dark mode after
> the brand assets settle. Rank visible problems by user impact, then
> propose narrow changes to hierarchy, spacing, icon consistency,
> empty/loading/error states, and small-screen behavior. Explain each
> problem and proposed solution before changing the interface. Keep the
> existing warm paper, forest, Manrope/Fraunces, and dividers-not-cards
> system.*

Three operative gates: (1) rank by user impact, (2) keep changes narrow,
(3) problem→solution on paper first.

## Artifacts (cumulative across passes)

Saved at `/tmp/openclaw/emu-shots-2/` (and `/Users/luis/.openclaw/
workspace/drafts/emu-shots-2/`). Selected:

| File | Screen / Mode | What it confirms |
|---|---|---|
| `01-convert-light.png` | Convert light | Trend arrows (red ↓ <1%) visible |
| `04-settings-light.png` | Settings light | Last row "F..." cropped by gesture bar (looked like Feedback) |
| `07-charts-dark.png` | Charts dark | Y-axis no labels; X-axis no year |
| `08-settings-dark.png` | Settings dark | "Clear" button stays heavy black |
| `11-convert-dark.png` | Convert dark | SOL broken (purple disc + white "SOL" text); BTC/ETH/SOL row text shows 8/6/6 decimals |
| `12-add-currencies.png` | Add currencies sheet | Region counts match source list (10/8/12/4/11) |
| `13-base-currency-picker.png` | Select base currency | ≈44 px circles; CHF readable; "kr" flags readable |
| `15-add-currencies-scrolled.png` | Add currencies scrolled into crypto | SOL still broken at picker size |
| `18-settings-bottom.png` | Settings scrolled to bottom | Developer/debug section + About section revealed (see "**Discoveries this pass**") |
| `20-settings-bottom.png` | Settings scrolled further | Data sources + Version row (`0.1.0 · DEV`) visible |
| `23-euro-swiped-right-y.png` | Convert, EUR row swiped left | Three quick actions revealed: **Remove · Pin · Base** (Pin near-invisible on white) |
| `25-longpress-euro.png` | Convert, EUR row long-pressed | **Conversion Lens** sheet: header restating rate, "Quick base amounts", "Reverse targets" with "Use" button |
| `26-longpress-gbp.png` | Convert, GBP row long-pressed | Same Conversion Lens shape, GBP-specific values |
| `29-info-longpress.png` | Convert, long-press on Fresh row | Tooltip: "Rates update once per day. Tap for details." |
| `33-dialog-capture.png` | Convert, tap on Fresh row | **"Daily exchange rates" sheet**: 📅 "Updated Sep 11" + ⏰ "Next around 4:00 PM local" + Premium hint footer |

## What the plan tells us not to touch

> *Keep the existing warm paper, forest, Manrope/Fraunces, and
> dividers-not-cards system.*

- Palette: `#F6F8EF` paper, `#285F3B` forest, `#6F8C49` moss, `#c98b28`
  amber, `#dc6543` coral. Inverts cleanly in dark mode.
- Type: Fraunces for headings, Manrope for body and labels.
- Composition rule: dividers-not-cards for content sections.

## Discoveries this pass (corrections + new)

### Discoveries, not previously documented

1. **Settings has a developer/debug section** (revealed by scrolling
   below "Charts Pro"). Toggles:
   - Subscription active
   - Remove Ads lifetime
   - Charts Pro lifetime
   - Favorites Pro lifetime (mentions "Save up to 16 favorite pairs")
   - Favorites boost (24h) — simulate rewarded ad
   - Chart temp unlocks — toggle off to clear all 24h pair unlocks
   - Ads: visible indicator
   Then "About" with **Data sources** (Frankfurter, ECB, crypto sources
   and chart availability) and **Version 0.1.0 · DEV**.
2. **`Favorites Pro` extends the cap from 3 to 16 pairs.** The
   "You can pin up to 3 pairs in this version." hint surfaces this
   distinction.
3. **`Chart temp unlocks`** — single switch that clears all 24h pair
   unlocks. Pair-specific locks exist via `chart_temp_badge.dart`.
4. **Swipe-left on a Convert RATES row** reveals three quick actions in
   a Material swipe-to-reveal panel: **Remove · Pin · Base** (left to
   right). Live captured at `/tmp/openclaw/emu-shots-2/23-euro-swiped-right-y.png`.
   Visual hierarchy: Base is the dominant green forest pill; Remove is
   a soft-coral `⊘`; Pin is a near-invisible white background with a
   gray outlined star.
5. **Long-press on a Convert RATES row** opens a **Conversion Lens**
   bottom sheet titled in Fraunces. Sections: header repeating
   "100 USD = 86.01 EUR" + copy icon + close X; "Quick base amounts"
   table (1.000 / 10.00 / 50.00 / 100. / 1,000. → EUR equivalents);
   "Reverse targets" table (10 / 50 / 100 EUR → USD with a green
   "Use" button). Live captured at
   `/tmp/openclaw/emu-shots-2/25-longpress-euro.png` and
   `/tmp/openclaw/emu-shots-2/26-longpress-gbp.png`.
6. **Tap on the "Fresh · Updated Sep 11" row** (or the `(i)` icon next
   to it) opens a **"Daily exchange rates" bottom sheet**. Title in
   Fraunces Bold. Body explains the free version updates once per day.
   Two icon rows: **📅 "Updated Sep 11"** + **⏰ "Next around 4:00 PM
   local"**. Footer text: "The next expected update is shown in your
   local time." + "Faster updates are planned for a future Premium
   subscription." A long-press on the row first surfaces a tooltip
   "Rates update once per day. Tap for details."; the actual tap opens
   the sheet. Live captures:
   `/tmp/openclaw/emu-shots-2/29-info-longpress.png` (tooltip) and
   `/tmp/openclaw/emu-shots-2/33-dialog-capture.png` (sheet).

### Corrections to my own previous findings

- **"BTC/ETH/SOL rows ignore Decimal places: 2"** (pass 3 finding #3
  expansion) — was wrong. Read
  `convert_quote_builder.dart`:

  ```dart
  int _cryptoDigits(String code) {
    if (code == 'BTC') return 8;
    if (code == 'USDT' || code == 'USDC') return 2;
    if (code == 'DOGE') return 4;
    return 6;  // ETH, SOL, XRP, ADA, AVAX, BNB, MATIC
  }

  String _formatAmount(double value, String code, int decimalPlaces) {
    final digits = isCryptoCurrency(code) ? _cryptoDigits(code) : decimalPlaces;
    return NumberFormat('#,##0.${'0' * digits}', 'en').format(value);
  }
  ```

  **The crypto branch is INTENTIONAL.** The user's `Decimal places`
  setting only controls **fiat**. The crypto precision is a per-coin
  property (BTC = 8, USDT/USDC = 2, DOGE = 4, everything else = 6).
  Visible behavior is by design, not a bug. Removing this from the
  defect list.

- **"Decimal places 5 and 6 are unusual for fiat"** — partly true.
  Real fiat maxes at 4 (JPY, KWD, BHD are 3), so 5 and 6 are dead
  picker options for fiat. They're not harmful — the picker
  validator (`isDecimalPlacesSupported` in `app_preferences.dart`) just
  requires `2..6`. Worth trimming the picker to 2..4 for fiat usage.
  Note: the **same 4-decimal smart formatter** (`decimalPatternDigits`)
  is used by Favorites, the Conversion Lens (`1 USD = 0.8601 EUR`),
  and the open of the lens (`100 USD = 86.01 EUR`). So **the user's
  Decimal places setting is effectively ignored everywhere except the
  fiat Convert RATES row and the chart value formatter** (which is its
  own bug, real and fixable).

## What works well — do not change

- Typography hierarchy, palette inversion in dark mode, bottom-nav
  pill, cards-vs-dividers, freshness copy, regional grouping sheet,
  "Add currencies" button becoming a green pill in dark.

## Issues, prioritized (ranked by user impact)

### P0 — visible bug

1. **Solana badge is broken on the Convert screen** (light and dark).
   See `phase2-currency-badge-audit-2026-09-11.md` P0 item 1.

### P1 — chart formatter bugs

2. **Y-axis has gridlines but no value labels.** Confirmed in both
   light and dark.
3. **Chart header ignores the user's "Decimal places" setting.**
   `chart_value_formatter.dart` has its own `digits` argument; the
   chart calls it with hardcoded `digits=6` (or similar). Live
   `USD/EUR` shows `0.860880` (six decimals) regardless of the
   user's setting (default 2). The chart also shows High/Low/Stats at
   six decimals (`0.867000`, `0.854770`). The change-percent pill
   correctly uses `toStringAsFixed(2)` — only the value formatter
   path is wrong. **Real bug, fixable in one formatter.** Note: only
   fiat-charts hit this; crypto values in the chart render through
   the same broken formatter.
4. **X-axis dates lack the year.** Easy fix.

### P1 — padlock discoverability (Charts Pro IAP)

5. Padlocked time ranges are too subtle. 1H / 6H / 1D show a small 🔒
   but free users may not realise they're gated. Add a "Pro" tag or
   dim the row.

### P1 — trend arrow color tier

6. **Red ↓ arrow for sub-1% changes** (light-mode capture:
   `Euro ↓ 0.09%`, `GBP ↓ 0.15%`, `JPY ↓ 0.05%`). Dark-mode
   capture showed no arrows — appears to be refresh timing (the %
   deltas happened to be near 0). **Re-test with a forced fetch
   before locking the threshold.**

### P1 — ad banner overlap

7. **AdMob banner overlaps the last visible list row** in Convert
   (SOL row clipped), Charts (stats), Settings (AD row + banner at
   the very bottom), Favorites (pin-count hint). One layout fix:
   add bottom padding to every scrollable list equal to the banner
   height. Or convert to `SliverList` with `EdgeInsets.only(bottom:
   bannerHeight)`. One PR covers four screens.

### P2 — settings polish

8. **Last Settings row that fits in the original viewport** (`F...`)
   was the first item of the developer/debug section. After scrolling
   it's clear the section has many toggles. **"Last item cut off by
   gesture bar" therefore wasn't a real bug** — the scrollable area
   continues and the content is all there. Reframe from "P2 — last
   item cut off" to "**add scroll-margin-bottom to keep gesture-bar
   chrome from hiding the final row**". Cosmetic.
9. **Decimal places options 5 and 6** — see "Corrections" above.
   Recommend trimming picker to 2..4 unless sub-cent pricing is
   product-critical.
10. **"Clear all data" button is heavy black** while the rest of the
    action vocabulary is forest-green pill. Add a confirmation dialog.
11. **No visible Feedback row** even after scrolling past About /
    Version. The developer-section UX is internal-only; user-facing
    feedback contact is absent. Out of scope for Phase 3 because the
    brand plan forbids adding new flows, but worth noting.

### P2 — favorites polish

12. **"You can pin up to 3 pairs in this version." hint** is clipped
    between the cards and the AdMob banner. Move to header context
    above the list. Add a "How does Favorites Pro work?" affordance
    pointing to the in-app toggle.

### P3 — micro-affordances

13. **Currency selector chip** has no "tap to change" hint.
14. **No tap-to-inspect on the chart line.**

### P3 — swipe-to-reveal row actions (Convert)

15. **"Pin" too quiet**. The Pin action (favorites — **positive** user
    value) has white background + gray outlined star — nearly invisible.
    The "Remove" action (destructive) has more visual weight than
    "Pin" despite opposite user value. Invert: Promote the Pin
    background (a moss-tinted green pill is consistent with the
    forest-family), demote Remove (push it further right, or keep the
    soft coral but make it smaller). Single asset swap, two-token
    tweak.
16. **No discovery hint for the swipe gesture**. New users won't know
    rows are swipeable. Add a one-time tutorial overlay (first launch
    only) or a subtle row-end chevron that animates on first scroll.
    Cheap fix.
17. **"Remove" is one tap from destruction**. No confirmation dialog,
    no undo snackbar verified. Either (a) add an undo snackbar with
    "Undo" action (10-second window), or (b) show a small confirmation
    modal. The swiped Remove button is the FIRST one the user
    encounters when they swipe left — high accident risk.
18. **Reverse-swipe behaviour unknown**. Swipe-right is wasted if it
    does nothing. Test and either remove the gesture (cleaner state
    machine) or assign a meaningful reverse action.
19. **Row tap (body, not on a swiped action) — does it open
    detail?** Untested. If not, the row is **swipe-only** — which
    most users will not discover. Add a tap action that opens the same
    Conversion Lens (long-press behaviour).

### P3 — Conversion Lens sheet (long-press row)

20. **"Use" label is ambiguous**. Tapping it does what? Sets the
    amount? Replaces USD/EUR roles? Adds the result to favorites?
    Without prior knowledge the user is guessing. Rename to "Set
    amount" or add an inline `?` tooltip that describes the action.
21. **Sheet title typography overflow**. "Conversion Lens" wraps on
    narrow widths. Try "Compare to EUR" or "Lens" + subtitle.
22. **Decimal places still ignored**. Same `decimalPatternDigits`
    formatter is used here (4 decimals for `1 USD = 0.8601 EUR`),
    even though Settings says 2. Consistent with the rest of the
    **fiat** smart-formatter surfaces. Chart fix propagates; this
    fix here would need a separate change.
23. **Why those specific Reverse targets** (10 / 50 / 100)? Looks
    arbitrary. If derived from user behavior, document; if static,
    surface the rule ("common denominations") in the sheet copy.
24. **Long-press gesture is Android, not iOS**. Users coming from iOS
    won't discover it. If Sheet was the goal, prefer **swipe-up** or
    **tap-and-hold equivalent** in user education. Or add a chevron
    up-arrow at each row tail to indicate "more info available".
25. **No way to switch the OTHER currency from this sheet**. Sheet
    always reads `<amount> USD = <computed> EUR`. To see "USD from
    EUR", the user has to long-press the USD chip in the AMOUNT card
    (TBD). Symmetry would help.
26. **No "Pin this pair" shortcut** in the sheet. The Conversion Lens
    is for a specific pair; an explicit "Pin EUR" affordance here
    would let users add favorites from the lens without going to
    Favorites tab first.
27. **Copy-icon hit target** is small (appears ~24 px). Functional but
    not generous. Optional polish.

### P3 — Daily exchange rates sheet (tap on Fresh row)

28. **"Updated Sep 11" lacks a timestamp**. Users wondering how
    stale the data is see only the date — not the time of last fetch.
    Time-formatted label ("Updated Sep 11 at 4:00 PM", or relative
    "Updated 14h ago") would be more useful. Cheap fix.
29. **"Next around 4:00 PM local"** is a soft commitment. If the
    server is delayed, users see a misleading "Next" indicator. Worth
    a "usually 4–5 PM" hedge copy.
30. **No "Refresh now" affordance**. The free version updates daily;
    users who'd like to retry today can only do so by restarting the
    app (`Refresh on open` setting, currently ON by default). An
    explicit "Try now" button — even if it actually waits a few
    hours — would let users feel in control. Optional; out of
    scope per the plan.
31. **Future-Premium mention is good copy** ("Faster updates are
    planned for a future Premium subscription"). Could be linked to
    the Charts Pro / Settings Premium IAP for discoverability.
32. **Dismiss button** — the dialog/sheet is dismissable by drag
    handle or by tapping outside (standard Material 3). The
    uiautomator dump shows a `Dismiss` semantic. Not a defect;
    worth a manual confirm during the Stream B UI review.
33. **Tooltip "Rates update once per day. Tap for details."** appears
    on long-press of the row. A short-term tooltip. **Already shows
    what the user is about to learn — good on-ramp**, but it
    duplicates the dialog title text. Tighten the copy if it survives
    the Stream B review.

### P2 — visual inconsistency between Convert's `+ Add currencies` and Favorites' `+ Open Convert`

Code-confirmed in this round:

- **`+ Add currencies`** (`lib/src/features/convert/widgets/rates_section_header.dart`):
  - `OutlinedButton.icon` with key `'open_currency_picker'`.
  - `foregroundColor: colors.primary` (forest text).
  - `backgroundColor: colors.container.withValues(alpha: .64)` (paper tinted).
  - `side: BorderSide(color: colors.border.withValues(alpha: .16))` (faint forest border).
  - **Visual: outlined forest on paper, `+` icon in the same color.**
- **`+ Open Convert`** (`lib/src/features/favorites/widgets/favorites_list_header.dart` + `favorites_empty_state.dart`):
  - Uses **`PillAction(emphasized: true)`** widget (`lib/src/shared/widgets/pill_action.dart`).
  - `colors.primary` background + `Colors.white` text + white icon.
  - **Visual: filled forest pill with white text.**

Two different visual languages for the same intent ("primary CTA: add
a currency to your list"). **Convert is ad-hoc outlined, Favorites
uses the shared `PillAction` widget — neither side uses the other's
tokens.** DESIGN.md defines a `pill-button` token (forest + white text
+ 14 px padding + `rounded.lg`) but no equivalent "outlined on paper"
token.

**Fix proposal**: add an `outlined-action-button` token to `DESIGN.md`
(forest text on paper-tinted background with faint forest border) and
apply it consistently. `rates_section_header.dart` should adopt it.
`PillAction` already handles its own styling; the two widgets should
agree on whether the same affordance ("add a currency to your list")
appears the same way in both screens. Sub-decision: should the
"sweep-the-user-toward-add" CTA be **outlined** (subtle, secondary
screen feels) or **filled** (anchor, primary action)? The current
visual split is a half-finished decision — pick one.

### P3 — locale has the swipe hint; the empty-state body uses it

- **`favoritesEmptyBody`** (in every `.arb` under `lib/l10n/`, including
  `app_localizations.dart`):
  - en: *"Swipe left on a currency row in Convert, then tap Pin."*
  - es: *"Desliza una fila de divisa a la izquierda en Convertir y toca Fijar."*
  - de: *"Wische eine Währungszeile in Umrechnen nach links und tippe auf Fixieren."*
  - it: *"Scorri a sinistra su una riga valuta in Converti, poi tocca Fissa."*
  - fr: *"Glisse une ligne de devise vers la gauche dans Convertir, puis appuie sur Épingler."*
- The string is used in `favorites_empty_state.dart:41`. **Good news**:
  the hint exists and is fully translated. **Bad news** (carried over
  from pass 5): the empty state is unreachable from a normal
  swipe-delete flow because the undo snackbar covers the bottom nav.
  Users hit the 3-pair limit naturally only after deleting favorites —
  which triggers the snackbar that blocks discovery of the
  `EmptyState` widget in the first place.

  The empty state is reachable two ways:
  - (a) **Fresh install** + decline the starter-favorites seed
    (`starter_favorites_seeded = true` prevents seeding), or
  - (b) **Integration test** with `favorite_pairs: []` seeded.

**Retraction of an earlier finding**: my pass 5 P3 #16 "no discovery
hint for the swipe gesture" was **wrong**. The hint copy exists in
the localized empty-state body (verified in `lib/l10n/app_de.arb` +
friends). The issue is **discoverability of the empty state itself**
(see (a)/(b) above), not absence of the hint copy.

## Could not verify this pass

- **Favorites empty state** (with 0 pinned pairs) — couldn't capture
  via taps in this round because removing a favorite triggers an undo
  snackbar that sits over the bottom nav and intercepts subsequent
  taps. Recommend: relaunch the app or use the "Chart temp unlocks"
  debug toggle (which has a similar UX challenge) and try again,
  OR wait for the snackbar to dismiss (10 s).
- **Offline / error / stale** states.
- **Accessibility** (TalkBack, font scaling, color-blind palette).
- **Onboarding** (app reopens to last state).
- **Trend arrow dark-mode verification** (re-take with forced fetch).
- **Settings bottom row** — captured `20-settings-bottom.png` ends at
  Version 0.1.0 · DEV. There may be one more scroll worth of content
  (legal, support email) that wasn't captured.

## What this fourth pass corrected

- **Pass 3's "Convert list crypto rows ignore Decimal places: 2"** is
  **intentional design**. Retracted. (Stream B doesn't own a fix
  here.)
- **Pass 3's "Settings bottom cropped" framing was partially wrong**:
  the cropped `F...` was the start of the developer/debug section,
  not a missed About row. Scrolled views show About is reachable.
  Rebadged as a "scroll-margin" polish, not a "missing content" bug.
- **Pass 2's "trend arrows hide in dark mode" was likely timing** —
  refreshed data, not mode-specific. Re-test before locking.

## What passes 5 and 6 added

- Discovered the **Settings developer/debug section** (Subscription /
  Remove Ads / Charts Pro / Favorites Pro / Favorites boost 24h /
  Chart temp unlocks / About / Version) via scrolling.
- Discovered **Favorites Pro caps at 16 pairs** (free tier 3).
- **Discovered swipe-to-reveal actions on Convert RATES rows** (Remove
  / Pin / Base). Pin prominence issue noted.
- **Discovered Conversion Lens bottom sheet** (long-press). Power-
  user feature; multiple polish opportunities called out.
- SOL badge broken confirmed in picker state AND in swipe/lens state
  — one asset fix covers all surfaces.

## Suggested order of work (Stream B — UI/UX)

Each item is a PR/commit. The plan requires problem + solution written
up before code lands.

1. **P1 layout — add bottom padding to scroll lists** = banner
   height. One PR covers Convert, Favorites, Charts, Settings.
2. **P1 formatter — chart `chart_value_formatter.dart` honour the
   user's `Decimal places` setting** (or hardcode `digits=4` for fiat
   charts). One PR.
3. **P1 chart axis — Y-axis labels + year on X-axis + padlock
   discoverability.** One PR.
4. **P1 trend color tier** — needs third capture first to lock the
   tier against a non-zero sample.
5. **P2 settings — decimal options trim + Clear-data restyle +
   scroll-margin-bottom.** One PR.
6. **P2 favorites pin-count relocation + Favorites Pro affordance.**
   Cheap.
7. **P3 swipe-to-reveal Pin prominence + Remove undo + tap-row =
   lens**. Single PR covering items #15, #17, #19.
8. **P3 lens sheet polish** (Use label, title overflow, reverse
   targets list justification, optional Pin shortcut). Cheap.
9. **P3 micro-affordances** (currency chip, chart tap-to-inspect).
   Optional polish.

## Notes

- The AdMob banner shown in all captures is a **test ad** — B4
  (production AdMob IDs) is still open per `RELEASE_CHECKLIST.md`.
  None of the Phase 3 findings are ad-driven.
- Captured APK is `versionName=0.1.0`, `versionCode=1`. There's a
  one-step lag from `0.1.0+2` (Play internal).
- The Settings developer/debug toggles exist because of how the build
  was scaffolded (ReleaseGate pattern from
  `monetization-access-rules.md`). They're internal; users on the
  Play build won't see them unless DEBUG is set.
- Companion file: `phase2-currency-badge-audit-2026-09-11.md` (Stream A).
