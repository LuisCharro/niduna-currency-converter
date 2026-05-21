# UI Redesign — Implementation Playbook

> Maps every demand in [UI_REDESIGN.md](./UI_REDESIGN.md) to actionable Flutter work.
> **Do not implement from this file in one shot** — execute phases in order; verify each phase before the next.

---

## Preconditions & read order

### Read before Phase 0

1. `README.md`, `AGENTS.md`, `DEFINITIONS.md`, `ROADMAP.md`, `DESIGN.md`, `ARCHITECTURE.md`
2. `.plan/UI_REDESIGN.md` (this pass demand spec)
3. Skills:
   - `.agent-local/skills/frontend/frontend-design-layer.SKILL.md`
   - `.agent-local/skills/frontend/frontend-design-direction.SKILL.md`
   - `.agent-local/skills/frontend/design-system-consistency.SKILL.md`
   - `.agent-local/skills/mobile/mobile-ui-review.SKILL.md`
   - `.agent/skills/small-screen-ui-review/SKILL.md`

### Repo state assumptions (validated May 2026)

- 3-tab shell in `lib/src/app.dart` — no Favorites tab index
- `AppTheme.pagePadding == 20` — canonical over `DESIGN.md` 16px
- `charts_screen.dart` is **249 lines** — must split in Phase 3
- Monetization stubs wired; AdMob may still be placeholder
- `.agent/DESIGN_GUIDELINES.md` **missing** — create in Phase 0

### Environment

```bash
flutter pub get
./scripts/check.sh
```

If Flutter not on PATH:

```bash
FLUTTER_BIN=/path/to/flutter ./scripts/check.sh
```

---

## Baseline capture (before any UI edits)

Run once per redesign branch; store under `.tmp/screens/ios/ui-redesign-baseline/`.

| Step | Command | Output |
|------|---------|--------|
| B-1 | `IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/sim_reinstall_build.sh` | Fresh build on simulator |
| B-2 | `IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/sim_wait_ready.sh` | App ready |
| B-3 | `./.devtools/sim_screenshot.sh baseline-convert` | Convert tab |
| B-4 | Tap Charts tab → `./.devtools/sim_screenshot.sh baseline-charts` | Charts tab |
| B-5 | Tap Settings → `./.devtools/sim_screenshot.sh baseline-settings` | Settings tab |
| B-6 | Optional full bundle | `IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/capture_ios_ui_review_bundle.sh` |

Record: device model, iOS version, `PROVIDER_PROFILE`, `APP_DEV_MODE`, text scale `1.0`.

---

## Phase 0: Token & theme foundation

**Goal:** Single source of truth; docs match code.

### Files

| Action | Path |
|--------|------|
| Edit | `lib/src/core/theme/app_theme.dart` |
| Edit | `DESIGN.md` (token section only — small sync) |
| Create | `.agent/DESIGN_GUIDELINES.md` (minimal — see template below) |
| Optional | `test/app_theme_test.dart` — assert key constants |

### Tasks

| Step | Task | Demand IDs |
|------|------|------------|
| 0.1 | Confirm canonical colors match table in UI_REDESIGN § Design tokens | G-3 |
| 0.2 | Add `AppTheme.pageInsets` → `EdgeInsets.symmetric(horizontal: pagePadding)` for migration | G-3 |
| 0.3 | Add `AppTheme.sectionGap` = 24, `AppTheme.screenTitleFraunces` TextStyle (28, w800) to reduce duplication | G-3 |
| 0.4 | Update `DESIGN.md`: `spacing.md` horizontal padding **20px**; fix `containerHigh` → `#F5EDEE`; fix `muted`/`subtle` to AppTheme hex; fix `letterSpacing` to px not `em` | S-1 |
| 0.5 | Create `.agent/DESIGN_GUIDELINES.md` (~80–120 lines): posture, tokens pointer, divider-not-cards, Fraunces rules, bottom chrome, anti-generic bullets | S-1 |
| 0.6 | Document dark mode token overrides in DESIGN_GUIDELINES (bg `#171D14`, text paper, primary moss) | D-SET-4 |
| 0.7 | Run `./scripts/check.sh` | S-2 |

### `.agent/DESIGN_GUIDELINES.md` minimum sections

1. Product posture (privacy-first, 3 tabs)
2. Canonical token file = `app_theme.dart`
3. Typography rules (Fraunces vs Manrope)
4. Layout: page padding 20, bottom chrome via `BottomTabFrame`
5. Dividers-not-cards + when `card` token is allowed
6. Monetization visual rules (shelf, coral Remove Ads, no aggressive paywall)
7. Verification: check.sh + screenshots + text scale

### Acceptance criteria

- [ ] `DESIGN.md` padding and `containerHigh` match `AppTheme`
- [ ] `DESIGN_GUIDELINES.md` exists and links to `UI_REDESIGN.md`
- [ ] No new analyzer issues
- [ ] No Flutter code behavior change required in Phase 0 (docs + small theme helpers only)

---

## Phase 1: Shared widgets & primitives

**Goal:** Reusable pieces for Phases 2–4; line budgets ≤ 60 lines per new widget file.

### Build or extend

| Widget | Path | Budget | Keys (tests) |
|--------|------|--------|--------------|
| `PagePadding` / use `AppTheme.pageInsets` | `lib/src/shared/widgets/page_padding.dart` | ≤ 30 | — |
| `InlineEmptyPanel` | `lib/src/shared/widgets/inline_empty_panel.dart` | ≤ 55 | `Key('inline_empty_panel')` |
| `ScreenTitle` (Fraunces) | `lib/src/shared/widgets/screen_title.dart` | ≤ 40 | `Key('screen_title')` |
| `InstrumentSectionLabel` | `lib/src/shared/widgets/instrument_section_label.dart` | ≤ 45 | — |
| Extend `DividerListRow` | `lib/src/shared/widgets/divider_list_row.dart` | existing | — |
| `ChartThemeText` helper | `lib/src/features/charts/widgets/chart_theme_text.dart` | ≤ 40 | — |

### Tasks

| Step | Task | Demand IDs |
|------|------|------------|
| 1.1 | Create `InlineEmptyPanel`: icon + title + optional subtitle + optional TextButton — **no** `BoxDecoration` card | D-CON-9, D-CHT-9 |
| 1.2 | Create `ScreenTitle` wrapping Fraunces 28/w800 pattern from Settings | D-SET-1, G-6 |
| 1.3 | Add `ChartThemeText.caption` / `.micro` static methods wrapping `AppTheme` for chart overlays | D-CHT-8 |
| 1.4 | Export shared widgets from a barrel only if already used elsewhere — avoid drive-by refactors | — |
| 1.5 | `./scripts/check.sh` | S-2 |

### Must / must-not

- **Must** use `AppTheme` colors only in new shared widgets
- **Must not** introduce `Card` widget for list/empty patterns
- **Must not** exceed 60 lines per new file

---

## Phase 2: Convert vertical slice

**Goal:** Play Store–ready Convert tab; screen orchestrator ≤ 80 lines.

### File split map

| Current | Target | Lines target |
|---------|--------|--------------|
| `convert_screen.dart` (64) | keep | ≤ 80 |
| `convert_content.dart` (144) | split toolbar + list wrapper | each ≤ 80 |
| `no_rates_card.dart` (42) | replace with `InlineEmptyPanel` usage | delete or deprecate |
| `_RatesToolbar` in `convert_content.dart` | `rates_section_header.dart` | ≤ 50 |

### Step-by-step

| Step | Task | Demand IDs |
|------|------|------------|
| 2.1 | Replace `NoRatesCard` with `InlineEmptyPanel` in `visible_rates_list.dart` | D-CON-9 |
| 2.2 | Extract `_RatesToolbar` → `rates_section_header.dart`: title “Rates” only OR micro subtitle “Edit list” — **remove** “N currencies visible” | D-CON-8 |
| 2.3 | Migrate horizontal padding to `AppTheme.pageInsets` in `amount_panel.dart`, `convert_content.dart`, `visible_rates_list.dart` | G-3 |
| 2.4 | Verify `AmountPanel` has no outer card decoration (only bottom hairline divider) | D-CON-10 |
| 2.5 | Verify freshness rail + info sheet for ECB copy | D-CON-3 |
| 2.6 | Verify `CurrencyRateRow` uses accent not card; favorite affordance visible | D-CON-4, D-CON-7 |
| 2.7 | Verify `AdSupportShelf` when `adsEnabled`; CTA opens `IapPurchasePlayer` Remove Ads | D-CON-6, M-2 |
| 2.8 | Add widget keys: `convert_amount_field`, `convert_rates_list`, `convert_refresh` | S-4 |
| 2.9 | Widget test: text scale 1.3 on `ConvertContent` — no overflow on amount row | S-3 |
| 2.10 | `./scripts/check.sh` | S-2 |
| 2.11 | `IOS_SIMULATOR_ID=… ./.devtools/sim_reinstall_build.sh` | — |
| 2.12 | Screenshots: `polish-convert-1x`, `polish-convert-1.3x` (set text scale in simulator settings) | S-3 |

### States to implement / verify

| State | UI behavior |
|-------|-------------|
| Fresh | Status rail green/moss copy; no error banner |
| Refreshing | Subtle progress on refresh control |
| Cached / stale | Status distinguishes; values still visible |
| Error / no cache | `InlineEmptyPanel` + retry |
| Max favorites | Snackbar or disabled star — no crash |

### Must-not

- Card empty state; admin count copy; paywall on launch; RUB in list

---

## Phase 3: Charts vertical slice

**Goal:** Instrument-style Charts; split oversized screen; range attached to chart.

### File split map

| Current | Target | Lines target |
|---------|--------|--------------|
| `charts_screen.dart` (249) | `charts_screen.dart` orchestrator only | ≤ 80 |
| — | `charts_tab_body.dart` — Column layout | ≤ 100 |
| — | `charts_chart_section.dart` — range + expanded chart | ≤ 90 |
| `_EmptyChart`, `_ErrorState` | `charts_empty_state.dart`, `charts_error_state.dart` | ≤ 50 each |

### Layout target (ASCII)

```
┌─────────────────────────────┐
│ ChartHeader (compact)       │
├─────────────────────────────┤
│ ┌─ chart area ────────────┐ │
│ │ [RangeSelector rail]    │ │  ← D-CHT-9: top or bottom edge of chart block
│ │   Line chart full bleed │ │
│ └─────────────────────────┘ │
│ PairSelector rail           │
│ ChartSummary (compact)      │
├─────────────────────────────┤
│ AdSupportShelf (if ads)     │
└─────────────────────────────┘
```

### Step-by-step

| Step | Task | Demand IDs |
|------|------|------------|
| 3.1 | Split `charts_screen.dart` per file map; no behavior change yet | D-CHT-11, S-7 |
| 3.2 | Move `RangeSelector` into `charts_chart_section.dart` directly above or below `RateChart` with shared horizontal padding | D-CHT-9, D-CHT-10 |
| 3.3 | Move `PairSelector` + `ChartSummary` below chart section | D-CHT-10 |
| 3.4 | Reduce `ChartHeader` vertical padding if first viewport fails SE test | D-CHT-1 |
| 3.5 | Replace `_EmptyChart` / centered columns with `InlineEmptyPanel` | D-CHT-9 |
| 3.6 | Audit `chart_touch_overlay.dart`, `chart_summary.dart`, `pair_selector.dart` — replace raw `TextStyle` with `ChartThemeText` / `AppTheme` | D-CHT-8 |
| 3.7 | Theme `rewarded_ad_player.dart`: replace `Colors.green/red/white` with `AppTheme` dark overlay palette | D-CHT-8, M-7 |
| 3.8 | Verify locked pair flow + `locked_pair_action_sheet` copy | D-CHT-4, M-6 |
| 3.9 | Verify intraday snackbar exact string per ROADMAP | D-CHT-3, M-8 |
| 3.10 | Keys: `charts_range_selector`, `charts_pair_base`, `charts_pair_quote`, `charts_retry` | S-4 |
| 3.11 | Widget test: text scale 1.3 on range chips — horizontal scroll, no clipped locks | S-3 |
| 3.12 | `./scripts/check.sh` + `sim_reinstall_build.sh` | S-2 |
| 3.13 | Screenshots: `polish-charts-default`, `polish-charts-locked-pair` | S-1 |

### Must-not

- Card around chart; range floating far above chart; neon rewarded player colors

---

## Phase 4: Settings vertical slice

**Goal:** Consistent divider system; premium shelf density; data trust copy.

### File split map

| Current | Target |
|---------|--------|
| `settings_screen.dart` (84) | keep ≤ 80 — extract list children if needed |
| `data_sources_page.dart` / `data_details_page.dart` | replace `_DetailCard` with inline sections or divider groups (Phase 4b) |

### Step-by-step

| Step | Task | Demand IDs |
|------|------|------------|
| 4.1 | Use `ScreenTitle` for Settings header | D-SET-1 |
| 4.2 | Verify `SectionHeader` moss uppercase on all sections | D-SET-2 |
| 4.3 | `UpgradeShelf`: shorten body copy to one line if height budget fails | D-SET-6 |
| 4.4 | Subscription row: “Not available in v1” visible | D-SET-4, M-4 |
| 4.5 | `SettingsDataSection`: ECB once-daily explanation + last update | D-SET-5 |
| 4.6 | `ClearCacheTile`: coral destructive styling only here | D-SET-5 |
| 4.7 | Dark mode toggle + `AppShell` `Theme` wrapper audit for dark scaffold on all tabs | D-SET-4 |
| 4.8 | Dev sandbox gated by `preferences.devMode` | D-SET-7 |
| 4.9 | Migrate list padding to `AppTheme.pageInsets`; bottom padding via nav clearance constant not magic `118` if possible | G-3 |
| 4.10 | Phase 4b (optional): refactor `_DetailCard` in data pages to divider layout | D-SET-3 |
| 4.11 | `./scripts/check.sh` + screenshots `polish-settings` | S-2 |

### Must-not

- Stacked premium cards; account settings; subscription purchase in v1

---

## Phase 5: Cross-cutting

| Step | Task | Demand IDs |
|------|------|------------|
| 5.1 | `FloatingPillNav`: verify labels Convert / Chart / Settings; active color `AppTheme.primary` | G-1 |
| 5.2 | `BottomTabFrame`: ensure Convert/Charts body bottom list padding uses frame inset — remove duplicate `96` bottom padding in lists where redundant | G-3 |
| 5.3 | `AdSupportShelf` divider on Charts only (`showDivider: true`) | M-1 |
| 5.4 | Dark mode: grep `lib/src` for hardcoded light `Color(0xFFF6F8EF)` outside theme | D-SET-4 |
| 5.5 | Favorites: confirm no route from nav; optional comment in `favorites_screen.dart` | D-FAV-1 |
| 5.6 | Version stays `0.x.x` in `pubspec.yaml` | README |
| 5.7 | Stitch: only update prompts/refs in design docs — no generated code import | G-8 |

### AdMob (release sub-task — product gate)

| Step | Task |
|------|------|
| 5.8 | Replace `AdBannerPlaceholder` with AdMob when approved |
| 5.9 | Update store privacy disclosures per `DEFINITIONS.md` |

---

## Phase 6: Verification matrix & sign-off

### Automated

```bash
./scripts/check.sh
IOS_SIMULATOR_ID=${IOS_SIMULATOR_ID} ./.devtools/run_ios_minimal_smoke.sh
```

### Manual matrix

| Check | 1.0× | 1.3× | 2.0× | Screenshot name |
|-------|------|------|------|-----------------|
| Convert first viewport | ☐ | ☐ | ☐ | `polish-convert-*` |
| Charts range+chart attached | ☐ | ☐ | ☐ | `polish-charts-*` |
| Settings premium + data | ☐ | ☐ | ☐ | `polish-settings-*` |
| Remove Ads hides shelf | ☐ | — | — | dev entitlement toggle |
| Locked chart pair sheet | ☐ | — | — | `polish-charts-locked` |
| Dark mode all tabs | ☐ | ☐ | ☐ | `polish-dark-*` |

### Sign-off checklist

- [ ] Anti-generic checklist in UI_REDESIGN.md — all pass items checked
- [ ] Traceability table below — every P0 demand has Step + Verified by
- [ ] `DESIGN.md` synced with `AppTheme`
- [ ] `.agent/DESIGN_GUIDELINES.md` present
- [ ] `charts_screen.dart` orchestrator ≤ 80 lines
- [ ] No new Phase 2 features in UI
- [ ] User informed on AdMob placeholder vs live ads decision

---

## Traceability table

| Demand ID | UI_REDESIGN section | Primary files | Step # | Verified by |
|-----------|---------------------|---------------|--------|-------------|
| S-1 | Success criteria | all features | 2.12, 3.13, 4.11, 6 | Screenshots |
| S-2 | Quality gate | — | 0.7, 1.5, 2.10, 3.12, 4.11, 6 | `./scripts/check.sh` |
| S-3 | Store-readiness QA | Convert, Charts | 2.9, 3.11, 6 | Text scale tests + screenshots |
| S-4 | Store-readiness QA | touch targets | 2.8, 3.10 | Widget keys + manual |
| S-5 | Monetization | `monetization/`, `ad_support_shelf.dart` | 2.7, 3.8, 5.3 | Manual + dev toggles |
| S-6 | Product posture | — | 5.5 | Code review |
| S-7 | Modularity | `charts_screen.dart` | 3.1 | Line count |
| G-1 | Global layout | `app.dart`, `floating_pill_nav.dart` | 5.1 | Code review |
| G-2 | Favorites deferred | `app.dart` | 5.5 | Code review |
| G-3 | Tokens / padding | `app_theme.dart`, screens | 0.2, 2.3, 4.9 | Code review |
| G-6 | Typography | headlines | 0.5, 1.2 | Visual |
| G-8 | Stitch | docs only | 5.7 | Doc review |
| D-CON-1 | Convert | `amount_header_row.dart` | 2.4 | Screenshot |
| D-CON-3 | Convert | `amount_status_bar.dart` | 2.5 | Manual |
| D-CON-4 | Convert | `currency_rate_row.dart` | 2.6 | Screenshot |
| D-CON-6 | Convert | `ad_support_shelf.dart` | 2.7 | Manual |
| D-CON-7 | Convert | controller + row | 2.6 | Manual |
| D-CON-8 | Convert | `rates_section_header.dart` | 2.2 | Screenshot |
| D-CON-9 | Convert | `inline_empty_panel.dart` | 2.1 | Screenshot |
| D-CON-10 | Convert | `amount_panel.dart` | 2.4 | Code review |
| D-CHT-1 | Charts | `chart_header.dart` | 3.4 | Screenshot |
| D-CHT-8 | Charts | chart widgets | 3.6, 3.7 | Code + visual |
| D-CHT-9 | Charts | `charts_chart_section.dart` | 3.2 | Screenshot |
| D-CHT-10 | Charts | layout reorder | 3.2, 3.3 | Screenshot |
| D-CHT-11 | Charts | split files | 3.1 | Line count |
| D-SET-1 | Settings | `settings_screen.dart` | 4.1 | Screenshot |
| D-SET-5 | Settings | `settings_data_section.dart` | 4.5 | Manual |
| D-SET-6 | Settings | `upgrade_shelf.dart` | 4.3 | Screenshot |
| D-FAV-1 | Favorites | `app.dart` | 5.5 | Code review |
| M-1 | Monetization | `ad_banner_placeholder.dart` | 5.8 | Product gate |
| M-2 | Monetization | `remove_ads_button.dart` | 2.7 | Manual |
| M-4 | Monetization | `premium_section.dart` | 4.4 | Screenshot |
| M-6 | Monetization | `locked_pair_action_sheet.dart` | 3.8 | Screenshot |
| M-7 | Monetization | `rewarded_ad_player.dart` | 3.7 | Visual |
| M-8 | Monetization | `range_selector.dart` | 3.9 | Manual tap |

---

## Post-implementation doc updates

| File | When |
|------|------|
| `DESIGN.md` | After Phase 0 |
| `.agent/DESIGN_GUIDELINES.md` | Phase 0 create; refine after Phase 6 |
| `ROADMAP.md` | Only if screen contract wording changes — avoid drive-by |
| `AGENTS.md` | If new screenshot names or verification loop becomes standard |

---

## Estimated effort (guidance)

| Phase | Effort |
|-------|--------|
| 0 | 0.5 day |
| 1 | 0.5 day |
| 2 | 1 day |
| 3 | 1.5 days |
| 4 | 0.5 day |
| 5 | 0.5 day |
| 6 | 0.5 day |

**Total:** ~4–5 focused days including QA loops.
