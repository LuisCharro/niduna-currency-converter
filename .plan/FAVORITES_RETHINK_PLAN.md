# Favorites / Pinned Pairs Rethink Plan

> Status: planning only  
> Scope: rethink `Favorites` from product value first, then define an
> implementation path against the current Flutter codebase. No functional code
> changes are implied by this file.

## Decision Summary

Do not simply restyle the current hidden `Favorites` tab.

The existing tab is early dev work and should not be re-enabled as-is. The
better product concept is **Pinned Pairs**: a small, local, fast-access surface
for the exchange pairs a user checks repeatedly.

Recommended MVP path:

1. keep the standalone `Favorites` tab hidden for launch
2. use the existing favorite/pin storage to improve the `Convert` experience
3. defer a full fourth-tab redesign until after MVP feedback

Reason:

- a fourth tab increases navigation and QA surface
- current `FavoritesScreen` is not visually aligned, not fully localized, and
  not release quality
- pinned pairs can deliver real value inside `Convert`, where users already do
  the work
- no new provider, backend, account, or API complexity is required

## Design Inputs Used

I used the repo's design and UI skills as constraints, not as decoration:

- `DESIGN.md`: keep the Niduna warm paper surface, Manrope/Fraunces hierarchy,
  thin dividers, compact rows, and forest-green interaction language.
- `.agent-local/skills/mobile/mobile-ui-review.SKILL.md`: make the first visible
  area support the primary user job; keep touch targets near `48 x 48`; avoid
  long explanatory copy before useful controls.
- `.agent/skills/small-screen-ui-review/SKILL.md`: design for the small Android
  emulator first; treat tall summary blocks and `Wrap` layouts as suspicious.
- `.agent-local/skills/frontend/design-system-consistency.SKILL.md`: use shared
  tokens/primitives instead of one-off card and color patches.
- `.agent-local/skills/frontend/frontend-design-direction.SKILL.md`: define the
  product job and structural fingerprint before choosing component details.
- `.agent-local/skills/frontend/visual-distinctiveness-review.SKILL.md`: avoid
  generic dashboard/card-grid patterns; make the surface specific to this app.

Design translation:

- this is a compact personal shortcut rail, not a portfolio/watchlist product
- it should feel like part of Convert, not a fourth product area
- the visual identity should come from data hierarchy, dividers, and typography,
  not from decorative cards
- the web/frontend skills were used only for design reasoning: hierarchy,
  spacing, component consistency, and avoiding generic dashboard patterns. The
  implementation should still be native Flutter and match this app's existing
  mobile system.

## Product Definition

### User Job

"I check the same few exchange pairs repeatedly. Let me pin them, see the
latest saved rate quickly, and jump back into conversion with one tap."

### MVP Scope

Pinned pairs are:

- local only
- capped at 3 pairs
- persisted in `SharedPreferences`
- available offline using cached/latest known rates when possible
- added/removed from Convert row actions
- used as a quick route back into Convert context

Pinned pairs are not:

- a portfolio
- an alerts system
- a cloud-sync feature
- unlimited bookmarks
- a new data provider surface
- a chart comparison feature

## Current Code Reality

Existing pieces:

- `lib/src/features/favorites/data/favorites_store.dart`
  - already stores up to 3 local pairs
  - already persists in `SharedPreferences`
  - already exposes `pairs`, `isFull`, `isFavorite`, `toggle`, and `remove`

- `lib/src/features/favorites/domain/favorite_pair.dart`
  - already models `base` + `quote`
  - already serializes to `base-quote`

- `lib/src/features/convert/presentation/convert_controller.dart`
  - already receives `FavoritesStore`
  - already marks `CurrencyQuote.favorite`
  - already exposes `toggleFavorite`
  - currently only exposes favorites for the active base in `state.quotes`

- `lib/src/features/convert/widgets/currency_rate_row.dart`
  - already displays favorite state in each row

- `lib/src/features/favorites/favorites_screen.dart`
  - still exists but is hidden from current navigation
  - has hardcoded English strings
  - has older UI patterns
  - should be treated as legacy/reference, not a shippable tab

- `lib/src/app.dart`
  - current visible app shell has 3 tabs: `Convert`, `Charts`, `Settings`
  - `FavoritesStore` is still created and wired into `ConvertController`

## MVP UX Direction: Pinned Pairs Inside Convert

### Placement

Add a compact `PinnedPairsPanel` inside `Convert`.

Recommended placement:

- below `AmountPanel`
- above `RatesSectionHeader`
- visible only when at least one pair is pinned

Why:

- this keeps the main conversion task central
- users see their pinned pairs without navigating away
- no fourth tab is needed before launch
- empty-state marketing copy is avoided

### Behavior

When there are no pinned pairs:

- show nothing in the main Convert screen
- users discover pinning through existing row favorite/star affordance

When there are 1-3 pinned pairs:

- show a horizontally scrollable or wrapped compact strip
- each item shows:
  - `USD -> EUR`
  - latest rate if computable from current snapshot
  - stale/cached indicator only if the existing snapshot status says data is not fresh
- tapping a pinned pair sets Convert to that base/quote context
- long-pressing or trailing icon removes the pair

When the max is reached:

- Convert row favorite affordance should still allow unfavorite
- trying to pin a fourth pair should show a localized snackbar:
  - English: `You can pin up to 3 pairs in this version.`

### Visual Design

Use the current Niduna system:

- warm paper background from `CanvasBackground`
- no large cards
- thin divider language where a section boundary is needed
- compact chips or rows, not a heavy dashboard
- Manrope for all pair/rate data
- no Fraunces inside compact pinned items
- use `AppColors.of(context)` for all colors
- use `AppTheme.supportingTextStyle(context)` and `AppTheme.sectionLabelStyle(context)`
- honor dark mode automatically through theme extensions

### Visual Fingerprint

The pinned-pairs surface should look like an **instrument rail**, not a card.
It should borrow the useful parts of Convert rows and Chart metric rails:

- pair identity on the left
- one strong current-rate value on the right
- a tiny secondary freshness/status line only when needed
- thin dividers instead of boxed cards
- icon-only destructive action

It should not look like:

- a portfolio
- a stock watchlist
- a generic dashboard
- a promotional card
- a second navigation system

### First Version Layout

Use a compact vertical row block first.

This is what the user should see in `Convert` when pairs exist:

```text
[Updated + action buttons]

Amount
100.00                                      [USD]
------------------------------------------------

PINNED PAIRS
USD -> EUR                         0.8519   [x]
CHF -> JPY                         178.23   [x]
BTC -> CHF                     101,234.00   [x]

3 shown currencies                 Add currencies

Euro                               EUR 85.11
British Pound                      GBP 73.70
Japanese Yen                       JPY 15,746.00
```

The pinned section should read as a useful shortcut shelf between amount entry
and the regular rates list. It should not look like a separate page inserted
inside the tab.

Recommended layout:

```text
PINNED PAIRS
USD -> EUR                         0.8519   [x]
CHF -> JPY                       178.23     [x]
BTC -> CHF                    101,234.00    [x]
```

Expanded row anatomy:

```text
USD -> EUR                         0.8519   [x]
Cached daily rate
```

Rules:

- the pair/value line is the priority
- freshness/status is optional and should disappear before the main line wraps
- row value uses tabular figures
- pair labels stay as codes, not currency names
- the whole row opens the pair in Convert
- the trailing icon removes the pair

Interaction:

- tap row: open that pair in Convert without changing the current amount
- press row: use the same subtle press scale language as existing Convert rows,
  but keep it restrained
- tap remove icon: remove immediately; if undo support already exists nearby,
  use it, otherwise keep removal simple for MVP
- do not add a secondary "Open" text button; the whole row is the target

### Surface Rules

Container:

- no filled large card by default
- optional top and bottom hairline divider only
- horizontal padding: `AppTheme.pagePadding`
- vertical padding: `AppTheme.space2` to `AppTheme.space3`
- if a background is needed, use `colors.container.withValues(alpha: .30)` and
  no shadow

Title:

- localized `Pinned pairs`
- `AppTheme.sectionLabelStyle(context)`
- uppercase/micro rhythm matching `AMOUNT` and `RATES`
- no Fraunces

Rows:

- minimum interactive height: `48`
- pair label: Manrope, `13-14`, `w800`, `colors.text`
- rate value: Manrope, `16-18`, `w800`, tabular figures, `colors.text`
- supporting text: `AppTheme.supportingTextStyle(context)`, one line
- divider: `colors.border.withValues(alpha: .12)`
- remove action: `IconButton`, `Icons.close_rounded` or
  `Icons.remove_circle_outline_rounded`, `colors.subtle`

Motion:

- use existing `PressScale` only if it does not make rows feel bouncy
- no staggered animation on every screen load
- row removal can use a short fade/size transition if simple

### State Designs

No pinned pairs:

- show nothing by default
- if discovery proves weak, add one compact hint near `RatesSectionHeader`, not
  a large empty card:
  - `Star rows to pin up to 3 pairs`

One pinned pair:

- show title + one row
- keep it visually quiet so it does not compete with the amount panel

Three pinned pairs:

- show title + three compact rows
- if this pushes too many rate rows below the fold, collapse supporting labels
  first

Fresh data:

- omit secondary status or reuse the current Convert freshness label
- avoid a second competing freshness system

Cached/stale data:

- show one short localized label such as `Cached`
- do not show warning paragraphs inside the panel

Unavailable rate:

- show `--`
- keep the row tappable

Dark mode:

- use only `AppColors.of(context)`
- no raw light colors
- dividers stay visible but low contrast

Spanish/long labels:

- pair codes and rate values keep priority
- supporting text can ellipsize
- no two-line icon labels

Recommendation for implementation:

- start with a compact vertical row block
- if it feels too heavy, convert it to a horizontal strip after screenshots

### Small-Screen Acceptance

On a compact phone, Convert should still show:

- amount panel
- pinned pairs if they exist
- `RATES` header
- at least two rate rows without immediate scroll

If three pinned pairs break this:

1. remove supporting text from pinned rows
2. reduce vertical padding
3. collapse to a one-line horizontal strip
4. only then reconsider placement

## Data Behavior

Pinned pair rates can be computed from the current `LatestRatesSnapshot`:

- if snapshot base equals pair base: `rate = rates[pair.quote]`
- if snapshot base equals pair quote: `rate = 1 / rates[pair.base]`
- otherwise: `rate = rates[pair.quote] / rates[pair.base]`

This logic already exists in `FavoritesScreen._FavoritesList._rateFor`.

Move it out of the hidden screen and into a small reusable helper:

- new file:
  - `lib/src/features/favorites/domain/favorite_pair_rate.dart`

Suggested API:

```dart
double? rateForFavoritePair({
  required FavoritePair pair,
  required LatestRatesSnapshot? snapshot,
})
```

This avoids duplicating rate math in Convert and the future tab redesign.

## Required Localization

Add keys to all ARB files in `lib/l10n/` and generated Dart localization files:

- `pinnedPairsTitle`
  - EN: `Pinned pairs`
  - ES: `Pares fijados`
  - DE: `Angeheftete Paare`
  - FR: `Paires épinglées`
  - IT: `Coppie fissate`

- `pinnedPairsLimitMessage`
  - EN: `You can pin up to 3 pairs in this version.`
  - ES: `Puedes fijar hasta 3 pares en esta versión.`
  - DE: `Du kannst in dieser Version bis zu 3 Paare anheften.`
  - FR: `Vous pouvez épingler jusqu'à 3 paires dans cette version.`
  - IT: `Puoi fissare fino a 3 coppie in questa versione.`

- `removePinnedPairTooltip`
  - EN: `Remove pinned pair`
  - ES: `Quitar par fijado`
  - DE: `Angeheftetes Paar entfernen`
  - FR: `Retirer la paire épinglée`
  - IT: `Rimuovi coppia fissata`

- `openPinnedPairTooltip`
  - EN: `Open pair in Convert`
  - ES: `Abrir par en Convertir`
  - DE: `Paar in Umrechnen öffnen`
  - FR: `Ouvrir la paire dans Convertir`
  - IT: `Apri coppia in Converti`

- `pinnedPairsDiscoveryHint`
  - EN: `Star rows to pin up to 3 pairs`
  - ES: `Marca filas para fijar hasta 3 pares`
  - DE: `Markiere Zeilen, um bis zu 3 Paare anzuheften`
  - FR: `Marquez des lignes pour épingler jusqu'à 3 paires`
  - IT: `Contrassegna le righe per fissare fino a 3 coppie`

- `pinnedPairCachedLabel`
  - EN: `Cached`
  - ES: `En caché`
  - DE: `Zwischengespeichert`
  - FR: `En cache`
  - IT: `In cache`

Do not keep hardcoded strings in user-facing UI.

## Implementation Plan: MVP Pinned Pairs In Convert

Implementation constraints:

- do not re-enable `FavoritesScreen` in the main nav for MVP
- do not modify `FloatingPillNav` tab count
- do not add a fourth visible tab
- do not add new data providers
- do not add charts, alerts, portfolio metrics, or backend behavior

### Task 1: Add Rate Helper

Create:

- `lib/src/features/favorites/domain/favorite_pair_rate.dart`

Add:

```dart
import '../../convert/domain/latest_rates_snapshot.dart';
import 'favorite_pair.dart';

double? rateForFavoritePair({
  required FavoritePair pair,
  required LatestRatesSnapshot? snapshot,
}) {
  final rates = snapshot?.rates;
  final snapBase = snapshot?.base;
  if (rates == null || snapBase == null) return null;

  if (snapBase == pair.base) return rates[pair.quote];

  if (snapBase == pair.quote) {
    final baseRate = rates[pair.base];
    if (baseRate == null || baseRate == 0) return null;
    return 1.0 / baseRate;
  }

  final baseRate = rates[pair.base];
  final quoteRate = rates[pair.quote];
  if (baseRate == null || quoteRate == null || baseRate == 0) return null;
  return quoteRate / baseRate;
}
```

Add tests in:

- `test/favorites_test.dart`

Test cases:

- direct pair from snapshot base
- inverse pair from snapshot base
- cross pair from third snapshot base
- missing rate returns null
- zero denominator returns null

### Task 2: Expose Pinned Pairs From ConvertController

Modify:

- `lib/src/features/convert/presentation/convert_controller.dart`

Add getter:

```dart
List<FavoritePair> get favoritePairs =>
    _favoritesStore?.pairs ?? const <FavoritePair>[];
```

Import required type:

```dart
import '../../favorites/domain/favorite_pair.dart';
```

Add method:

```dart
Future<void> removeFavoritePair(FavoritePair pair) async {
  await _favoritesStore?.remove(pair.base, pair.quote);
}
```

Add method:

```dart
Future<void> openFavoritePair(FavoritePair pair) async {
  if (pair.base != _base) {
    await setBase(pair.base);
  }
  if (!_selectedCodes.contains(pair.quote)) {
    _selectedCodes = <String>[pair.quote, ..._selectedCodes]
        .where((code) => code != pair.base)
        .toList();
    _preferences?.setSelectedCodes(_selectedCodes);
    state = _snapshot == null
        ? state.copyWith(selectedCodes: _selectedCodes)
        : _stateFromSnapshot(_snapshot!, state.status);
    _safeNotify();
  }
}
```

Important:

- `setBase` is async in
  `lib/src/features/convert/presentation/convert_controller_editing.dart`
- do not call `setBase(pair.base)` without `await`
- do not call `_safeNotify()` again after `setBase` unless selected codes were
  actually changed after the awaited call
- avoid `.toSet().toList()` because it can reorder user-selected currency codes

### Task 2b: Make Favorite Toggle Result Observable

Current `FavoritesStore.add` silently returns when full. To show a max-limit
snackbar, the UI needs a result.

Preferred minimal change:

- keep existing methods for compatibility
- add a new controller-level method:

```dart
Future<bool> tryToggleFavorite(String quote) async {
  final store = _favoritesStore;
  if (store == null) return true;
  if (!store.canAdd(_base, quote)) return false;
  await store.toggle(_base, quote);
  return true;
}
```

Then `ConvertScreen` / `ConvertContent` can show `pinnedPairsLimitMessage` only
when `false` is returned.

If changing `onToggleFavorite` from `ValueChanged<String>` to an async result is
too broad, defer the snackbar and keep silent max-limit behavior for the first
implementation. Do not fake success copy.

### Task 3: Add PinnedPairsPanel Widget

Create:

- `lib/src/features/convert/widgets/pinned_pairs_panel.dart`

Responsibilities:

- receives `List<FavoritePair>`
- receives `LatestRatesSnapshot?`
- receives `ConvertStatus status` or a preformatted short status label
- receives callbacks:
  - `onOpen(FavoritePair pair)`
  - `onRemove(FavoritePair pair)`
- returns `SizedBox.shrink()` when empty
- displays max 3 rows
- uses `rateForFavoritePair`
- uses localized title/tooltips
- uses only `AppColors.of(context)` and `AppTheme` dynamic styles

Suggested structure:

```dart
class PinnedPairsPanel extends StatelessWidget {
  const PinnedPairsPanel({
    required this.pairs,
    required this.snapshot,
    required this.status,
    required this.onOpen,
    required this.onRemove,
    super.key,
  });
}
```

Recommended status input:

```dart
final ConvertStatus status;
```

Use it only for short labels:

- `ConvertStatus.fresh` -> omit secondary label or show existing updated text
- `ConvertStatus.cached` -> localized `Cached`
- `ConvertStatus.stale` -> localized `Cached`
- `ConvertStatus.loading` / `noCache` -> no status label

If localization for `Cached` is not already available, add a key or reuse an
existing one. Do not hardcode English.

Visual rules:

- no card inside card
- no large bordered container
- optional top/bottom divider using `colors.border.withValues(alpha: .12)`
- row min height around `48`
- remove action is icon-only with tooltip
- open action is the whole row tap
- use tabular figures for the rate value
- helper computes raw rate only; formatting belongs in this widget
- format fiat and crypto rates consistently with existing Convert/Charts rules

### Task 4: Insert PinnedPairsPanel Into ConvertContent

Modify:

- `lib/src/features/convert/widgets/convert_content.dart`

Add new required parameters:

```dart
required List<FavoritePair> favoritePairs,
required LatestRatesSnapshot? snapshot,
required ConvertStatus status,
required ValueChanged<FavoritePair> onOpenFavoritePair,
required ValueChanged<FavoritePair> onRemoveFavoritePair,
```

Import:

```dart
import '../../favorites/domain/favorite_pair.dart';
import 'pinned_pairs_panel.dart';
```

Place `PinnedPairsPanel` between `AmountPanel` and `RatesSectionHeader`:

```dart
PinnedPairsPanel(
  pairs: widget.favoritePairs,
  snapshot: widget.snapshot,
  status: widget.state.status,
  onOpen: widget.onOpenFavoritePair,
  onRemove: widget.onRemoveFavoritePair,
),
```

If screenshots show it makes Convert too tall, move it below `RatesSectionHeader`
or make it a one-line horizontal strip.

### Task 5: Wire ConvertScreen

Modify:

- `lib/src/features/convert/convert_screen.dart`

Pass through:

```dart
favoritePairs: controller.favoritePairs,
snapshot: controller.snapshot,
status: controller.state.status,
onOpenFavoritePair: controller.openFavoritePair,
onRemoveFavoritePair: controller.removeFavoritePair,
```

If callback types require async wrapping:

```dart
onOpenFavoritePair: (pair) => controller.openFavoritePair(pair),
onRemoveFavoritePair: (pair) => controller.removeFavoritePair(pair),
```

### Task 6: Localize Strings

Modify:

- `lib/l10n/app_en.arb`
- `lib/l10n/app_es.arb`
- `lib/l10n/app_de.arb`
- `lib/l10n/app_fr.arb`
- `lib/l10n/app_it.arb`

Then run:

```bash
flutter gen-l10n
```

If the generated `app_localizations_*.dart` files do not update, manually
verify whether this repo commits generated files and update them consistently.
This has happened before in this repo.

### Task 7: Update Tests

Modify:

- `test/widget_test.dart`
- `test/favorites_test.dart`

Widget tests:

1. Convert with no favorites does not show `Pinned pairs`.
2. Convert with one favorite shows `Pinned pairs`.
3. Convert with one favorite shows `USD -> EUR` or localized equivalent if the
   test uses app localizations.
4. Tapping a pinned pair calls the controller path and shows that quote in the
   visible list.
5. Removing a pinned pair hides it.

Avoid asserting fragile exact rates unless the fake repository data makes the
math obvious.

Domain tests:

1. `rateForFavoritePair` direct
2. `rateForFavoritePair` inverse
3. `rateForFavoritePair` cross
4. missing rate
5. zero denominator

### Task 8: Screenshot Review

Capture on iOS:

```bash
IOS_SIMULATOR_ID=AD6518C3-252E-4951-AE25-AF6732817FB1 \
SCREEN_OUTPUT_DIR=.tmp/screens/pinned-pairs-ios \
CAPTURE_TARGET_PATH=integration_test/<capture_test>.dart \
./.devtools/capture_ios_screens.sh
```

If no capture test exists for this state, create a temporary one or manually
rebuild and inspect on simulator.

Manual checks:

- no pinned pairs
- one pinned pair
- three pinned pairs
- dark mode
- Spanish locale if feasible
- small iPhone height if feasible

### Task 9: Verification

Run:

```bash
flutter test test/favorites_test.dart test/widget_test.dart
./scripts/check.sh
```

Then rebuild for manual testing:

```bash
IOS_SIMULATOR_ID=AD6518C3-252E-4951-AE25-AF6732817FB1 \
BUNDLE_ID=com.niduna.currencyConverter \
./.devtools/sim_reinstall_build.sh
```

```bash
ANDROID_SERIAL=emulator-5556 \
ANDROID_PACKAGE_NAME=com.niduna.currency_converter \
./.devtools/android_reinstall_build.sh
```

## Post-MVP Full Favorites Tab Redesign

Only do this after MVP or if the decision changes and Favorites becomes a
release blocker.

### Product Shape

The standalone tab should be a **personal rate board**, not a generic list.

Must include:

- title: `Favorites`
- small status: local-only / cached freshness
- max 3 pairs
- latest rate
- delete action
- tap to open Convert
- empty state with direct instruction
- no marketing copy

Must not include:

- charts inside rows
- provider diagnostics
- account/cloud language
- unlimited favorites
- upgrade prompts unless a future paid max-favorites unlock is approved

### UI Shape

Recommended layout:

```text
Favorites
Local pairs saved on this device

USD -> EUR                         0.8519
Last daily update                 Open >

CHF -> JPY                       178.23
Cached                           Open >

[+ Add from Convert]
```

Style rules:

- use `CanvasBackground`
- use `BottomTabFrame`
- use `ScreenTitle`
- no large card wrapper around the whole page
- rows separated by hairline dividers
- icon-only delete action with tooltip
- no hardcoded English
- all colors via `AppColors.of(context)`

### Navigation Cost

Re-enabling the standalone tab requires:

- add `FavoritesScreen` back into `AppShell.screens`
- expand `FloatingPillNav` from 3 to 4 items
- adjust selected-pill width math
- update tests expecting 3 nav items
- update screenshots, store assets, and docs
- retest iOS/Android small screens

This is why it is not recommended before MVP unless Favorites becomes a core
launch differentiator.

## Documentation Updates If Implemented

If MVP path is implemented:

- update `ROADMAP.md` to say Favorites tab remains hidden but pinned pairs are
  surfaced inside Convert
- update `PLAN.md` Slice 3 notes
- update `DEFINITIONS.md` if this changes the phase contract wording

If full tab is re-enabled:

- update `ROADMAP.md` current reality from 3 visible tabs to 4 visible tabs
- update app store screenshots checklist
- update nav-related tests

## Acceptance Criteria

MVP pinned pairs is complete when:

- adding/removing favorites from Convert still works
- Convert shows a polished pinned-pair surface only when pairs exist
- tapping a pinned pair moves the user into a useful Convert context
- no user-facing hardcoded English exists in the new surface
- dark mode looks consistent
- Spanish strings fit
- tests pass
- iOS and Android manual builds run

Full tab redesign is complete when:

- Favorites can be enabled in nav without looking visually older than Convert,
  Charts, or Settings
- empty, one-pair, three-pair, and dark-mode states are verified
- all copy is localized
- no Phase/dev language is visible to users
- the fourth-tab nav remains comfortable on small phones
