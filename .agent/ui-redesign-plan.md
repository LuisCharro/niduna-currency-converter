# UI Redesign Plan — "Professional Polish" Cycle

> **Status:** Planning
> **Based on:** Competitor analysis (Currency app / miniapatti screenshots)
> **Reference screens:** `/Users/luis/Downloads/CurrencyApp/` (7 PNGs)
> **Goal:** Transform app from "functional but ugly" to professional, polished design

---

## Competitor Analysis Summary

The competitor app (miniapatti Currency) wins on specific visual elements:

| Element | Competitor | Ours (current) | Gap |
|---------|-----------|-----------------|-----|
| **Background** | Pure white `#FFFFFF` | Gray `#F8F9FA` | Looks dull/unclean |
| **Convert layout** | Clean list rows + dividers | Every row is bordered+shadowed card | Heavy, cluttered |
| **Value display** | Green pill badges on right side | Separate heavy result cards | No visual hierarchy |
| **Bottom nav** | Floating pill container, custom icons | Standard `BottomNavigationBar` | Generic Material look |
| **Chart header** | Huge bold `"USD per 1 EUR"` as main title | Small AppBar "Charts" | Weak hierarchy |
| **Chart area** | Full-bleed, no wrapper, colored gradient fill | Wrapped in card, cramped | Wasted space |
| **Chart line color** | Dynamic: red=down, green=up | Fixed single color | Less informative |
| **Crosshair** | Vertical line + floating date pill + dot | Tooltip card above chart | Less precise |
| **Pair selector** | Large rounded pills with flags inside | Small plain buttons | Low visual weight |
| **Range chips** | Inside rounded gray container bar | Bare horizontal scroll | Uncontained |
| **Borders/Shadows** | Almost none — dividers only | `Border.all` + `softShadow` everywhere | Over-designed |
| **Typography hierarchy** | Clear bold sizes (32/24/16/12) | Weak differentiation | Hard to scan |
| **Spacing** | Generous whitespace | Tight, cluttered | Cramped feel |
| **Currency picker** | Full-screen modal, tab segments, A-Z index strip, search at bottom | Standard bottom sheet | Basic |

### Key Design Principles from Competitor

1. **Less is more** — no card borders, no shadows on list rows. Dividers only.
2. **Color as information** — green pills for values, red/green for trend direction
3. **Full-bleed content** — charts and lists use entire screen width
4. **Floating nav** — pill-shaped bottom nav feels modern and premium
5. **Typography does the work** — size + weight create hierarchy, not boxes

---

## Phase 1 — Foundation (Theme + Layout)

**Goal:** Change the visual foundation so everything immediately looks more professional.

### 1a. Theme Overhaul (`app_theme.dart`)

Current tokens → New tokens:

```
OLD                          NEW
─────────────────────────    ─────────────────────────
bg: #F8F9FA (gray)           bg: #FFFFFF (pure white)
text: #191C1D                text: #1A1A1A (near-black)
muted: #5F5E5E               muted: #8E8E93 (iOS-style gray)
subtle: #717786              subtle: #AEAEB2
card: white                  card: #FFFFFF (same as bg now)
container: #EDEEEF           container: #F2F2F7 (iOS grouped bg)
border: #E1E3E4              border: #C6C6C8 (slightly darker for dividers)
primary: #0058BC             primary: #007AFF (iOS blue, more vibrant)
radius: 12                   radius: 12 (unchanged)
cardRadius: 16               cardRadius: 16 (unchanged)
softShadow: [heavy]          softShadow: [extremely subtle or REMOVED]
                             NEW: trendUp: #34C759 (green)
                             NEW: trendDown: #FF3B30 (red)
                             NEW: pillRadius: 20 (for rounded badges)
                             NEW: display: 32px w800
                             NEW: heading: 22px w700
                             NEW: body: 16px w500
                             NEW: caption: 12px w500
                             NEW: micro: 10px w600
```

Key changes:
- Background becomes pure white — biggest single visual improvement
- Remove or drastically reduce `softShadow` — competitor uses almost no shadows
- Add semantic trend colors (green/red) used throughout app
- Add proper typography scale with clear hierarchy
- Primary blue shifts slightly toward iOS standard (#007AFF) for more vibrancy

### 1b. Bottom Nav → Floating Pill Nav (`app.dart`)

Replace `BottomNavigationBar` with custom floating pill:

```
┌────────────────────────────────────┐
│                                    │
│         [app content]              │
│                                    │
│                                    │
│        ┌──────────────┐            │
│        │  🔄    📈   ⚙️  │  ← floating pill
│        │ Convert Chart Settings │  │
│        └──────────────┘            │
└────────────────────────────────────┘
```

Spec:
- Container: white bg, `borderRadius: 28`, subtle shadow (`0 4 20 rgba(0,0,0,0.08)`)
- Margin-bottom: 24px, horizontally centered
- Width: ~240px (or 60% of screen width)
- Height: 56px
- Icons: custom or Material Symbols Rounded style
  - Convert: `swap_horiz` in circle or custom swap icon
  - Chart: `show_chart` line-graph style
  - Settings: `settings` gear
- Active: primary color icon + primary color label
- Inactive: muted gray icon + muted gray label
- Label font: 11px w600
- Smooth transition on tab switch (150ms)

Files changed:
- `lib/src/core/theme/app_theme.dart`
- `lib/src/app.dart` (new `_FloatingPillNav` widget or extracted file)

---

## Phase 2 — Convert Screen Redesign

**Goal:** Match competitor's clean list-based layout.

### Current Layout (before)

```
┌──────────────────────────────┐
│  🛡️ Niduna Convert  [LOCAL] │  ← Header with branding
│  ● Updated: May 10 16:21 [i]│  ← Info bar
├──────────────────────────────┤
│  ┌──────────────────────────┐│
│  │ YOU SEND     [time] [i]  ││  ← Card with border+shadow
│  │                     [🇺🇸$]││
│  │ 100.00                  ││
│  └──────────────────────────┘│
│  ┌──────────────────────────┐│
│  │ 🇪🇺 EUR          €91.32 ││  ← Card with border+shadow
│  │ Euro              [↔][✕]││
│  └──────────────────────────┘│
│  ┌──────────────────────────┐│
│  │ 🇬🇧 GBP          £79.45 ││  ← Another card...
│  │ British Pound     [↔][✕]││
│  └──────────────────────────┘│
│  ...more cards...            │
└──────────────────────────────┘
```

### Target Layout (after — competitor style)

```
┌──────────────────────────────┐
│                              │
│        Currency          [+][⋮]  ← Minimal header
│                              │
│  ── ── ── ── ── ── ── ── ──  │
│                              │
│  🇨🇭 Swiss Franc      Fr 77.696│  ← Row: flag + name + code + GREEN PILL
│     CHF                        │
│  ─────────────────────────── │  ← Thin divider only
│  🇪🇺 Euro              € 84.796│
│     EUR                        │
│  ─────────────────────────── │
│  🇺🇸 United States D  US$ 100.00│  ← Selected = green filled pill
│     USD                        │
│  ─────────────────────────── │
│  🇬🇧 British Pound      £ 73.346│
│     GBP                        │
│  ─────────────────────────── │
│                              │
│  [ad banner placeholder]      │
│                              │
│    ┌──────────────┐           │
│    │  🔄  📈  ⚙️  │           │  ← Floating pill nav
│    └──────────────┘           │
└──────────────────────────────┘
```

### Specific Changes

**Header (`convert_header.dart`):**
- REMOVE shield icon + "Niduna Convert" branding
- REPLACE with simple centered "Currency" title (like competitor)
- Keep "+" button (add currency) and "..." menu on right
- Optional: remove "LOCAL-ONLY" badge (competitor doesn't show privacy signals)

**Info Bar (`convert_info_bar.dart`):**
- REMOVE entirely or make extremely subtle
- Move timestamp into amount area as small muted text
- Competitor has no status bar at all

**Amount Panel (`amount_panel.dart` → `amount_card.dart`):**
- REMOVE card border + shadow
- Make it a clean area: label row + large input
- Input field: 36px font, w700, letter-spacing -0.5
- Currency selector: flag circle (24px) + code in a rounded button

**Rate List (`visible_rates_list.dart` + `currency_rate_row.dart`):**
- **COMPLETE REDESIGN** — most impactful change:
  - Each row = NO card, NO border, NO shadow
  - Left: flag circle (40px radius)
  - Middle column: currency name (16px w600) + code (12px gray)
  - Right: **green pill badge** with converted value
    - Pill: `roundedRectangle(radius: 8)`, bg `#E8F5E9`, text `#34C759`
    - Selected base currency: solid green bg `#34C759`, white text
  - Between rows: 0.5px `Divider(color: AppTheme.border)`
  - On tap/active: light gray background tint on row (no border change)
  - Swap button: only appears on active/tapped row (not always visible)
  - Close/remove button: swipe-to-dismiss OR long-press menu (not always visible)

**Currency Picker (`currency_picker_sheet.dart`):**
- Upgrade from bottom sheet to **full-screen modal** (like competitor):
  - Rounded top corners (radius 20)
  - Header: "Add Currency" centered + green checkmark (done) top-right
  - Segmented tabs below header: `All | Crypto | Metal` (pill style)
  - "My Location — Switzerland" section at top with local currency pre-selected + green check
  - Alphabetical section headers (A, B, C...) in muted gray
  - Rows: flag (40px) + name bold (16px) + code gray (13px) + radio/check circle (24px)
  - A-Z index strip on right edge (green letters, scrollable)
  - Search bar pinned at bottom of modal: magnifier + "Currency, Country, Region, or Code"
  - This is a major UX upgrade matching competitor 1:1

---

## Phase 3 — Chart Screen Redesign

**Goal:** Full-bleed chart with dynamic colors and professional interaction.

### Current Layout (before)

```
┌──────────────────────────────┐
│  ← Charts                    │  ← AppBar
├──────────────────────────────┤
│  [USD ▼]  ↕  [EUR ▼]       │  ← Pair selector (small buttons)
│  Updated: May 10 16:21       │
│  [1W][1M][3M][6M][1Y]        │  ← Range chips (bare scroll)
│  ┌──────────────────────────┐│
│  │  📈 Chart (in card)      ││  ← Wrapped in card
│  │  with grid lines         ││
│  └──────────────────────────┘│
│  High: 1.20  Low: 0.88       │  ← Summary
│  Change: +2.3%               │
├──────────────────────────────┤
│  [ad banner]                 │
└──────────────────────────────┘
```

### Target Layout (after — competitor style)

```
┌──────────────────────────────┐
│                              │
│  USD per 1 EUR          [↕]  │  ← HUGE title (32px w800) + swap btn
│  US$ 1.1793   ↓ 0.80%       │  ← Rate + change% in one line
│                              │
│  ╭────────────────────────╮  │
│  │  📈📈📈📈📈📈📈📈📈📈  │  │  ← FULL-BLEED chart (no wrapper)
│  │    📈📈📈📈📈📈📈📈📈  │  │     colored gradient fill to edges
│  │  📈📈📈📈📈📈📈📈📈📈  │  │     RED line when down, GREEN when up
│  │    📈📈📈📈📈📈📈📈📈  │  │
│  ╰────────────────────────╯  │
│                              │
│  ┌──────────────────────┐    │
│  │ 1D  1W  1M [3M] 6M 1Y 2Y│  │  ← Range chips IN container
│  └──────────────────────┘    │
│                              │
│  ┌──────────┐  ┌──────────┐  │
│  │ 🇪🇵 EUR  │  │ 🇺🇸 USD  │  │  ← Large pill buttons with flags
│  └──────────┘  └──────────┘  │
│                              │
│  Try the chart with these    │  ← Upgrade prompt (subtle)
│  default currencies.         │
│  Upgrade to Currency+ to...  │
│                              │
│  [ad banner]                 │
│                              │
│    ┌──────────────┐           │
│    │  🔄  📈  ⚙️  │           │
│    └──────────────┘           │
└──────────────────────────────┘
```

### Specific Changes

**Remove AppBar entirely:**
- No more "Charts" title bar
- Chart content starts near top of screen

**Chart header area (new widget):**
- Line 1: `"USD per 1 EUR"` — 32px, w800, `AppTheme.text`
- Line 2: `"US$ 1.1793  ↓ 0.80%"` — 18px w500, rate in text color, change% in trend color
- Swap button: top-right, circular (40px), white bg, subtle shadow, swap-arrows icon

**Chart area (`rate_chart.dart`) — major overhaul:**
- **Remove card wrapper** — chart fills full width
- **Dynamic line color**: red (`#FF3B30`) when trend down, green (`#34C759`) when up
- **Gradient fill**: matches line color, fades from 25% opacity at top to 0% at bottom
- **Remove grid lines** (competitor has none) or make them extremely subtle (5% opacity)
- **Remove left/right axis titles** (already hidden, confirm)
- **Keep bottom date labels** but make them lighter (10px, `AppTheme.subtle`)

**Crosshair interaction redesign:**
- On touch: vertical line through touched point (competitor style)
- Date badge: floating white **pill above crosshair** (`"24 MAR"` in trend-colored text, bold)
- Dot on line: solid circle (8px, white stroke 2px, trend fill)
- Remove `_TooltipCard` above chart — replace with inline crosshair
- Crosshair line color: trend color at 30% opacity, 1px stroke

**Range selector (`range_selector.dart`):**
- Wrap all chips in a **rounded gray container** (bg `#F2F2F7`, radius 12, padding horizontal 8)
- Selected chip: white bg, slight shadow, text in `AppTheme.text`
- Unselected chip: transparent bg, text in `AppTheme.muted`
- All chips visible without scroll if possible (use smaller font if needed)

**Pair selector (`pair_selector.dart`):**
- Two large **rounded-pill buttons** side by side (horizontal center)
- Each pill: ~140px wide, 48px tall, radius 24
- Content: flag circle (28px) + currency code (16px w700)
- White bg, 1px border (`AppTheme.border`), extremely subtle shadow
- Active/selected state: slightly elevated shadow + primary tint border
- Swap button between them: circular (40px), same style as chart header swap

**Summary stats (`chart_summary.dart`):**
- Keep three-column layout (High / Low / Change%)
- Style: lighter, less prominent than current
- Values: 15px w600, labels: 11px w500 muted
- Change% colored by trend (green/red)

---

## Phase 4 — Settings Cleanup + Logic Separation

**Goal:** Split the 808-line monster into proper files. Extract ALL logic into a controller. Views must be pure presentation.

### Problem Analysis

Current `settings_screen.dart`: **808 lines**, 14 private widget classes mixed together.

**Where logic leaks into views (violates architecture rules):**

| Lines | Widget | Embedded Logic (must extract) |
|-------|--------|-------------------------------|
| 96-137 | `_DefaultBaseTile` | Shows bottom sheet, handles async result, writes to preferences |
| 139-224 | `_BaseCurrencyPicker` | Search query state, filter algorithm on supported currencies |
| 307-366 | `_ClearCacheTile` | AlertDialog construction, confirmation flow, SnackBar after clear |
| 368-411 | `_VersionTile` | Dev mode toggle state, long-press gesture, SnackBar feedback |
| 560-642 | `_PremiumSection` | Navigator.push to purchase player, restore purchases SnackBar |

**What's already correctly separated (no changes needed):**
- `AppPreferences` (61 lines) — all persistence logic ✅
- `MonetizationController` — all entitlement state ✅
- `PurchaseService` — IAP business logic ✅
- `IapPurchasePlayer` (already in `widgets/`) — purchase UI flow ✅

### Architecture: New File Structure

```
settings/
├── settings_screen.dart          ← ORCHESTRATOR ONLY (~60 lines)
├── settings_controller.dart      ← NEW: all interaction/logic decisions
└── widgets/
    ├── iap_purchase_player.dart  ← (exists, unchanged)
    ├── section_header.dart       ← extracted from _SectionHeader
    ├── settings_tile.dart        ← extracted from _SettingsTile → promoted to shared/widgets/
    ├── base_currency_tile.dart   ← extracted from _DefaultBaseTile
    ├── base_currency_picker.dart ← extracted from _BaseCurrencyPicker
    ├── decimal_places_tile.dart  ← extracted from _DecimalPlacesTile
    ├── switch_tile.dart          ← NEW: unified widget for Refresh/Dark mode tiles
    ├── clear_cache_tile.dart     ← extracted from _ClearCacheTile
    ├── version_tile.dart         ← extracted from _VersionTile
    ├── premium_section.dart      ← extracted from _PremiumSection + _PremiumCard + _SubscriptionCard
    ├── dev_sandbox_section.dart  ← extracted from _DevSandboxSection + _EntitlementSwitch
```

### NEW: `settings_controller.dart` (~90 lines)

Owns ALL interaction logic. Views call controller methods; never do navigation or side-effects directly.

```dart
class SettingsController extends ChangeNotifier {
  final AppPreferences preferences;
  final MonetizationController monetization;
  final VoidCallback onClearCache;

  // --- Base currency ---
  Future<void> pickBaseCurrency(BuildContext context);

  // --- Decimal places ---
  void setDecimalPlaces(int value);

  // --- Toggles (pass-through) ---
  void toggleRefreshOnOpen(bool value);
  void toggleDarkMode(bool value);

  // --- Clear cache ---
  void requestClearCache(BuildContext context);

  // --- Dev mode ---
  void toggleDevMode(BuildContext context);

  // --- Premium / IAP ---
  void purchaseProduct(BuildContext context, ProductType product);
  void restorePurchases(BuildContext context);
}
```

**Key principle:** Views receive callbacks like `controller.pickBaseCurrency(context)` — they never call `Navigator.showModalBottomSheet()`, `preferences.setXxx()`, or show `SnackBar`s directly.

### Execution Steps Within Phase 4

| Step | Action | Output |
|------|--------|--------|
| 1 | Create `settings_controller.dart` | Logic layer with all interaction methods |
| 2 | Extract `_SectionHeader` → `widgets/section_header.dart` | Pure view, < 20 lines |
| 3 | Extract `_SettingsTile` → `shared/widgets/settings_tile.dart` | Public reusable widget |
| 4 | Create unified `SwitchTile` widget | Replaces both `_RefreshOnOpenTile` + `_DarkModeTile` |
| 5 | Extract `_BaseCurrencyPicker` → `widgets/base_currency_picker.dart` | Pure view, search state stays local |
| 6 | Extract `_DefaultBaseTile` → `widgets/base_currency_tile.dart` | Calls controller.pickBaseCurrency |
| 7 | Extract `_DecimalPlacesTile` → `widgets/decimal_places_tile.dart` | Pure view |
| 8 | Extract `_ClearCacheTile` → `widgets/clear_cache_tile.dart` | Calls controller.requestClearCache |
| 9 | Extract `_VersionTile` → `widgets/version_tile.dart` | Calls controller.toggleDevMode |
| 10 | Extract `_DevSandboxSection` + `_EntitlementSwitch` → `widgets/dev_sandbox_section.dart` | Pure view |
| 11 | Extract `_PremiumSection` + `_PremiumCard` + `_SubscriptionCard` → `widgets/premium_section.dart` | Calls controller.purchaseProduct / restorePurchases |
| 12 | Rewrite `settings_screen.dart` as thin orchestrator | ~60 lines, instantiates sections passing controller |
| 13 | Run `flutter analyze` + tests | Must pass cleanly |

Each step is independently testable and commit-able.

### Rules for Extracted Widgets

1. **Pure view** — zero business logic, zero navigation calls
2. **Data in via constructor params** — never import `AppPreferences` or `MonetizationController` directly (except section-level widgets that receive the controller)
3. **Actions out via callbacks** — `VoidCallback`, `ValueChanged<T>`, or controller method refs
4. **Under 60 lines each** — enforced split trigger
5. **No `_` prefix** — extracted files are public within the feature module

---

## Phase 5 — Icons & Visual Details (MiniMax Generation)

**Goal:** Regenerate low-quality icons, generate new ones needed by redesigned UI.

### 5a. Regenerate Blurry Icons (when quota resets)

| Icon | Issue | Action |
|------|-------|--------|
| CLP (Chilean Peso) | Missing/broken | Regenerate with "flat 2D vector NO blur" prompt |
| BRL (Brazilian Real) | Slightly blurry | Try alternative prompt approach or regenerate |
| Others | Review after theme change | Some may look different on pure-white bg |

### 5b. New Icons Needed

| Icon | Purpose | Spec |
|------|---------|------|
| **Nav: Convert** | Floating pill nav | Swap arrows in circle, 24px, monochrome or primary-colored |
| **Nav: Chart** | Floating pill nav | Line graph trending up, 24px |
| **Nav: Settings** | Floating pill nav | Gear icon, 24px |
| **Swap button** | Chart header + pair selector | Circular swap arrows, white bg variant |
| **Empty states** | No data / offline illustrations (optional) | Simple line-art style |
| **App icon refresh** | Brand identity update (optional) | If brand direction changes |

Approach options:
- Use **Material Symbols Rounded** (built-in Flutter font) for nav icons — free, consistent, no generation needed
- Generate custom icons via MiniMax (`mmx image generate`) if we want unique brand identity
- Recommendation: Start with Material Symbols, upgrade to custom later if needed

### 5c. Future-Proof: Crypto Coin Icons (Phase 2 prep)

Generate now while we have the pipeline ready:
- BTC (Bitcoin) — orange circle, ₿ symbol
- ETH (Ethereum) — blue/purple diamond, Ξ symbol
- LTC (Litecoin) — silver circle, Ł symbol
- XRP (Ripple) — blue circle, X symbol
- Style: circular, flat design, matching existing currency flag icon spec (48x48 PNG)

---

## Phase 6 — Polish Cycle (Iterative Refinement)

**Goal:** After Phases 1-5 are implemented, do iterative comparison and fine-tuning.

### 6.1 Screenshot Comparison

1. Capture our app on simulator (all 3 tabs)
2. Place side-by-side with competitor screenshots
3. Identify remaining visual gaps
4. Prioritize by impact (biggest visual difference first)

### 6.2 Fine-Tuning Areas

| Area | Check | Adjust |
|------|-------|--------|
| Spacing | Consistent 4/8/12/16/24/32px scale? | Pad/margin adjustments |
| Colors | All colors from theme tokens? | No hardcoded colors |
| Font weights | Hierarchy clear at a glance? | Adjust sizes/weights |
| Corner radii | Consistent within context? | Unify radii per element type |
| Animations | 150-300ms transitions? | Duration/easing curves |
| Touch targets | Minimum 44x44px? | Size up small tappable areas |
| Dark mode | All changes work in dark theme? | Test both themes |
| Small screen | Works on iPhone SE (375pt)? | Layout adaptations |

### 6.3 Verification

After every phase (and definitely after Phase 6):

```bash
./scripts/check.sh          # flutter analyze + test
# If UI work: hot restart simulator and visually verify
```

---

## Execution Order Summary

```
Phase 1  Foundation (Theme + Floating Nav)     ← BIGGEST SINGLE IMPACT
Phase 2  Convert Screen Redesign               ← Most user-visible change
Phase 3  Chart Screen Redesign                 ← Second-most user-visible
Phase 4  Settings Cleanup + Logic Separation   ← Code quality + architecture
Phase 5  Icons & Visual Details                ← Polish + new assets
Phase 6  Polish Cycle (Iterative)              ← Final refinement
```

Each phase is independently commit-able, testable, and deployable.

### Estimated Scope

| Phase | Files changed | Files new | Lines changed | Complexity |
|-------|--------------|-----------|---------------|------------|
| Phase 1 | 2 | 1 | ~150 | Medium |
| Phase 2 | 8 | 3 | ~800 | High |
| Phase 3 | 5 | 2 | ~600 | High |
| Phase 4 | 2 | 14 | ~900 (net -400 after extraction) | Medium |
| Phase 5 | 2 | 5-10 | ~50 (assets) | Low |
| Phase 6 | varies | 0 | ~200 | Low |
| **Total** | **~19** | **~25** | **~2700** | |

---

## Non-Goals (Explicitly Out of Scope)

These are NOT part of this UI redesign cycle:

- ~~Backend integration~~ — Phase 2 feature
- ~~Real IAP (Store Kit / Play Billing)~~ — stubs stay
- ~~Real AdMob ads~~ — placeholders stay
- ~~Crypto/metal data~~ — Phase 3 feature
- ~~New features or functionality~~ — visual polish only
- ~~Brand identity overhaul~~ — unless explicitly requested
- ~~Animation framework~~ — use built-in AnimatedWidget only

---

## References

- Competitor screenshots: `/Users/luis/Downloads/CurrencyApp/` (7 PNGs)
- Current theme: `lib/src/core/theme/app_theme.dart`
- Current convert: `lib/src/features/convert/` (13 files)
- Current charts: `lib/src/features/charts/` (8 files)
- Current settings: `lib/src/features/settings/settings_screen.dart` (808 lines!)
- Current app shell: `lib/src/app.dart` (191 lines)
- Icon generation skill: `.agent/skills/icon-generation/SKILL.md`
- MiniMax CLI skill: `../skills/mobile/minimax-cli.SKILL.md`
- AGENTS.md modularity rules (file size budgets, split triggers)
