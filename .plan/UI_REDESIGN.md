# UI Redesign — Play Store Demand Spec

> **Status:** Validated against `lib/src/` (May 2026). Demand document only — not implementation.
> **Scope:** Phase 1 Play Store polish · version `0.x.x` · privacy-first · no backend/accounts/analytics
> **Shell:** 3 tabs — **Convert · Charts · Settings** (Favorites code retained, tab hidden until Phase 2)

---

## Executive summary

Ship a **Play Store–ready** currency converter that feels unmistakably **Niduna**: warm paper canvas, forest-green interaction, editorial Fraunces headlines, divider-led lists — not generic fintech cards or iOS-blue utility chrome.

The codebase already implements much of the Stitch-derived direction (floating pill nav, `BottomTabFrame`, `AdSupportShelf`, monetization stubs, dark `AppTheme.dark`). This spec defines **what must still change** and **what must not regress** during the polish pass.

### Success criteria (Play Store bar)

| # | Criterion |
|---|-----------|
| S-1 | A reviewer can identify Niduna brand with nav hidden (palette + typography + dividers). |
| S-2 | `./scripts/check.sh` passes with zero analyzer errors before release. |
| S-3 | Compact phone + text scale `1.3×` and `2.0×` — no clipped primary labels, no broken main flows. |
| S-4 | Touch targets ≥ `48×48` logical px on custom controls (store checklist). |
| S-5 | Monetization surfaces match `DEFINITIONS.md` / `ROADMAP.md` (banner, Remove Ads, Charts Pro, chart locks, rewarded unlock). |
| S-6 | No Phase 2 leakage (accounts, backend sync, intraday as “available”, RUB, tracking). |
| S-7 | Screens respect `AGENTS.md` file budgets (orchestrator screens ≤ ~80 lines; split oversized files). |

---

## Lessons from the first attempt

**What failed**

- Demand doc treated the app as stub-only; many patterns are **already in code** but unevenly applied.
- Generic patterns returned: card-wrapped empty states (`NoRatesCard`), admin toolbar copy (“*N* currencies visible”), chart layout that reads as stacked widgets rather than one instrument.
- Token docs (`DESIGN.md`) drifted from `AppTheme` (padding, `containerHigh`, muted/subtle hex, micro size).
- `charts_screen.dart` grew to **249 lines** — violates modularity guardrails.

**What to keep**

- `AmountHeaderRow` Fraunces “Convert” + micro “Niduna” rail.
- `CurrencyRateRow` divider rows with left accent (not cards).
- `FloatingPillNav` 3-tab shell, `BottomTabFrame` bottom inset math.
- `UpgradeShelf` single premium shelf (not stacked IAP cards).
- `MonetizationController` entitlement model and chart-pair lock flows.
- `ChartLinePlot` axis labels using `AppTheme.muted` (fix any remaining hardcoded chart text in overlays).

**This pass must**

1. Close **visual cohesion** gaps (layout order on Charts, remove card empty states, unify padding via tokens).
2. Sync **canonical tokens** across `AppTheme`, `DESIGN.md`, and new `.agent/DESIGN_GUIDELINES.md`.
3. Finish **store-readiness QA** loop (screenshots, text scale, traceability).

---

## Brand & visual identity

| Pillar | Demand |
|--------|--------|
| Posture | Privacy-first precision instrument — warm, trustworthy, crafted. |
| Canvas | Warm paper `#F6F8EF` — never full-screen stark white. |
| Accent | Forest leaf `#285F3B` — never `#007AFF` or purple gradients. |
| Typography | **Fraunces** = screen/chart headlines only; **Manrope** = all operational UI. |
| Structure | **Dividers, not cards** for lists/rows; `card` token = selected chip / raised control only. |
| Charts | Full-bleed plot on paper; range rail **visually attached** to chart block. |
| Motion | Subtle, purposeful (swap flip on Charts OK); no decorative motion. |

**Anti-palette:** iOS blue, neon crypto gradients, cold corporate gray text, centered SaaS empty panels.

---

## Design tokens (canonical)

**Source of truth for implementation:** `lib/src/core/theme/app_theme.dart` (`AppTheme`).

Sync targets (must match after Phase 0): `DESIGN.md`, `.agent/DESIGN_GUIDELINES.md`.

### Colors

| Token | Canonical value | Notes |
|-------|-----------------|-------|
| `bg` | `#F6F8EF` | Scaffold / page |
| `text` | `#171D14` | Primary ink |
| `muted` | `#5F6A58` | **Code value** — sync `DESIGN.md` from `#707B68` |
| `subtle` | `#66745B` | **Code value** — sync `DESIGN.md` from `#88987A` |
| `card` | `#FFFFFF` | Selected chips / raised controls only |
| `container` | `#FFF9EC` | Nav, warm rails |
| `containerHigh` | `#F5EDEE` | **Fixed in code** — fix `DESIGN.md` typo `#F5EDE` |
| `border` | `#3B5D24` @ 14–22% alpha | Dividers |
| `primary` | `#285F3B` | Interactive |
| `trendUp` | `#6F8C49` | Positive |
| `trendDown` | `#DC6543` | Negative / destructive CTA |
| `greenBadge` / `greenBadgeText` | `#EDF5EB` / `#3D6E2C` | Rate value pills |

**Dark mode (in scope):** `AppTheme.dark` exists; Settings toggle via `AppPreferences.isDarkMode`. Demand: audit all screens for hardcoded light-only colors (e.g. `rewarded_ad_player.dart` system greens/reds).

### Typography (Flutter numeric)

| Style | Size | Weight | Letter spacing | Use |
|-------|------|--------|----------------|-----|
| `display` | 32 | 800 | -0.5 | Rare hero numbers |
| `heading` | 22 | 700 | default | Section titles (sans) |
| `body` | 16 | 500 | default | Default copy |
| `caption` | 12 | 600 | default | Metadata |
| `micro` | 11 | 700 | 0.5 | Badges, section tags |
| Fraunces headline | 28–29 | 800 | -0.5 to -0.6 | Convert, Charts pair, Settings title |

`DESIGN.md` `letterSpacing: -0.5em` entries are **invalid for Flutter** — use px values above.

### Spacing & layout (resolved)

| Rule | Canonical | Rationale |
|------|-----------|-----------|
| Horizontal page padding | **`20px`** (`AppTheme.pagePadding`) | Entire `lib/` already uses `EdgeInsets` 20; `DESIGN.md` 16px is stale |
| Section vertical gap | **24px** | Settings pattern |
| Row min height | **64px** (`AppTheme.rowMinHeight`) | Touch-friendly |
| 8px base scale | 4 / 8 / 12 / 16 / 20 / 24 / 32 | Half-steps for micro gaps |

### Radii & chrome

| Token | Value |
|-------|-------|
| `radius` | 12 |
| `cardRadius` | 16 |
| `pillRadius` | 20 |
| Floating nav height | 64 |
| Floating nav bottom offset | 0 |
| Bottom dock gap | 8 |
| Nav outer radius | 32 (pill container) |

### Bottom chrome

- All tab bodies use `BottomTabFrame` + shared nav metrics.
- Ad + Remove Ads CTA: `AdSupportShelf` on Convert and Charts when `monetization.adsEnabled`.
- Footer clearance = safe area + `floatingNavHeight` + `bottomDockGap` (no per-screen magic `96` padding except migrate to frame).

---

## Global layout rules

| ID | Rule |
|----|------|
| G-1 | **3-tab shell only** in `AppShell` — Convert (0), Charts (1), Settings (2). |
| G-2 | **Favorites deferred** — `favorites_screen.dart` stays; no nav item until Phase 2. |
| G-3 | Use `AppTheme.pagePadding` (or `EdgeInsets.symmetric(horizontal: AppTheme.pagePadding)`) — eliminate scattered magic `20` over time. |
| G-4 | Max widget nesting **3 levels** for list rows; `build()` ≤ ~30 lines per widget. |
| G-5 | No card-inside-card for list content; one intentional shelf (`UpgradeShelf`, `RangeSelector` rail) per region. |
| G-6 | Fraunces never on body/caption/micro; Manrope never on primary screen titles. |
| G-7 | Custom controls ≥ `48×48` logical px. |
| G-8 | Stitch = exploration only; ship Flutter + screenshot QA. |

---

## Screen specs

### Convert (D-CON-*)

**Must have (many implemented — verify polish)**

| ID | Requirement | Code anchor |
|----|-------------|-------------|
| D-CON-1 | Fraunces “Convert” + micro “Niduna” header | `amount_header_row.dart` |
| D-CON-2 | Amount instrument: large value + inline base pill | `amount_value_row.dart`, `amount_base_button.dart` |
| D-CON-3 | Freshness rail: last updated + `(i)` ECB daily tooltip | `amount_status_bar.dart`, `daily_rates_info_sheet.dart` |
| D-CON-4 | Rate ledger: divider rows, left accent on active, `ValuePill` rates | `currency_rate_row.dart`, `quote_value.dart` |
| D-CON-5 | States: fresh, refreshing, cached/stale, error, empty | `ConvertStatus`, `no_rates_card.dart` |
| D-CON-6 | Banner + Remove Ads CTA when ads enabled | `ad_support_shelf.dart` |
| D-CON-7 | Favorite star per row (max 3) | controller + row actions |

**Must not / fix**

| ID | Requirement |
|----|-------------|
| D-CON-8 | No “*N* currencies visible” admin toolbar — replace with compact “Rates” + single **Add/Edit** affordance or remove subtitle |
| D-CON-9 | No card-wrapped empty state — inline empty panel on paper (icon + one line + retry) |
| D-CON-10 | No card wrapper around amount block (`AmountCard` → name `AmountPanel` only in UI copy) |
| D-CON-11 | No transfers, accounts, RUB, paywall modals on core flow |

**First viewport (compact):** amount + base pill + **≥3 rate rows** visible without scroll.

---

### Charts (D-CHT-*)

**Must have**

| ID | Requirement | Code anchor |
|----|-------------|-------------|
| D-CHT-1 | Fraunces pair headline + moss/coral change chip | `chart_header.dart` |
| D-CHT-2 | Full-bleed chart (no card box) | `rate_chart.dart`, `chart_line_plot.dart` |
| D-CHT-3 | Range rail: fiat `1W–2Y`; crypto max `1Y`; locked intraday toast copy per ROADMAP | `chart_range.dart`, `range_selector.dart` |
| D-CHT-4 | Pair selector warm rail; lock UI + `locked_pair_action_sheet.dart` | `pair_selector.dart` |
| D-CHT-5 | Summary metrics compact below chart area | `chart_summary.dart` |
| D-CHT-6 | Default free pair USD↔EUR; Charts Pro / rewarded 24h unlock | `MonetizationController` |
| D-CHT-7 | Banner shelf same as Convert | `charts_screen.dart` footer |
| D-CHT-8 | Axis/overlay text uses `AppTheme` text styles | audit `chart_touch_overlay.dart`, `chart_line_plot.dart` |

**Layout demand (gap vs current)**

| ID | Requirement | Current state |
|----|-------------|---------------|
| D-CHT-9 | **Range selector visually attached to chart** — pair selector + summary **below** chart or in collapsible rail | Today: header → range → chart → pair → summary |
| D-CHT-10 | Reorder to: compact header → chart block (range top or bottom edge of chart) → pair rail → metrics |
| D-CHT-11 | Split `charts_screen.dart` (249 lines) into orchestrator + `charts_body.dart` + state widgets |

**Must not**

- Card container around chart
- Noisy always-on axis labels; prefer sparse anchors + touch reveal (`chart_touch_overlay`)
- `Wrap` chip clouds on narrow width without scroll
- `rewarded_ad_player` default Material greens/reds in production skin

**First viewport:** pair title + current rate + **top of chart** visible; range attached to chart edge.

---

### Settings (D-SET-*)

**Must have**

| ID | Requirement |
|----|-------------|
| D-SET-1 | Fraunces “Settings” title |
| D-SET-2 | Section headers uppercase moss (`section_header.dart`) |
| D-SET-3 | Divider tiles — `SettingsTile`, not stacked cards |
| D-SET-4 | Conversion: base, decimals, dark mode (free) |
| D-SET-5 | Data: freshness explanation, clear cache (coral destructive), provider disclosure |
| D-SET-6 | Premium: `UpgradeShelf` + Subscription “Soon” + Restore |
| D-SET-7 | Dev Sandbox only when `APP_DEV_MODE` or version unlock |
| D-SET-8 | About/privacy/version/provider profile |

**Must not**

- Long explanatory paragraphs above controls
- Multiple stacked premium cards (single shelf + subscription row OK)

---

### Favorites (deferred — D-FAV-*)

| ID | Requirement |
|----|-------------|
| D-FAV-1 | **No tab in v1** — document only; re-enable with Phase 2 |
| D-FAV-2 | When enabled: max 3 pairs, local-only, jump to Convert context |
| D-FAV-3 | Redesign pass may restyle `favorites_screen.dart` but not blocking Play Store |

---

## Cross-cutting states

| Surface | States | Demand |
|---------|--------|--------|
| Convert rates | fresh, loading refresh, cached, stale/offline, error, no cache | Clear copy + color via status rail, not paragraphs |
| Charts | loading, fresh, cached, stale, error, empty | No centered card panels; retry inline |
| Network | offline-first | Show cache timestamp; never blank crash |
| IAP | loading, success, unavailable | `iap_purchase_player.dart` — stub OK for MVP |
| Entitlements | ads on/off, pair locked/unlocked, temp 24h badge | Consistent across Charts picker |

---

## Monetization surfaces (Phase 1)

| ID | Surface | Location | Product |
|----|---------|----------|---------|
| M-1 | Banner placeholder → AdMob | `AdBannerPlaceholder` in `AdSupportShelf` | Ads when `adsEnabled` |
| M-2 | Remove Ads text CTA | `RemoveAdsButton` below banner | 1.99 CHF one-time |
| M-3 | Settings premium shelf | `UpgradeShelf` | Remove Ads + Charts Pro pills |
| M-4 | Subscription row | `PremiumSection` | Informational “Not available in v1” |
| M-5 | Restore purchases | `PremiumSection` | Local restore stub |
| M-6 | Chart pair lock sheet | `locked_pair_action_sheet.dart` | Charts Pro / rewarded |
| M-7 | Rewarded ad player | `rewarded_ad_player.dart` | 24h pair unlock; theme-aligned colors |
| M-8 | Intraday ranges | `RangeSelector` | Locked + snackbar “coming soon” |
| M-9 | Dev entitlements | `dev_sandbox_section.dart` | Dev only |

**Policy reminders:** Remove Ads hides **all** ad surfaces and rewarded offers; subscription stub must not imply purchasable v1.

---

## Anti-patterns & anti-generic checklist

**Fail release polish if any:**

- [ ] Looks like default Material / iOS utility converter
- [ ] iOS blue, purple gradient, neon crypto styling
- [ ] Card-wrapped list rows or chart area
- [ ] Card-centered empty states on primary tabs
- [ ] Fraunces on body text; Manrope on screen titles
- [ ] `FittedBox` on control labels; `Row + Expanded` segments + extra chip on narrow phones
- [ ] Admin copy (“N currencies visible”) on Convert
- [ ] Chart range disconnected from chart visually
- [ ] Hardcoded non-theme colors on chart chrome (audit overlays + rewarded player)

**Pass if all:**

- [ ] Warm paper + forest/moss/coral visible on every tab screenshot
- [ ] Divider-led lists on Convert
- [ ] Floating paper-warm nav
- [ ] First useful action immediate per tab
- [ ] Text scale 1.3× / 2.0× without broken primary layout
- [ ] `./scripts/check.sh` clean

---

## Store-readiness QA

1. Seeded iOS/Android screenshots: Convert, Charts (free + locked pair), Settings (Premium + Data).
2. Smallest device: iPhone SE class or small Android emulator.
3. Text scale 1.3× and 2.0× on Convert range/chips and Charts pair/range rails.
4. Widget tests with `flutter_test` text scale for fragile controls (add keys per ROADMAP).
5. Privacy store copy aligned when real AdMob ships.
6. Version label `0.x.x` in `pubspec.yaml` and Firebase scripts.

Commands: see `AGENTS.md` — `capture_ios_ui_review_bundle.sh`, `sim_reinstall_build.sh`, `./scripts/check.sh`.

---

## Implementation order (vertical slices)

| Order | Slice | Outcome |
|-------|-------|---------|
| 1 | **Phase 0 — Tokens** | `AppTheme` + doc sync + `DESIGN_GUIDELINES.md` |
| 2 | **Phase 1 — Shared primitives** | Padding helper, empty inline panel, theme text for charts |
| 3 | **Phase 2 — Convert polish** | Toolbar copy, empty state, padding consistency |
| 4 | **Phase 3 — Charts polish** | Layout reorder, file split, overlay theme audit |
| 5 | **Phase 4 — Settings polish** | Tile consistency, data copy, premium shelf density |
| 6 | **Phase 5 — Cross-cutting** | Nav/ad clearance, dark mode audit, real AdMob hook (optional) |
| 7 | **Phase 6 — Verification matrix** | Screenshots + sign-off |

Detail: `.plan/UI_REDESIGN_IMPLEMENTATION.md`.

---

## Quality gate

| Gate | Command / action |
|------|------------------|
| Static + unit | `./scripts/check.sh` |
| Reinstall QA | `IOS_SIMULATOR_ID=… ./.devtools/sim_reinstall_build.sh` |
| Screenshots | `./.devtools/capture_ios_ui_review_bundle.sh` or tab capture |
| Anti-generic | Checklist above signed in PR/issue |
| Traceability | Implementation doc table complete |

---

## Demand ID index

| Prefix | Domain |
|--------|--------|
| `S-*` | Success criteria |
| `G-*` | Global layout |
| `D-CON-*` | Convert |
| `D-CHT-*` | Charts |
| `D-SET-*` | Settings |
| `D-FAV-*` | Favorites (deferred) |
| `M-*` | Monetization |

---

## Open decisions (user input)

| Topic | Recommendation | Status |
|-------|----------------|--------|
| Page padding 16 vs 20 | **20px** — code wins; update `DESIGN.md` | **Resolved** — implement unless product overrides |
| `muted` / `subtle` hex | **AppTheme values** — update `DESIGN.md` | **Resolved** |
| `containerHigh` | **`#F5EDEE`** | **Resolved** |
| Real AdMob vs placeholder in v1 | Placeholder OK for polish; real SDK separate release task | **Needs product call** if Play Store submission requires live ads |
| Favorites tab hidden | Confirmed v1 | **Resolved** per `DEFINITIONS.md` |

---

## References

- Product: `DEFINITIONS.md`, `ROADMAP.md`, `PLAN.md`
- Visual portable spec: `DESIGN.md` (sync after token phase)
- Agent workflow: `AGENTS.md`, `.agent/monetization-access-rules.md`
- Skills: `frontend-design-layer`, `frontend-design-direction`, `design-system-consistency`, `mobile-ui-review`, `small-screen-ui-review`
