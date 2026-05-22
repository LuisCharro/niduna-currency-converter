# Design Guidelines — Currency Converter

> Canonical demand spec: [.plan/UI_REDESIGN.md](../.plan/UI_REDESIGN.md)  
> Token source of truth: `lib/src/core/theme/app_theme.dart` (`AppTheme`)  
> Portable token mirror: `DESIGN.md` (sync after token changes)

## Product posture

- Privacy-first precision instrument: no backend, accounts, analytics, or cloud sync in Phase 1.
- Three-tab shell only: **Convert · Charts · Settings** (Favorites code retained, tab hidden until Phase 2).
- Version stays `0.x.x` until MVP is explicitly confirmed.

## Visual identity

| Pillar | Rule |
|--------|------|
| Canvas | Warm paper `#F6F8EF` — never full-screen stark white |
| Accent | Forest leaf `#285F3B` — never iOS blue or purple gradients |
| Typography | **Fraunces** = screen/chart headlines only; **Manrope** = all operational UI |
| Structure | **Dividers, not cards** for lists/rows; `card` token = selected chip / raised control only |
| Charts | Full-bleed plot on paper; range rail visually attached to chart block |

**Anti-palette:** iOS blue, neon crypto gradients, cold corporate gray, centered SaaS empty panels.

## Canonical tokens

Implement and read colors from `AppTheme` — do not duplicate hex in widgets.

| Token | Value |
|-------|-------|
| `bg` | `#F6F8EF` |
| `text` | `#171D14` |
| `muted` | `#5F6A58` |
| `subtle` | `#66745B` |
| `primary` | `#285F3B` |
| `container` | `#FFF9EC` |
| `containerHigh` | `#F5EDEE` |
| `trendUp` / `trendDown` | `#6F8C49` / `#DC6543` |

**Layout:** `pagePadding` / `pageInsets` = 20px horizontal; `sectionGap` = 24px; `rowMinHeight` = 64px.

**Dark mode:** `AppTheme.dark` — scaffold `#171D14`, paper text `#F6F8EF`, selected nav moss `#6F8C49`. Toggle in Settings; audit new UI for hardcoded light-only colors.

## Typography rules

- Use `AppTheme.screenTitleFraunces` (or `ScreenTitle` widget) for Convert, Charts pair headline, Settings title.
- Never Fraunces on body, caption, micro, or currency codes.
- Never Manrope on primary screen titles.

## Layout & bottom chrome

- All tab bodies use `BottomTabFrame` + shared nav metrics (`floatingNavHeight`, `bottomDockGap`).
- Ad + Remove Ads: `AdSupportShelf` on Convert and Charts when `monetization.adsEnabled`.
- Do not add per-screen magic bottom padding when the frame already clears the nav.

## Dividers-not-cards

- List rows: `DividerListRow` / hairline dividers on paper — no `Card` wrapper.
- Empty/error on primary tabs: `InlineEmptyPanel` on paper — no boxed empty state.
- Allowed raised surfaces: `UpgradeShelf`, `RangeSelector` rail, selected chips, touch overlay tooltip.

## Monetization visual rules

- Single premium shelf (`UpgradeShelf`) + subscription “Soon” row — no stacked IAP cards.
- Remove Ads CTA: coral tint (`#FDF0EC` / `#B54E48`).
- Rewarded ad player: theme-aligned overlay (forest/moss/coral), not Material green/red.
- Subscription row must not imply purchasable v1.

## File budgets (AGENTS.md)

| Type | Max lines |
|------|-----------|
| Screen orchestrator | ~80 |
| Shared widget | ~60 |
| Split immediately when file exceeds 200 lines or `build()` > ~30 lines |

## Verification loop

1. `./scripts/check.sh`
2. Hot restart / `sim_reinstall_build.sh` on simulator
3. Screenshots vs design intent (not code diff alone)
4. Text scale 1.3× and 2.0× on Convert amount row and Charts range/pair rails
5. Anti-generic checklist in `UI_REDESIGN.md`

## Stitch

Exploration only via Stitch workflow — **never** paste generated code into `lib/`.
