# UI Redesign — Iteration 2 Implementation Playbook

> Maps [UI_REDESIGN.md](./UI_REDESIGN.md) **Iteration 2** demands to Flutter work.  
> **Docs-only predecessor:** v1 shipped in commit `92f8dcf`. This playbook assumes that baseline is on the branch.  
> **Execute in waves** — each wave ends with a **visible delta screenshot** before the next.  
> **Current branch note:** this file has been continued mid-plan. Several Wave A/B/C items already exist; do not restart them unless verification fails.

---

## Iteration 2 playbook summary

| Principle | v1 | v2 |
|-----------|----|----|
| Goal | Cohesion, doc sync, file splits | **Obvious visual transformation** |
| Acceptance | Engineer checklist | **Non-dev screenshot diff** (S2-1) |
| Convert | Polish rows + empty panel | **Hero instrument + ledger** |
| Charts | Attach range to plot | **Plot-first flagship + metric rail** |
| Settings | ScreenTitle + tiles | **De-card premium + data pages** |
| Tokens | Sync existing | **Add hero type scale + spacing names + semantic colors** |

---

## Preconditions & read order

### Read before Wave A.0

1. `AGENTS.md`, `DEFINITIONS.md`, `ROADMAP.md`, `DESIGN.md`, `.agent/DESIGN_GUIDELINES.md`
2. `.plan/UI_REDESIGN.md` (v2 demand spec)
3. Skills (sync if missing: `./agent/sync-shared-skills.sh`):
   - `.agent-local/skills/frontend/frontend-design-layer.SKILL.md`
   - `.agent-local/skills/frontend/frontend-design-direction.SKILL.md`
   - `.agent-local/skills/frontend/design-system-consistency.SKILL.md`
   - `.agent-local/skills/mobile/mobile-ui-review.SKILL.md`
   - `.agent-local/skills/mobile/flutter/flutter-small-screen-ui.SKILL.md`
   - `.agent/skills/small-screen-ui-review/SKILL.md`
   - `.agent-local/skills/mobile/chart-ux-review.SKILL.md`

### Repo baseline after v1 (May 2026)

| Item | State |
|------|-------|
| `charts_screen.dart` | 72 lines orchestrator ✅ |
| `AmountCard` | Thin wrapper → `AmountPanel` — **rename/replace in v2** |
| `no_rates_card.dart` | Deleted ✅ |
| `UpgradeShelf` | Card-style container — **refactor in Wave C** |
| `ChartSummary` | Oval pill metrics — **replace layout in Wave B** |
| `pair_selector.dart` | Heavy shadow pills — **refactor in Wave B** |

```bash
flutter pub get
./scripts/check.sh
```

---

## Baseline capture (v1 — do not overwrite)

Store v1 reference screenshots before v2 edits:

```bash
mkdir -p .tmp/screens/ios/ui-redesign-baseline
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/sim_reinstall_build.sh
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/sim_wait_ready.sh
./.devtools/sim_screenshot.sh ui-redesign-baseline/convert
# Tap Charts → ./.devtools/sim_screenshot.sh ui-redesign-baseline/charts
# Tap Settings → ./.devtools/sim_screenshot.sh ui-redesign-baseline/settings
```

Optional full bundle:

```bash
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} SCREEN_OUTPUT_DIR=.tmp/screens/ios/ui-redesign-baseline \
  ./.devtools/capture_ios_ui_review_bundle.sh
```

Record: device, iOS version, `PROVIDER_PROFILE`, `APP_DEV_MODE`, text scale `1.0`.

**v2 output directory:** `.tmp/screens/ios/ui-redesign-v2/` (same filenames with `v2-` prefix).

---

## v1 files: refactor vs replace

| File | v1 role | v2 action |
|------|---------|-----------|
| `amount_card.dart` | Wrapper name | **Replace** — delete; call `AmountPanel` or `ConvertInstrumentHeader` from `convert_content.dart` |
| `amount_panel.dart` | Flat header stack | **Refactor** — hero instrument well |
| `amount_editing_field.dart` | 42px amount | **Refactor** — use `AppTheme.heroAmount` |
| `amount_header_row.dart` | Title + actions | **Refactor** — slim micro rail |
| `amount_status_bar.dart` | Status | **Refactor** — single-line signal strip |
| `convert_content.dart` | Column layout | **Refactor** — instrument + ledger |
| `rates_section_header.dart` | Rates + Add pill | **Refactor** — lighter Edit affordance |
| `currency_rate_row.dart` | Divider row | **Polish** — accent/wash only |
| `visible_rates_list.dart` | List | **Refactor** — use `DesignedStatePanel` |
| `inline_empty_panel.dart` | Generic empty | **Extend** or add `designed_state_panel.dart` |
| `charts_tab_body.dart` | Layout column | **Refactor** — plot-first order |
| `charts_chart_section.dart` | Range + plot | **Refactor** — de-box, loading line |
| `chart_header.dart` | Tall header | **Refactor** — compact masthead |
| `chart_summary.dart` | Oval pills | **Replace** → `chart_metric_rail.dart` |
| `pair_selector.dart` | Heavy pills | **Refactor** → `chart_pair_strip.dart` |
| `range_selector.dart` | Chip rail | **Polish** — flush to plot |
| `charts_empty_state.dart` / `charts_error_state.dart` | Inline empty | **Refactor** — personality copy |
| `upgrade_shelf.dart` | Card shelf | **Refactor** — divider-integrated |
| `data_details_page.dart` | Detail cards | **Refactor** — divider blocks |
| `data_sources_page.dart` | Source cards | **Refactor** — divider blocks |
| `ad_support_shelf.dart` | Footer ads | **Refactor** — instrument footer |
| `app_theme.dart` | Tokens | **Extend** — hero type + spacing + semantics |
| N/A | — | **Create** `instrument_panel.dart`, `canvas_background.dart`, `chart_metric_rail.dart`, `chart_pair_strip.dart`, `designed_state_panel.dart` |

---

## Mid-implementation checkpoint — current branch state

This branch already contains substantial v2 work. Use this checkpoint to continue safely from the middle instead of redoing Wave A.

### Already present in code

| Demand | Observed files | Status |
|--------|----------------|--------|
| A.0 token foundation | `app_theme.dart` has hero styles, named spacing, instrument colors, coral colors | Present — verify tests/docs |
| Canvas/panel primitives | `canvas_background.dart`, `instrument_panel.dart`, `designed_state_panel.dart` | Present |
| Amount card removal | No `amount_card.dart` in `convert/widgets`; `ConvertContent` calls `AmountPanel` | Present |
| Convert instrument | `amount_panel.dart`, `amount_header_row.dart`, `amount_value_row.dart`, `amount_status_bar.dart` | Present — screenshot verify height |
| Charts plot-first pieces | `charts_tab_body.dart`, `charts_chart_section.dart`, `chart_pair_strip.dart`, `chart_pair_pill.dart`, `chart_metric_rail.dart` | Present — screenshot verify proportions |
| Settings de-card pass | `upgrade_shelf.dart`, `data_details_page.dart`, `data_sources_page.dart` use divider-oriented structure | Present — verify dark mode and typography |
| Test scaffolding | `app_theme_test.dart`, `ui_redesign_widget_test.dart` | Present — run full check |

### Continue from here

| Step | Action | Why |
|------|--------|-----|
| R.1 | Run `./scripts/check.sh` | Establish whether current branch compiles/tests before polishing |
| R.2 | Rebuild/reinstall iOS simulator with `.devtools/sim_reinstall_build.sh` | Verify the renderer, not just code structure |
| R.3 | Capture Convert, Charts, Settings screenshots at 1.0× text scale | Decide whether S2-1 visual leap is already achieved |
| R.4 | Capture or manually inspect 1.3×/2.0× text scale for Convert hero and Charts range/pair controls | Compact-screen release risk |
| R.5 | Only patch screenshot failures: Convert first viewport, Charts plot height, Settings premium calmness, ad footer integration, dark mode | Avoid churn after core v2 components already landed |
| R.6 | Complete Wave D sign-off | Motion, flags, haptics, dark screenshots, non-dev review |

### Likely remaining polish targets

| Area | Check before editing |
|------|----------------------|
| Convert | Does `AmountPanel` plus status leave ≥3 rate rows visible on SE? If not, reduce vertical gaps before shrinking hero typography |
| Convert | Does `AdSupportShelf` look like an integrated footer instrument, or still like a rectangular ad block? |
| Charts | Does the expanded chart visibly own ≥40% viewport? If not, reduce masthead/pair/metric vertical padding first |
| Charts | Does `ChartMetricRail` fit at 2.0× without ellipsis hiding important values? If not, allow horizontal scroll or reduce visible metric count at high text scale |
| Settings | Does `UpgradeShelf` read as a settings group, not a marketing block? If not, align it closer to `SettingsTile` rhythm |
| Dark mode | Do `containerHigh`, `card`, badges, and chart tooltip surfaces still look light-theme-only? |

### Verification run — current continuation checkpoint

| Gate | Result | Notes |
|------|--------|-------|
| `./scripts/check.sh` | Passed | Analyzer clean; all tests passed |
| iOS simulator build/reinstall | Passed | `sim_reinstall_build.sh` built, installed, and launched current code |
| Convert screenshot | Captured | `.tmp/screens/ios/ui-redesign-v2/v2-convert-100326.png` |
| Charts/Settings screenshots | Invalid capture | Manual tap coordinates missed the bottom nav; captured Convert again. Recapture with `capture_ios_ui_review_bundle.sh`, integration screenshot flow, or corrected simulator coordinates before judging S2-3/S2-10 |
| Preliminary Convert visual read | Needs human/product review | Functional first viewport is good (hero + 3+ rows visible), but the top instrument may still read as a rounded card and the ad footer may feel intrusive against the v2 north star |

Do not make Charts/Settings visual decisions from the invalid screenshots. The next action is a reliable screenshot bundle, then targeted polish only where images fail S2 gates.

---

## Wave A.0 — Tokens & canvas foundation

**Goal:** Land v2 type/spacing semantics without layout moves yet.  
**Visible delta:** Subtle — amount slightly larger if hero style applied early; full delta comes Wave A.1.

### Files

| Action | Path | Budget |
|--------|------|--------|
| Edit | `lib/src/core/theme/app_theme.dart` | ≤ 120 lines |
| Create | `lib/src/shared/widgets/canvas_background.dart` | ≤ 45 lines |
| Create | `lib/src/shared/widgets/instrument_panel.dart` | ≤ 55 lines |
| Edit | `DESIGN.md` | token section |
| Edit | `.agent/DESIGN_GUIDELINES.md` | hero + instrument rules |

### Steps

| Step | Task | Demand IDs |
|------|------|------------|
| A.0.1 | Add `heroAmount`, `heroAmountCompact`, `pairTitleFraunces`, `metricValue`, `sectionLabel` TextStyles | G2-4 |
| A.0.2 | Add `space1`…`space8` static const doubles | G2-4 |
| A.0.3 | Add `instrumentFill`, `instrumentBorder`, `coralSurface`, `coralInk` colors | G2-4 |
| A.0.4 | Create `CanvasBackground` — wraps child with bottom-weighted gradient on `AppTheme.bg` | G2-5 |
| A.0.5 | Create `InstrumentPanel` — padding, fill, border, optional `header` slot | G2-4 |
| A.0.6 | Extend `test/app_theme_test.dart` for new constants | S2-5 |
| A.0.7 | `./scripts/check.sh` | S2-5 |

### Acceptance

- [ ] No analyzer errors
- [ ] `DESIGN.md` documents hero scale and instrument panel

---

## Wave A.1 — Convert instrument (highest visible impact)

**Goal:** Convert tab reads as a **precision instrument**, not a form.  
**Visible delta checkpoint:** Screenshot `v2-convert-1x` — obvious hero well, larger amount, warm panel, ledger below.

### Target layout (ASCII)

```
┌─────────────────────────────────────┐
│ CONVERT          [refresh] [more]   │  micro rail
├─────────────────────────────────────┤
│ ┌─ InstrumentPanel (containerHigh)─┐│
│ │  AMOUNT                           ││
│ │  48–52px hero amount    [EUR ▼]  ││
│ │  ● Fresh · Updated 16:21  (i)    ││  signal strip
│ └───────────────────────────────────┘│
├─────────────────────────────────────┤
│ RATES                    Edit       │
│ │▌ USD  US Dollar      [1.08]      ││
│ │  EUR  Euro           [0.92]      ││
│ │  GBP  …              […]         ││
├─────────────────────────────────────┤
│ ─── ad footer instrument ───        │
└─────────────────────────────────────┘
```

### File map

| File | Lines target | Action |
|------|--------------|--------|
| `convert_content.dart` | ≤ 80 | Refactor layout |
| `amount_panel.dart` | ≤ 90 | Hero instrument |
| `amount_editing_field.dart` | ≤ 60 | Hero typography |
| `amount_header_row.dart` | ≤ 50 | Micro rail |
| `amount_status_bar.dart` | ≤ 70 | Signal strip |
| `rates_section_header.dart` | ≤ 45 | Lighter Edit |
| `convert_screen.dart` | ≤ 80 | Wrap body with `CanvasBackground` |
| `amount_card.dart` | — | **Delete** |
| `designed_state_panel.dart` | ≤ 60 | **Create** |
| `visible_rates_list.dart` | ≤ 90 | Use designed states |
| `ad_support_shelf.dart` | ≤ 70 | Footer instrument |

### Steps

| Step | Task | Demand IDs |
|------|------|------------|
| A.1.1 | Delete `amount_card.dart`; update `convert_content.dart` to use `AmountPanel` only | D2-CON-6 |
| A.1.2 | Wrap amount region in `InstrumentPanel`; apply `heroAmount` / compact fallback from `MediaQuery.textScaler` | D2-CON-1, D2-CON-2 |
| A.1.3 | Refactor `AmountHeaderRow` → micro “CONVERT” + icon buttons (drop redundant Fraunces title if duplicate) | D2-CON-2 |
| A.1.4 | `AmountStatusBar` → single-line moss/amber/coral signal | D2-CON-3 |
| A.1.5 | `RatesSectionHeader`: text-button “Edit” instead of emphasized `PillAction` Add | D2-CON-5 |
| A.1.6 | `AnimatedSwitcher` on amount text key | D2-CON-8 |
| A.1.7 | Create `DesignedStatePanel`; wire in `visible_rates_list.dart` for error/empty | D2-CON-7 |
| A.1.8 | `AdSupportShelf`: top hairline + `container` strip styling | D2-CON-10, M2-1, M2-2 |
| A.1.9 | `ConvertScreen` / tab root: `CanvasBackground` | G2-5 |
| A.1.10 | Widget keys: `convert_amount_field`, `convert_rates_list`, `convert_refresh` | S2-6 |
| A.1.11 | Update `test/ui_redesign_widget_test.dart` — hero style, text scale 1.3 | S2-5 |
| A.1.12 | `./scripts/check.sh` + `sim_reinstall_build.sh` | S2-5 |
| A.1.13 | Screenshot `v2-convert-1x`, `v2-convert-1.3x` | S2-1, S2-2 |

### Visible delta checkpoint (A.1)

Compare to `ui-redesign-baseline/convert`:

- [ ] Warm **filled** amount well visible (not just padding on paper)
- [ ] Amount clearly **larger** than v1
- [ ] “Card” naming gone from code and visual
- [ ] Non-dev says “different” without hints

---

## Wave B — Charts flagship surface

**Goal:** Charts tab is a **market instrument** — plot dominates.  
**Visible delta checkpoint:** `v2-charts-1x` — plot ≥40% viewport; metric rail is flat row; pair strip slim.

### Target layout (ASCII)

```
┌─────────────────────────────────────┐
│ CHARTS                              │
│ USD / EUR     1.0842  ↑ 0.4%   [⇅] │  compact masthead
├─────────────────────────────────────┤
│ [1W][1M][3M][6M][1Y][2Y]            │  range flush top
│                                     │
│         full-bleed line chart       │
│                                     │
├─────────────────────────────────────┤
│ [USD]  ⇄  [EUR 🔒]                  │  pair strip
│ High 1.09 │ Low 1.06 │ Chg +0.4%   │  metric rail
└─────────────────────────────────────┘
```

### File map

| File | Lines target | Action |
|------|--------------|--------|
| `charts_tab_body.dart` | ≤ 85 | Reorder children |
| `chart_header.dart` | ≤ 75 | Compact masthead |
| `charts_chart_section.dart` | ≤ 95 | De-box plot, loading line |
| `chart_metric_rail.dart` | ≤ 65 | **Create** (replaces summary layout) |
| `chart_pair_strip.dart` | ≤ 80 | **Create** from `pair_selector` |
| `pair_selector.dart` | — | **Deprecate** — export strip from new file |
| `chart_summary.dart` | — | **Delete** after migration |
| `charts_empty_state.dart` | ≤ 40 | Personality |
| `charts_error_state.dart` | ≤ 45 | Personality |
| `range_selector.dart` | ≤ 70 | Visual flush |

### Steps

| Step | Task | Demand IDs |
|------|------|------------|
| B.1 | `ChartHeader`: reduce vertical padding; use `pairTitleFraunces` + `metricValue` + delta chip | D2-CHT-1 |
| B.2 | `charts_tab_body.dart`: order = masthead → `ChartsChartSection` → `ChartPairStrip` → `ChartMetricRail` | D2-CHT-2 |
| B.3 | `ChartsChartSection`: lighter border (hairline); optional remove side borders; loading = top `LinearProgressIndicator` moss | D2-CHT-3, D2-CHT-4 |
| B.4 | Create `ChartMetricRail` — three columns + dividers, no `FittedBox` on primary values | D2-CHT-6 |
| B.5 | Create `ChartPairStrip` from `pair_selector` logic — slim pills, no heavy shadow | D2-CHT-5 |
| B.6 | Update `charts_empty_state.dart` / `charts_error_state.dart` copy + `DesignedStatePanel` | D2-CHT-8 |
| B.7 | Range change: fade-only `AnimatedSwitcher` (disable flip except swap) | D2-CHT-9 |
| B.8 | `AdSupportShelf` on Charts matches Convert footer | D2-CHT-12 |
| B.9 | Keys: `charts_range_selector`, `charts_pair_base`, `charts_pair_quote` | S2-6 |
| B.10 | Widget test: text scale 1.3 on range chips | S2-5 |
| B.11 | `./scripts/check.sh` + screenshots `v2-charts-1x`, `v2-charts-locked` | S2-1, S2-3 |

### Visible delta checkpoint (B)

Compare to `ui-redesign-baseline/charts`:

- [ ] Plot visibly taller; header shorter
- [ ] Metrics are **one flat rail**, not three pills
- [ ] Pair controls slimmer, below chart
- [ ] Non-dev obvious diff

---

## Wave C — Settings calm utility

**Goal:** Settings feels like **trust desk**, not marketing cards.  
**Visible delta checkpoint:** `v2-settings-1x` — Premium is divider-group; data pages flat.

### Steps

| Step | Task | Demand IDs |
|------|------|------------|
| C.1 | Refactor `UpgradeShelf` → divider header + `SettingsTile`-style purchase rows + inline owned badges | D2-SET-3 |
| C.2 | `PremiumSection`: subscription/restore as normal tiles | D2-SET-4 |
| C.3 | `SettingsDataSection`: single tile with subtitle → navigates to details | D2-SET-5 |
| C.4 | `data_details_page.dart`: `_DetailBlock` with dividers, no card boxes | D2-SET-6 |
| C.5 | `data_sources_page.dart`: same pattern | D2-SET-6 |
| C.6 | Dark mode audit: replace hardcoded `AppTheme.card` fills with theme-aware surfaces | D2-SET-8 |
| C.7 | `settings_screen.dart`: top spacing `space7` | D2-SET-1 |
| C.8 | `./scripts/check.sh` + `v2-settings-1x` | S2-1 |

### Visible delta checkpoint (C)

- [ ] No large rounded Premium card floating on paper
- [ ] Data subpages match divider system

---

## Wave D — Motion, flags, sign-off

| Step | Task | Demand IDs |
|------|------|------------|
| D.1 | Flag circles unified 36px in `quote_identity.dart`, pair strip, pickers | G2-8 |
| D.2 | Review haptics on row select / swap | G2-6 |
| D.3 | Dark mode screenshots all tabs | S2-10 |
| D.4 | Run non-dev screenshot test (3 viewers) — record S2-1 | S2-1 |
| D.5 | Full bundle: `capture_ios_ui_review_bundle.sh` → `ui-redesign-v2/` | S2-1 |
| D.6 | Anti-generic checklist in UI_REDESIGN.md — all pass | — |

---

## Verification matrix

### Automated

```bash
./scripts/check.sh
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/run_ios_minimal_smoke.sh
```

### Manual matrix

| Check | 1.0× | 1.3× | 2.0× | Screenshot |
|-------|------|------|------|------------|
| S2-1 non-dev obvious diff | ☐ | — | — | baseline vs v2 side-by-side |
| Convert hero + 3 rows (S2-2) | ☐ | ☐ | ☐ | `v2-convert-*` |
| Charts plot height (S2-3) | ☐ | ☐ | ☐ | `v2-charts-*` |
| Settings premium de-card | ☐ | — | — | `v2-settings-*` |
| Remove Ads hides shelf | ☐ | — | — | dev entitlement |
| Locked pair sheet | ☐ | — | — | `v2-charts-locked` |
| Dark mode all tabs | ☐ | ☐ | ☐ | `v2-dark-*` |
| Ad footer integrated | ☐ | — | — | Convert + Charts |

### Sign-off

- [ ] S2-1 passed (document viewer names + verdict)
- [ ] `./scripts/check.sh` clean
- [ ] No file > 200 lines in touched paths
- [ ] Traceability table below complete
- [ ] User informed on AdMob placeholder decision

---

## Traceability table (D2-* → files → steps)

| Demand ID | Primary files | Step | Verified by |
|-----------|---------------|------|-------------|
| S2-1 | all tabs | D.4 | Non-dev review |
| S2-2 | `amount_panel.dart`, `visible_rates_list.dart` | A.1.13 | Screenshot SE |
| S2-3 | `charts_chart_section.dart`, `chart_header.dart` | B.11 | Screenshot SE |
| S2-5 | tests, simulator | A.1.11, B.10 | check.sh + text scale |
| S2-6 | touch targets | A.1.10, B.9 | Manual |
| S2-10 | theme + screens | C.6, D.3 | Dark screenshots |
| G2-4 | `instrument_panel.dart` | A.0.5, A.1.2 | Visual |
| G2-5 | `canvas_background.dart` | A.0.4, A.1.9 | Visual |
| G2-6 | amount/charts switchers | A.1.6, B.7 | Visual |
| G2-8 | `quote_identity.dart`, pair strip | D.1 | Visual |
| D2-CON-1 | `amount_panel.dart`, `amount_editing_field.dart` | A.1.2 | v2-convert |
| D2-CON-2 | `amount_header_row.dart` | A.1.3 | v2-convert |
| D2-CON-3 | `amount_status_bar.dart` | A.1.4 | v2-convert |
| D2-CON-5 | `rates_section_header.dart` | A.1.5 | v2-convert |
| D2-CON-6 | delete `amount_card.dart` | A.1.1 | Code review |
| D2-CON-7 | `designed_state_panel.dart` | A.1.7 | v2-convert empty |
| D2-CON-8 | `amount_editing_field.dart` | A.1.6 | Visual |
| D2-CON-10 | `ad_support_shelf.dart` | A.1.8 | v2-convert footer |
| D2-CHT-1 | `chart_header.dart` | B.1 | v2-charts |
| D2-CHT-2 | `charts_tab_body.dart` | B.2 | v2-charts |
| D2-CHT-3 | `charts_chart_section.dart` | B.3 | v2-charts |
| D2-CHT-5 | `chart_pair_strip.dart` | B.5 | v2-charts |
| D2-CHT-6 | `chart_metric_rail.dart` | B.4 | v2-charts |
| D2-CHT-8 | empty/error states | B.6 | v2-charts |
| D2-CHT-9 | `charts_chart_section.dart` | B.7 | Visual |
| D2-CHT-12 | `ad_support_shelf.dart` | B.8 | v2-charts footer |
| D2-SET-3 | `upgrade_shelf.dart` | C.1 | v2-settings |
| D2-SET-5 | `settings_data_section.dart` | C.3 | Manual |
| D2-SET-6 | `data_details_page.dart`, `data_sources_page.dart` | C.4–C.5 | Navigation |
| D2-SET-8 | settings + theme | C.6 | Dark |
| M2-1 | `ad_support_shelf.dart` | A.1.8, B.8 | Screenshot |
| M2-2 | `remove_ads_button.dart` | A.1.8 | Screenshot |
| M2-3 | `upgrade_shelf.dart` | C.1 | v2-settings |

---

## Estimated effort

| Wave | Effort | Visible impact |
|------|--------|----------------|
| A.0 | 0.5 day | Low (foundation) |
| A.1 | 1.5 days | **Highest** |
| B | 1.5 days | **Very high** |
| C | 0.75 day | Medium |
| D | 0.5 day | Polish + S2-1 gate |

**Total:** ~4.5–5 focused days including QA and non-dev screenshot review.

---

## Post-implementation doc updates

| File | When |
|------|------|
| `DESIGN.md` | After A.0 — hero scale, instrument panel, gradient |
| `.agent/DESIGN_GUIDELINES.md` | After D — v2 verification loop |
| `AGENTS.md` | If `v2-*` screenshot names become standard |

---

## Stitch (exploration only)

If v2 visuals stall, run Stitch **after** Wave A.1 screenshot exists:

1. Capture `v2-convert-1x` + reference competitors
2. Extract composition ideas (hero well proportion, chart masthead density)
3. Implement in Flutter — **never** import generated code
4. Re-screenshot against baseline for S2-1

Stitch project IDs: see `AGENTS.md`.
