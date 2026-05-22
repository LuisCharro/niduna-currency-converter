# UI Redesign — Iteration 2

> **Status:** Demand spec (docs only) · **Iteration 2 (v2)** · May 2026  
> **Scope:** Phase 1 Play Store polish · version `0.x.x` · privacy-first · no backend/accounts/analytics  
> **Shell:** 3 tabs — **Convert · Charts · Settings** (Favorites code retained, tab hidden until Phase 2)  
> **Predecessor:** [v1 shipped](https://github.com/) as commit `92f8dcf` on `turbo/ui-redesign` — see baseline below

---

## Executive summary

**Iteration 1** closed documentation drift, split oversized Charts files, removed card-wrapped empty states, attached the range rail to the chart block, and synced tokens. The app is cleaner and more maintainable — but the **visible leap is still too small**. A non-developer comparing before/after screenshots would call it “tidied,” not “redesigned.”

**Iteration 2** targets a **beautiful, elegant, intuitive, production-ready** Niduna surface: Play Store quality with a **distinct** warm-instrument identity — not generic fintech cards, not Material-default utility chrome.

### Why v1 was not enough

| Area | v1 delivered | What users still perceive |
|------|----------------|---------------------------|
| Convert | `AmountPanel`, divider rows, `RatesSectionHeader` | Still “form header + list of rows,” not a single precision instrument |
| Typography | Fraunces on titles, 42px amount | No systematic scale; hero amount does not dominate the viewport |
| Charts | File split, range inside bordered chart block | Flagship chart area still competes with header + bottom pair rail + pill metrics |
| Settings | `ScreenTitle`, divider tiles | `UpgradeShelf` + data subpages still read as “settings-card soup” |
| Depth & color | Token sync | Flat paper everywhere; moss/coral used mainly on chips, not composition |
| Motion | Chart `AnimatedSwitcher` | Rest of app feels static; states swap without designed transitions |
| Empty/error | `InlineEmptyPanel` | Correct pattern, generic copy/icon — no Niduna personality |
| Acceptance | Engineer checklist | No explicit “screenshot diff obvious to non-dev” gate |

### v2 north-star outcome

Someone opening the app for three seconds should think: **warm editorial finance instrument made by Niduna** — not “another currency converter with green accents.”

---

## Success criteria (measurable)

| ID | Criterion | How to verify |
|----|-----------|---------------|
| S2-1 | **Non-developer redesign test:** side-by-side screenshots (v1 baseline vs v2) — 3/3 casual viewers say “clearly different app” without coaching | `.tmp/screens/ios/ui-redesign-v2/` vs `ui-redesign-baseline/` |
| S2-2 | **Convert first viewport:** hero amount + base + status + **≥3 rate rows** visible on iPhone SE class without scroll | Manual + `capture_ios_ui_review_bundle.sh` |
| S2-3 | **Charts first viewport:** pair identity + live rate + trend color + **≥40% screen height chart** on SE | Screenshot ruler / layout test |
| S2-4 | Niduna brand identifiable with nav hidden (palette, Fraunces rhythm, divider instrument, no iOS blue) | Visual review |
| S2-5 | `./scripts/check.sh` clean; text scale `1.3×` / `2.0×` — no clipped hero amount, range chips, or pair selectors | Widget tests + simulator |
| S2-6 | Touch targets ≥ `48×48` on custom controls | Manual + keys |
| S2-7 | Monetization looks **integrated** (banner shelf, premium, chart locks) — not bolted-on rectangles | Screenshot review |
| S2-8 | Modularity: screen orchestrators ≤ ~80 lines; no file > 200 lines | `wc -l` on touched files |
| S2-9 | No Phase 2 leakage (accounts, backend, intraday as “available”, RUB, tracking) | Product review |
| S2-10 | Dark mode: same v2 hierarchy and instrument metaphors — not a light-theme recolor only | `polish-dark-*` screenshots |

---

## Current baseline — honest v1 inventory

Commit **`92f8dcf`** (`feat(ui): implement Play Store UI redesign`) shipped:

| Deliverable | Evidence in repo |
|-------------|------------------|
| Token helpers | `AppTheme.pageInsets`, `sectionGap`, `screenTitleFraunces`, `tabScrollBottomPadding` |
| Doc sync | `DESIGN.md` padding 20px, muted/subtle/containerHigh aligned |
| Agent guidelines | `.agent/DESIGN_GUIDELINES.md` |
| Charts modularity | `charts_screen.dart` (72 lines) → `charts_tab_body`, `charts_chart_section`, empty/error widgets |
| Range attached to chart | `ChartsChartSection` top/bottom border + `RangeSelector` inside block |
| Convert empty state | `no_rates_card.dart` deleted → `InlineEmptyPanel` |
| Rates toolbar | `rates_section_header.dart` — “Rates” + Add (no admin count) |
| Shared primitives | `ScreenTitle`, `PagePadding`, `InstrumentSectionLabel`, `InlineEmptyPanel` |
| Theme audit (partial) | `chart_theme_text.dart`, `rewarded_ad_player.dart`, overlay colors |
| Tests | `test/app_theme_test.dart`, `test/ui_redesign_widget_test.dart` |

### Gaps that justify v2 (code-grounded)

| Gap | Current code signal |
|-----|---------------------|
| Convert not an “instrument panel” | `ConvertContent`: `AmountCard` → header stack → `RatesSectionHeader` → `VisibleRatesList` rows — vertical admin layout |
| Hero amount undersized for v2 bar | `AmountEditingField` uses 42px Manrope — below `AppTheme.display` (32/800 is chart-only); no dedicated hero style |
| Amount region lacks instrument chrome | `AmountPanel` ends with hairline divider only — no warm `containerHigh` instrument well |
| Charts layout still stacked widgets | `ChartsTabBody`: header → chart section → `PairSelector` → `ChartSummary` pill row |
| Summary metrics feel generic | `ChartSummary` three rounded containers + `FittedBox` — reads as chip row, not integrated metric rail |
| Settings premium still card-forward | `UpgradeShelf` full `BoxDecoration` rounded container — allowed in v1, contradicts v2 “calm utility” |
| Data subpages still card sections | `data_details_page.dart`, `data_sources_page.dart` use `_DetailSection` / `_SourceCard` boxes |
| Canvas flat | `AppTheme.bg` solid only — `DESIGN.md` gradient depth not implemented in Flutter |
| Empty states lack personality | `ChartsEmptyState` / `InlineEmptyPanel` — correct structure, stock icons/copy |
| `AmountCard` naming debt | Wrapper still named `AmountCard` though it delegates to `AmountPanel` — confuses “card” metaphor |
| Pair selector heavy shadows | `pair_selector.dart` — raised pills with shadow; competes with chart on small screens |

---

## Mid-plan checkpoint — current branch review

This branch is no longer at the v1 baseline. Treat the following as the live continuation point before doing more UI work.

| Area | Current branch signal | Continue from here |
|------|-----------------------|--------------------|
| Tokens/canvas | `AppTheme` now has `heroAmount`, `heroAmountCompact`, `pairTitleFraunces`, `metricValue`, `sectionLabel`, `space1`…`space8`, `instrumentFill`, `instrumentBorder`, `coralSurface`, `coralInk`; `CanvasBackground` and `InstrumentPanel` exist | Do not redo Wave A.0; verify `DESIGN.md` and `.agent/DESIGN_GUIDELINES.md` match these tokens |
| Convert | `AmountCard` is gone; `AmountPanel` uses `InstrumentPanel`; `AmountHeaderRow` is a compact `CONVERT` micro rail; `AmountValueRow` exists | Verify first viewport on SE: hero + status + at least 3 rows; polish active row, empty/error state, and ad footer only if screenshots fail |
| Charts | `ChartPairStrip`, `ChartPairPill`, `ChartMetricRail`, `ChartsChartSection`, and `ChartThemeText` exist; layout is masthead → expanded chart → pair strip → metric rail | Verify plot height, range rail attachment, pair strip shadows, metric rail readability at 1.3×/2.0× text scale |
| Settings | `UpgradeShelf` is divider-integrated; `data_details_page.dart` and `data_sources_page.dart` use divider blocks instead of card sections | Verify premium shelf still feels calm, data pages match settings row typography, and dark mode surfaces are not hardcoded light |
| States | `DesignedStatePanel` exists; chart empty/error widgets exist | Continue with personality/tone polish only if screenshots still look generic |
| Tests | `app_theme_test.dart` and `ui_redesign_widget_test.dart` exist | Run `./scripts/check.sh`; add tests only for failures or fragile compact layouts |
| Favorites | Tab is hidden for v2 | No visual work in this pass; only avoid breaking retained code |

### Continue-from-here order

1. Run `./scripts/check.sh` and fix compile/analyzer/test failures first.
2. Rebuild/reinstall on iOS simulator and capture Convert, Charts, Settings screenshots.
3. Compare screenshots against S2-1, S2-2, S2-3, S2-7, and S2-10 before writing more UI code.
4. Only make targeted polish changes where screenshots fail the plan; do not restart foundation work already present in the branch.
5. Finish with Wave D sign-off: motion polish, dark screenshots, text scale, non-dev screenshot diff.

---

## Design north star

### Posture

**Privacy-first precision instrument** — warm, trustworthy, crafted. Feels like a physical conversion desk on warm paper, not a SaaS dashboard.

### Visual thesis (v2)

1. **One hero per screen** — Convert: amount; Charts: plot; Settings: calm grouped utility (no hero card stack).
2. **Instrument panels** — related controls share a warm surface (`container` / `containerHigh`) with hairline edges, not floating cards.
3. **Editorial hierarchy** — Fraunces for identity moments; Manrope for operations; deliberate type scale (hero → title → label → meta).
4. **Color tells the story** — forest = action; moss = positive/cache-fresh; coral = negative/destructive/offline emphasis.
5. **Full-bleed data** — chart and rate ledger bleed horizontally; chrome is minimal.
6. **Designed states** — loading, empty, error, stale each have iconography, copy tone, and micro-motion — not `CircularProgressIndicator` alone in a void.

### Anti-references (reject explicitly)

- Generic fintech: white cards on gray, purple gradients, sparkline wallpaper
- iOS utility clone: `#007AFF`, system grouped lists, centered empty states in boxes
- “Settings-card soup”: stacked rounded rectangles for every section
- Crypto neon: glowing charts, dark-mode-only trading aesthetic
- Admin dashboards: “N currencies visible,” debug copy on primary tabs

---

## Token & type system (canonical)

**Source of truth:** `lib/src/core/theme/app_theme.dart` — extend in Wave A, sync `DESIGN.md` + `.agent/DESIGN_GUIDELINES.md`.

### Colors (unchanged hex — richer roles)

| Token | Value | v2 usage |
|-------|-------|----------|
| `bg` | `#F6F8EF` | Scaffold; optional bottom-weighted gradient overlay |
| `text` | `#171D14` | Primary ink |
| `muted` | `#5F6A58` | Meta, timestamps |
| `subtle` | `#66745B` | Placeholders, disabled |
| `container` | `#FFF9EC` | Instrument wells, nav, range rail |
| `containerHigh` | `#F5EDEE` | Hero amount well, selected row wash |
| `card` | `#FFFFFF` | Selected chips, swap button, tooltip only |
| `primary` | `#285F3B` | CTAs, active nav, accent bar |
| `trendUp` / `trendDown` | `#6F8C49` / `#DC6543` | Trends, stale warning accents |
| `greenBadge` / `greenBadgeText` | `#EDF5EB` / `#3D6E2C` | Rate value pills |

Add v2 semantic aliases (implementation):

| Alias | Maps to | Use |
|-------|---------|-----|
| `instrumentFill` | `containerHigh` @ 0.55–0.7 alpha | Convert hero well |
| `instrumentBorder` | `border` @ 0.12–0.18 alpha | Panel edges |
| `coralSurface` | `#FDF0EC` | Remove Ads CTA background |
| `coralInk` | `#B54E48` | Destructive / Remove Ads text |

### Typography scale (v2 — add to `AppTheme`)

| Style | Size / weight | Font | Use |
|-------|---------------|------|-----|
| `heroAmount` | **48–52** / w800 | Manrope | Convert primary amount (editable) |
| `heroAmountCompact` | **40** / w800 | Manrope | Text scale ≥ 1.3× fallback |
| `screenTitleFraunces` | 28 / w800 | Fraunces | Tab titles (existing) |
| `pairTitleFraunces` | 30 / w800 | Fraunces | Charts pair headline |
| `metricValue` | 20 / w700 | Manrope | Charts header rate |
| `metricDelta` | 12 / w800 | Manrope | Change chip |
| `sectionLabel` | 11 / w700, ls 0.9 | Manrope | “AMOUNT”, “RATES” micro rails |
| `display` | 32 / w800 | Manrope | Rare secondary heroes |
| `body` / `caption` / `micro` | (existing) | Manrope | Operations |

**Rules:** Fraunces never on body rows; Manrope never on primary tab titles; currency codes always Manrope caps.

### Spacing scale (8px base — enforce named constants)

| Token | px | Use |
|-------|-----|-----|
| `space1` | 4 | Micro gaps |
| `space2` | 8 | Inline icon gaps |
| `space3` | 12 | Row internal |
| `space4` | 16 | Compact section |
| `space5` | 20 | Page horizontal (`pagePadding`) |
| `space6` | 24 | Section gap (`sectionGap`) |
| `space7` | 32 | Hero breathing room |
| `space8` | 40 | Instrument panel vertical padding |

### First-viewport pixel budgets (iPhone SE ~667pt tall, 1.0× text)

| Surface | Budget | Notes |
|---------|--------|-------|
| Convert hero instrument | ≤ **200px** total height | Title rail + hero amount + status + divider |
| Convert rate row | **64px** min (`rowMinHeight`) | ≥3 rows ≈ 192px |
| Charts header compact | ≤ **120px** | Micro + pair + rate + delta |
| Charts plot | ≥ **280px** (flex) | `Expanded` in chart section |
| Charts metric rail | ≤ **56px** | Single row, no stacked pills |
| Settings first section | visible without scroll | Title + Conversion header + 1 tile |

### Radii & elevation

- **No new drop shadows** on list rows or chart plot.
- Shadows only: floating nav, selected chips, swap FAB — use existing `subtleShadow` / `floatingShadow`.
- Instrument panels: border + fill contrast only.

---

## Global patterns (G2-*)

| ID | Rule |
|----|------|
| G2-1 | 3-tab shell only — Convert (0), Charts (1), Settings (2) |
| G2-2 | Favorites deferred — no nav item |
| G2-3 | All tab bodies use `BottomTabFrame`; scroll padding via `tabScrollBottomPadding` |
| G2-4 | **Instrument panel** primitive: shared `InstrumentPanel` widget (new) — `containerHigh` fill, hairline border, optional header rail |
| G2-5 | **Canvas depth:** optional `Scaffold` body gradient (bottom 35% warm shift) — static `DecoratedBox`, no images |
| G2-6 | **Motion budget:** `AnimatedSwitcher` 200–280ms for amount/range/pair; `AnimatedContainer` 180ms for accents; no Lottie, no spring chains |
| G2-7 | **State illustrations:** empty/error use branded icon treatment (forest line icon in moss/coral circle — not raw `Icons.*` gray) |
| G2-8 | Flags: consistent **36px** circle, 1px border `@ border 20%`, no per-row size drift |
| G2-9 | Dividers: `0.5px` `@ border 15%` between rows; instrument panels use **1px** outer edge |
| G2-10 | Stitch = exploration only; ship Flutter + screenshot diff |

---

## Screen specs — bold (D2-*)

### Convert — instrument desk (D2-CON-*)

**Metaphor:** Single **conversion instrument** — top well for amount, bottom **ledger** for rates. Not a settings form.

| ID | Requirement | v1 → v2 delta |
|----|-------------|---------------|
| D2-CON-1 | **Hero amount well** — `containerHigh` instrument panel, `heroAmount` typography, base pill embedded in well (right or below on narrow) | Panel is flat padding + hairline today |
| D2-CON-2 | **Micro rail hierarchy** — “CONVERT” moss micro + Fraunces omitted here; amount is sans hero; refresh/more as icon buttons in rail | `AmountHeaderRow` still competes with amount |
| D2-CON-3 | **Status as signal strip** — single line: freshness + ECB hint icon; moss dot = fresh, amber = cached, coral = error (no paragraph) | `AmountStatusBar` exists — tighten to one line |
| D2-CON-4 | **Ledger section** — full-width divider list; active row: 3px forest accent + `trendUp` wash; inactive transparent | Mostly done — increase wash subtlety consistency |
| D2-CON-5 | **Rates header** — `InstrumentSectionLabel` “RATES” micro style (uppercase optional) + ghost “Edit” text button, not heavy `PillAction` | Reduce visual weight of Add |
| D2-CON-6 | **Rename/delete `AmountCard`** — public API is `ConvertInstrumentHeader` or use `AmountPanel` directly | Remove card naming |
| D2-CON-7 | Empty/error: `DesignedStatePanel` (extends inline pattern) — title + one line + forest text button | Replace generic `InlineEmptyPanel` on Convert |
| D2-CON-8 | **Motion:** amount changes animate with `AnimatedSwitcher` (fade + 4px slide), base pill swap cross-fades flag | Static today |
| D2-CON-9 | First viewport: hero + ≥3 rows (see budgets) | Verify SE |
| D2-CON-10 | Ad shelf: visually **separate instrument footer** — top hairline, `container` strip, banner + coral Remove Ads inline | Integrate, not floating rectangle |

**Must not:** Card wrapping amount or rows; admin counts; paywall on launch; RUB.

---

### Charts — flagship surface (D2-CHT-*)

**Metaphor:** **Market instrument** — chart dominates; controls orbit the plot.

| ID | Requirement | v1 → v2 delta |
|----|-------------|---------------|
| D2-CHT-1 | **Compact chart masthead** — pair in Fraunces `pairTitleFraunces`; rate + delta on one baseline; swap as 44px circle (keep) | Header ~140px+ today |
| D2-CHT-2 | **Plot-first layout order:** masthead → **chart block (range top edge + plot)** → integrated pair strip → metric rail | Pair selector still below plot |
| D2-CHT-3 | **Full-bleed plot** — chart paints edge-to-edge inside block; grid lines `@ border 8%`; no inner card | Border box exists — reduce “boxiness” |
| D2-CHT-4 | **Range rail** — flush to top of plot, `container` fill, horizontal scroll chips; locked ranges show lock + snackbar | Attached but visually separate chip container |
| D2-CHT-5 | **Integrated pair strip** — slim row: base pill | swap | quote pill; lock badge on locked codes; **no large shadows** | `pair_selector.dart` heavy pills |
| D2-CHT-6 | **Metric rail** — single horizontal row: High · Low · Change · Period — divider-separated, **not** three oval pills | Replace `ChartSummary` layout |
| D2-CHT-7 | **Touch overlay** — tooltip uses `container` + forest border; values in `ChartThemeText` | Audit complete from v1 |
| D2-CHT-8 | Empty/error: designed copy — “No history yet” / “Offline — showing cache” with retry | Personality + tone |
| D2-CHT-9 | Swap motion: keep flip for pair swap; range change uses fade only (no flip) | Already partial |
| D2-CHT-10 | First viewport: masthead ≤120px + plot ≥280px on SE | Layout constraint |
| D2-CHT-11 | Monetization: locked pair sheet + rewarded player **forest overlay** — no Material green/red | v1 themed — verify contrast |
| D2-CHT-12 | Ad shelf matches Convert integrated footer pattern | Consistency |

**Must not:** Card around chart; `Wrap` chip clouds without scroll; neon rewarded UI.

---

### Settings — calm utility (D2-SET-*)

**Metaphor:** **Trust desk** — grouped divider lists; premium is one calm shelf, not a marketing landing page.

| ID | Requirement | v1 → v2 delta |
|----|-------------|---------------|
| D2-SET-1 | `ScreenTitle` + increased top breathing (`space7`) | Minor |
| D2-SET-2 | Sections: moss uppercase `SectionHeader` + **no outer card** around groups | Tiles already divider-based |
| D2-SET-3 | **Premium row group** — `UpgradeShelf` becomes **divider-integrated**: title row + inline purchase rows, not floating 16px padded card | Major visual change |
| D2-SET-4 | Subscription + Restore as normal `SettingsTile` rows below shelf | Reduce card prominence |
| D2-SET-5 | Data: ECB explanation as **one** `SettingsTile` with subtitle; detail via navigation only | Trim inline paragraphs |
| D2-SET-6 | `data_details_page` / `data_sources_page`: replace `_DetailSection` / `_SourceCard` with `_DetailBlock` — title + bullet lines separated by dividers | Remove card soup |
| D2-SET-7 | Clear cache: only coral destructive button in app | Keep |
| D2-SET-8 | Dark mode: instrument panels use dark `container` equivalents | Audit hardcoded light fills |

**Must not:** Stacked premium cards; account settings; purchasable subscription in v1.

---

### Favorites (deferred — D2-FAV-*)

| ID | Requirement |
|----|-------------|
| D2-FAV-1 | No tab in v2 implementation pass |
| D2-FAV-2 | When Phase 2 enables: reuse Convert ledger row + instrument patterns |

---

## Monetization — integrated, not bolted-on (M2-*)

| ID | Surface | v2 visual demand |
|----|---------|------------------|
| M2-1 | Banner | Fixed-height strip inside `AdSupportShelf` footer instrument — `container` bg, top hairline |
| M2-2 | Remove Ads CTA | Coral text link right-aligned under banner — `coralSurface` optional pill background |
| M2-3 | Settings premium | Divider-group shelf; forest primary buttons; owned state = moss badge inline |
| M2-4 | Charts Pro / lock sheet | Sheet header Fraunces; options as divider rows, not stacked cards |
| M2-5 | Rewarded player | Full-screen forest ink overlay; moss progress; coral cancel |
| M2-6 | Chart pair locks | Lock icon on pair strip; 24h badge uses `trendUp` tint — not iOS blue |
| M2-7 | Remove Ads hides **all** ad + rewarded prompts | Unchanged policy |

**Product gate (unchanged):** AdMob placeholder OK for polish; live SDK is separate release decision.

---

## States matrix (v2)

| Surface | States | v2 UI demand |
|---------|--------|--------------|
| Convert | fresh, refreshing, cached, stale, error, empty | Signal strip color + icon; ledger skeleton shimmer optional (simple opacity pulse, no package) |
| Charts | loading, fresh, cached, stale, error, empty | Plot area shows designed empty/error **inside** chart bounds; loading: thin moss indeterminate line at top of plot |
| IAP | loading, success, unavailable | `IapPurchasePlayer` uses theme surfaces only |
| Entitlements | locked/unlocked, 24h temp | Consistent badges on pair strip + picker sheet |
| Dark | all above | Same hierarchy; no light-gray chips on dark scaffold |

---

## Anti-generic checklist (stricter than v1)

**Fail v2 if any:**

- [ ] Side-by-side with v1 baseline fails S2-1 (non-dev obvious diff)
- [ ] Convert still reads as “labeled form + list” without instrument well
- [ ] Charts pair selector + oval metric pills dominate over the plot on SE screenshot
- [ ] Settings Premium still looks like a marketing card floating on paper
- [ ] iOS blue, purple gradient, or neon crypto styling anywhere
- [ ] `Card(` widget on primary tab content areas
- [ ] Gray centered empty state in a white box
- [ ] Fraunces on rate rows or settings subtitles
- [ ] New drop shadows on rows or chart background
- [ ] `FittedBox` scaling primary hero amount or control labels

**Pass v2 if all:**

- [ ] S2-1 through S2-10 satisfied
- [ ] Warm paper + forest/moss/coral visible in every tab screenshot
- [ ] Hero hierarchy obvious in Convert and Charts within 1 second
- [ ] `./scripts/check.sh` clean
- [ ] Traceability table in implementation doc complete

---

## Implementation waves (maximum visible impact first)

| Wave | Focus | Visible outcome |
|------|-------|-----------------|
| **A — Convert + canvas + tokens** | Hero instrument, typography tokens, gradient canvas, rename AmountCard, designed empty states, ad footer | **Daily tab transforms** — biggest user-facing win |
| **B — Charts flagship** | Masthead compact, plot-first layout, pair strip, metric rail, empty/error personality | Charts tab looks like a different product class |
| **C — Settings calm + data pages** | Premium divider group, detail page de-card, dark audit | Settings trust surface matches Convert/Charts quality |
| **D — Motion + polish pass** | Amount/range animations, flag consistency, haptics audit, screenshot sign-off | Subtle craft; completes S2-1 |

Waves A and B may run in parallel by file ownership after A.0 token landing.

Detail: `.plan/UI_REDESIGN_IMPLEMENTATION.md`.

---

## Quality gate

| Gate | Action |
|------|--------|
| Static + unit | `./scripts/check.sh` |
| Reinstall | `IOS_SIMULATOR_ID=… ./.devtools/sim_reinstall_build.sh` |
| Baseline vs v2 | Compare `.tmp/screens/ios/ui-redesign-baseline/` vs `ui-redesign-v2/` |
| Non-dev test | 3 viewers, no coaching — record pass/fail for S2-1 |
| Text scale | 1.3× and 2.0× Convert hero + Charts range |
| Anti-generic | Checklist above signed in PR |
| Traceability | Implementation doc D2-* table complete |

---

## Open decisions (product input)

| Topic | v2 recommendation | Status |
|-------|-------------------|--------|
| Canvas gradient | Static 3-stop warm gradient on scaffold body — low cost | **Proposed** |
| Hero amount inline edit | Keep tap → sheet, but **display** at 48–52px in instrument well | **Proposed** |
| Charts pair strip position | Below plot (orbit layout) — not in masthead | **Proposed** |
| Metric rail vs pills | Divider row replaces oval pills | **Proposed** |
| AdMob live vs placeholder | Placeholder OK until store submission gate | **Needs product call** |
| `UpgradeShelf` card removal | Divider-integrated premium group | **Proposed** |

---

## Demand ID index

| Prefix | Domain |
|--------|--------|
| `S2-*` | Success criteria |
| `G2-*` | Global layout |
| `D2-CON-*` | Convert |
| `D2-CHT-*` | Charts |
| `D2-SET-*` | Settings |
| `D2-FAV-*` | Favorites (deferred) |
| `M2-*` | Monetization |

---

## References

- v1 spec: git history of `.plan/UI_REDESIGN.md` pre-v2
- Product: `DEFINITIONS.md`, `ROADMAP.md`, `PLAN.md`
- Visual: `DESIGN.md`, `.agent/DESIGN_GUIDELINES.md`
- Workflow: `AGENTS.md`, `.agent/monetization-access-rules.md`
- Skills: `frontend-design-layer`, `frontend-design-direction`, `design-system-consistency`, `mobile-ui-review`, `small-screen-ui-review`, `chart-ux-review` (shared)
