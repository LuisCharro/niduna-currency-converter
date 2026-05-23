# Dark Mode Implementation Plan

> **Branch:** `feature/dark-mode` (from `turbo/ui-redesign`)
> **Status:** Planning complete, ready to implement
> **Created:** 2026-05-23

---

## Problem

Dark mode toggle is ON but background stays warm-paper-light and text becomes hard to read. Root cause: all 67 widget files use **179 hardcoded `static const` light-mode colors** from `AppTheme`. When dark mode toggles, only Flutter's internal `ThemeData` switches — custom widgets keep rendering light-mode colors on top of a dark scaffold.

## Solution

Replace all hardcoded `AppTheme.token` references with a brightness-aware `ThemeExtension<AppColors>` pattern. This is the standard Flutter way — every widget automatically responds to theme changes without manual brightness checks.

## New file

`lib/src/core/theme/app_colors.dart` — `ThemeExtension<AppColors>` with:
- All 14 color tokens (light + dark variants)
- Static `.of(context)` resolver
- Registered in `AppTheme.light` and `AppTheme.dark` via `extensions: []`

## Color tokens (light → dark)

| Token | Light | Dark | Rationale |
|---|---|---|---|
| `bg` | `#F6F8EF` | `#141A11` | Deeper than current dark scaffold for more contrast |
| `text` | `#171D14` | `#E8ECE2` | Warm off-white, not pure white |
| `muted` | `#5F6A58` | `#8A9A7E` | Lighter sage for readability |
| `subtle` | `#66745B` | `#7A8B70` | Lighter olive |
| `card` | `#FFFFFF` | `#1E2D18` | Dark green card surface |
| `container` | `#FFF9EC` | `#243520` | Dark moss |
| `containerHigh` | `#F5EDEE` | `#2A3D24` | Slightly lighter moss for instrument fills |
| `border` | `#3B5D24` | `#4D7E32` | Brighter forest for visibility on dark bg |
| `primary` | `#285F3B` | `#6F8C49` | Moss green (already used in dark ThemeData) |
| `trendUp` | `#6F8C49` | `#8AAE62` | Brighter green for dark bg |
| `trendDown` | `#DC6543` | `#E87A5A` | Brighter coral |
| `greenBadge` | `#EDF5EB` | `#2A4024` | Dark green badge surface |
| `greenBadgeText` | `#3D6E2C` | `#8CC47A` | Light green text on dark badge |
| `coralSurface` | `#FDF0EC` | `#3A2520` | Dark coral surface |
| `coralInk` | `#B54E48` | `#E07A6E` | Brighter coral text |

## Text styles needing dark color adaptation

6 styles hardcode `color: AppTheme.text` or `color: AppTheme.muted`:

- `screenTitleFraunces` — color: text
- `heroAmount` — color: text
- `heroAmountCompact` — color: text
- `pairTitleFraunces` — color: text
- `metricValue` — color: text
- `sectionLabel` — color: muted

Solution: Convert to context-aware getter methods that read from `AppColors.of(context)`.

## Shadow adjustments

- `subtleShadow` → dark variant with higher alpha: `Color(0x30FFFFFF)` (white glow on dark)
- `floatingShadow` → dark variant: `Color(0x40FFFFFF)` (subtle white glow)

## Gradient adjustments

- `canvas_background.dart` → dark gradient: `#141A11` → `#1A2616` → `#1E2D18`
- `chart_line_plot.dart` → uses `AppTheme.card` → auto-fixes via token resolution

## Implementation phases

### Phase 1 — Infrastructure (2 files)
- Create `app_colors.dart` ThemeExtension
- Update `app_theme.dart` to register extension + add dark-aware helpers

### Phase 2 — Core shared widgets (~13 files)
- `canvas_background.dart` — dark gradient
- `screen_title.dart` — dark-aware text style
- `floating_pill_nav.dart` + `floating_pill_nav_item.dart`
- `settings_tile.dart`, `divider_list_row.dart`
- `instrument_section_label.dart`, `designed_state_panel.dart`
- `inline_empty_panel.dart`, `pill_action.dart`, `value_pill.dart`
- `remove_ads_button.dart`, `currency_picker_chrome.dart`

### Phase 3 — Convert screen (20 files)
All widgets under `features/convert/widgets/`

### Phase 4 — Charts screen (11 files)
All widgets under `features/charts/widgets/`

### Phase 5 — Settings screen (14 files)
All widgets under `features/settings/widgets/`

### Phase 6 — Remaining (1 file)
- `favorites_screen.dart`

### Phase 7 — Polish + verify
- Shadows, swipe action colors, special cases
- Visual test: light mode still looks correct
- Visual test: dark mode looks correct
- Run `./scripts/check.sh`
- Build and test on iOS simulator

## Mechanical replacement pattern

Every `AppTheme.token` becomes `AppColors.of(context).token`:

```dart
// Before
color: AppTheme.bg
// After
color: AppColors.of(context).bg
```

Every `AppTheme.token.withValues(alpha: ...)` becomes:
```dart
AppColors.of(context).token.withValues(alpha: ...)
```

Text styles with hardcoded color get resolved via context:
```dart
// Before
AppTheme.screenTitleFraunces
// After
AppTheme.screenTitleStyle(context)
```

## What stays unchanged

- `currency_colors.dart` — currency brand colors (same in both modes)
- `AppTheme` spacing, radii, sizes — not brightness-dependent
- `Colors.transparent` / `Colors.black.withValues(alpha:)` / `Colors.white` — semantically correct
- `iap_purchase_player.dart` overlay — uses its own dark overlay, OK
- `rewarded_ad_player.dart` overlay — its own overlay colors, review in polish phase
- `currency_row_swipe_actions.dart` swipe action accent colors — brand-colored, OK in both modes
- `amount_status_bar.dart` stale warning gold — semantic color, OK in both modes

## Files affected (67 total)

### New file
- `lib/src/core/theme/app_colors.dart`

### Modified core
- `lib/src/core/theme/app_theme.dart`

### Shared widgets (13 files)
- `lib/src/shared/widgets/canvas_background.dart`
- `lib/src/shared/widgets/screen_title.dart`
- `lib/src/shared/widgets/floating_pill_nav.dart`
- `lib/src/shared/widgets/floating_pill_nav_item.dart`
- `lib/src/shared/widgets/settings_tile.dart`
- `lib/src/shared/widgets/divider_list_row.dart`
- `lib/src/shared/widgets/instrument_section_label.dart`
- `lib/src/shared/widgets/instrument_panel.dart`
- `lib/src/shared/widgets/designed_state_panel.dart`
- `lib/src/shared/widgets/inline_empty_panel.dart`
- `lib/src/shared/widgets/pill_action.dart`
- `lib/src/shared/widgets/value_pill.dart`
- `lib/src/shared/widgets/remove_ads_button.dart`
- `lib/src/shared/widgets/currency_picker_chrome.dart`

### Convert widgets (20 files)
- `lib/src/features/convert/widgets/amount_value_row.dart`
- `lib/src/features/convert/widgets/amount_base_button.dart`
- `lib/src/features/convert/widgets/amount_editing_field.dart`
- `lib/src/features/convert/widgets/amount_input_header.dart`
- `lib/src/features/convert/widgets/amount_input_sheet.dart`
- `lib/src/features/convert/widgets/amount_keypad.dart`
- `lib/src/features/convert/widgets/amount_presets.dart`
- `lib/src/features/convert/widgets/amount_status_bar.dart`
- `lib/src/features/convert/widgets/amount_utility_pill.dart`
- `lib/src/features/convert/widgets/conversion_lens_sheet.dart`
- `lib/src/features/convert/widgets/convert_info_bar.dart`
- `lib/src/features/convert/widgets/convert_label.dart`
- `lib/src/features/convert/widgets/currency_picker_sheet.dart`
- `lib/src/features/convert/widgets/currency_picker_tile.dart`
- `lib/src/features/convert/widgets/currency_rate_row.dart`
- `lib/src/features/convert/widgets/currency_row_swipe_actions.dart`
- `lib/src/features/convert/widgets/daily_rates_info_sheet.dart`
- `lib/src/features/convert/widgets/quote_identity.dart`
- `lib/src/features/convert/widgets/quote_value.dart`
- `lib/src/features/convert/widgets/rates_section_header.dart`
- `lib/src/features/convert/widgets/visible_rates_list.dart`
- `lib/src/features/convert/widgets/ad_banner_placeholder.dart`
- `lib/src/features/convert/widgets/ad_support_shelf.dart`

### Charts widgets (11 files)
- `lib/src/features/charts/widgets/chart_currency_picker_sheet.dart`
- `lib/src/features/charts/widgets/chart_header.dart`
- `lib/src/features/charts/widgets/chart_line_plot.dart`
- `lib/src/features/charts/widgets/chart_metric_rail.dart`
- `lib/src/features/charts/widgets/chart_pair_pill.dart`
- `lib/src/features/charts/widgets/chart_pair_strip.dart`
- `lib/src/features/charts/widgets/chart_theme_text.dart`
- `lib/src/features/charts/widgets/chart_touch_overlay.dart`
- `lib/src/features/charts/widgets/charts_chart_section.dart`
- `lib/src/features/charts/widgets/locked_pair_action_sheet.dart`
- `lib/src/features/charts/widgets/range_selector.dart`
- `lib/src/features/charts/widgets/rewarded_ad_player.dart`

### Settings widgets (14 files)
- `lib/src/features/settings/widgets/base_currency_picker.dart`
- `lib/src/features/settings/widgets/base_currency_tile.dart`
- `lib/src/features/settings/widgets/clear_cache_tile.dart`
- `lib/src/features/settings/widgets/data_details_page.dart`
- `lib/src/features/settings/widgets/data_sources_page.dart`
- `lib/src/features/settings/widgets/decimal_places_tile.dart`
- `lib/src/features/settings/widgets/dev_ads_status_card.dart`
- `lib/src/features/settings/widgets/dev_entitlements_panel.dart`
- `lib/src/features/settings/widgets/premium_section.dart`
- `lib/src/features/settings/widgets/provider_flow_cards.dart`
- `lib/src/features/settings/widgets/provider_matrix.dart`
- `lib/src/features/settings/widgets/provider_profile_card.dart`
- `lib/src/features/settings/widgets/settings_about_section.dart`
- `lib/src/features/settings/widgets/settings_data_section.dart`
- `lib/src/features/settings/widgets/upgrade_shelf.dart`
- `lib/src/features/settings/widgets/version_tile.dart`
- `lib/src/features/settings/widgets/iap_purchase_player.dart`

### Favorites (1 file)
- `lib/src/features/favorites/favorites_screen.dart`
