# UI Redesign — Niduna Currency Converter

## Design Direction (from skills)

- Product posture: a warm, privacy-first currency instrument panel — fast like a utility, crafted like an editorial finance notebook.
- First useful action stays immediate: enter amount / inspect rates / open a favorite / read a trend, without marketing copy or decorative chrome.
- Structural fingerprint: warm paper canvas + one decisive top instrument area + divider-led rows + compact pill controls, not stacked white cards.
- Typography must carry hierarchy: Fraunces only for screen/instrument headlines; Manrope for operational labels, values, rows, controls.
- Color is information: forest green for interaction, moss/coral for trend or state, amber/cream for warmth; no purple gradients, iOS blue, or cold SaaS gray.
- Avoid card-inside-card, centered empty SaaS panels, generic fintech dashboards, crypto-app neon, and rectangular default Material surfaces.
- Mobile-first density: primary summary above secondary detail, 48px+ touch targets, no wrapped control labels, no explanatory paragraphs when labels and values explain enough.
- If the UI could belong to any converter app after removing the nav, the redesign failed.

## Token Spec (from DESIGN.md + refinements)

- Keep: warm cream canvas `#F6F8EF`, forest primary `#285F3B`, ink text `#171D14`, moss/coral trend colors, Manrope + Fraunces split, pill navigation, thin green-tinted dividers.
- Fix DESIGN.md token hygiene before/with implementation: `containerHigh` is malformed (`#F5EDE`), typography `letterSpacing` uses `em` where Flutter tokens use numeric px, and rounding indentation is inconsistent.
- Reduce `card` usage from default surface to exception-only: rows/lists should sit on `bg` or `container`; white should indicate selected chips or deliberate lift, not every tile.
- Add/standardize semantic primitives: `InstrumentHeader`, `DividerList`, `NidunaRow`, `PillAction`, `MetricPill`, `SectionDivider`, `WarmEmptyState`.
- Surface hierarchy: `bg` = page, `container` = grouped control rail/shelf, `card` = selected/raised control only, `border@.14-.22` = separators, shadow only for floating nav/selected chip.
- Spacing rhythm: 20px page padding already works; rows should be 56-64px; large screen headers must earn height and leave the main list/chart visible on compact phones.

## Screen-by-Screen Changes

### Convert

- Current state: the top amount area is close to the right direction, but still reads like a generic form header plus toolbar; the `Converted to` block adds admin chrome before the rate list; active-row behavior is under-signaled; the list is the strongest piece because it uses dividers.
- Goal state: one compact conversion instrument at top, then a clean rate ledger with selectable rows and minimal toolbar noise.
- Changes:
  1. Turn `AmountPanel` into a branded instrument header: Fraunces or strong numeric amount, inline base pill, tiny freshness/status rail, one divider at the bottom.
  2. Replace `Converted to / N currencies` toolbar with a shorter ledger header: `Rates` + count + compact `Add` pill on one line.
  3. Keep `VisibleRatesList` divider-first; do not wrap rows in cards. Make active row feel like a selected instrument row with a subtle left accent or warm tint, not a card.
  4. Ensure quote values use tabular figures and pill/badge only when it communicates action or selection; avoid badge clutter on every value if hierarchy is enough.
  5. Currency picker sheets should inherit the same divider list style and warm controls so the redesign does not stop at the tab surface.

### Favorites

- Current state: most generic tab. It uses a default Scaffold/AppBar and card tiles with borders/radius, which breaks the Niduna direction and looks like stock Material.
- Goal state: a saved-pairs ledger: compact, warm, fast to scan, with favorites feeling like pinned instruments rather than cards.
- Changes:
  1. Remove default AppBar styling; use a warm safe-area screen title with Fraunces `Favorites` and a short operational caption only if needed.
  2. Replace `_FavoriteTile` card boxes with divider-separated rows: pair label, current rate in tabular figures, subtle chevron/remove affordance.
  3. Add a small top summary rail (`Saved pairs`, count, add pill) instead of a bottom-only add CTA; keep bottom CTA only if it does not fight the floating nav.
  4. Redesign empty state as a warm paper note with star icon + direct action copy, not centered generic app placeholder.
  5. Swipe-to-delete background should be coral-tinted but flat; no rounded card margin unless the row itself remains cardless.

### Charts

- Current state: strongest conceptually, but the chart/control stack feels like separate widgets bolted together; header is large, pair/range/summary compete below the plot; chart chrome risks feeling detached.
- Goal state: an instrument chart panel: pair headline + trend, full-bleed chart, range rail before/near the chart, exact values on touch, summary metrics as compact anchors.
- Changes:
  1. Tighten `ChartHeader` height and treat it as the chart instrument label: Fraunces pair title, current value, moss/coral delta, freshness in one compact column.
  2. Place `RangeSelector` before or visually attached to the chart because it changes the whole range; keep it as a horizontal pill rail for 4+ options.
  3. Keep chart full-bleed/cardless; improve axis anchors and theme inheritance in `ChartLinePlot` instead of adding a container.
  4. Move selected-point detail below or inside a stable overlay zone only if it does not cause jumpy/covered chart reading on compact phones.
  5. Compress `ChartSummary` into 2-3 metric pills/inline anchors below the chart; `PairSelector` should be a warm control rail, not a second card stack.

### Settings

- Current state: closer to divider-led settings, but Premium uses multiple cards inside a settings list; explanatory data copy is long; default settings rows can feel plain rather than branded.
- Goal state: a calm preferences ledger with clear sections, thin dividers, warm toggles, and premium as one restrained upgrade shelf.
- Changes:
  1. Keep Fraunces `Settings`, but make section rhythm more editorial: uppercase moss headers, divider lists, consistent row padding.
  2. Convert Premium from three stacked cards into one warm upgrade shelf plus divider rows for purchasable items; avoid card-inside-settings-list.
  3. Shorten the Data explanatory paragraph into a one-line note or move detail into `Data details`.
  4. Ensure `SettingsTile`, `SwitchTile`, `BaseCurrencyTile`, and detail pages share the same row primitive and divider language.
  5. Keep switches primary green, destructive/cache actions coral only when action semantics require it.

## Implementation Order

1. Convert — core product job and shared primitives (`InstrumentHeader`, divider rows, pills) should be proven here first.
2. Favorites — currently the most generic; reuse Convert row/ledger primitives to eliminate card tiles quickly.
3. Charts — apply the same instrument-panel language after primitives exist; verify range selector, chart readability, and compact-phone behavior carefully.
4. Settings — final consistency pass; convert premium/settings rows to the shared divider system and remove remaining generic Material/card surfaces.

One implementation pass should be enough for the 4 tabs, followed by a visual QA pass on compact mobile. Split only if Convert primitives reveal large theme/component refactors.

## Anti-Generic Checklist

- Does NOT look like a generic fintech/crypto app.
- Has personality specific to Niduna: warm paper, forest/moss palette, Fraunces editorial headings, restrained instrument-panel composition.
- Dividers not cards for rows.
- Warm instead of cold/corporate.
- Typography does hierarchy work, not just decoration.
- No card-inside-card.
- No purple gradients, iOS blue, neon crypto styling, fake chrome, or SaaS dashboard widgets.
- If it looks like any currency converter app, it is wrong.

## Quality Gate

- `./scripts/check.sh` must pass with 0 errors.
- Run a Flutter build before handoff, e.g. `flutter build web` or the repo’s preferred mobile build target.
- For UI completion, also capture/review compact-phone screenshots for Convert, Favorites, Charts, and Settings with normal and increased text scale when practical.
