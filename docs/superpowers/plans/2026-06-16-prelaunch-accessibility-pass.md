# Pre-launch Accessibility Pass — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Give every interactive control a localized semantic label/role, make layouts survive large text, verify contrast in both themes, and confirm the existing error/empty/offline states render — without new features.

**Architecture:** Follow the established house pattern — wrap interactive `InkWell`/`IconButton`/`GestureDetector` in `Semantics(button: true, label: ...)`, label sourced from localized strings via the `l10n(context)` safe helper. Decorative flag icons are excluded from the AT tree. New strings are added to all 5 ARB files and regenerated with `flutter gen-l10n`. Dynamic Type and contrast are audited on the emulators with targeted fixes.

**Tech Stack:** Flutter, `flutter_localizations` + ARB (`generate: true`), `Semantics`, `MediaQuery.textScalerOf`, existing `AppColors` tokens.

**Spec:** `docs/superpowers/specs/2026-06-16-prelaunch-accessibility-pass-design.md`

**Branch:** `feat/accessibility-pass` (already created off `main`).

**Conventions for every task:**
- Localized strings come from `l10n(context)` (`import '../../../../l10n/app_localizations_safe.dart'` — adjust `../` depth per file). Reuse existing keys where noted; only add new keys in Task 1.
- Never modify `AppColors.dark`. Contrast fixes use existing tokens / opacity.
- Respect `AGENTS.md` file-size caps; if adding `Semantics` pushes a file over, extract a small sub-widget in the same file/folder.
- Run `./scripts/check.sh` before each commit; expected: analyze clean + all tests pass.

---

## Task 1: Add localized semantic-label strings (all 5 ARBs)

**Files:**
- Modify: `lib/l10n/app_en.arb`, `app_de.arb`, `app_es.arb`, `app_it.arb`, `app_fr.arb`
- Generated (do not hand-edit): `lib/l10n/app_localizations*.dart`

- [ ] **Step 1: Add keys to `app_en.arb`** (template). Insert these entries (keep valid JSON — comma-separate, the two placeholder keys need `@` metadata blocks):

```json
"refreshRatesTooltip": "Refresh rates",
"shareRatesTooltip": "Share rates",
"openSettingsTooltip": "Settings",
"closeTooltip": "Close",
"removeCurrencyLabel": "Remove currency",
"toggleFavoriteLabel": "Add or remove favorite",
"setAsBaseLabel": "Set as base currency",
"swapCurrenciesTooltip": "Swap currencies",
"rateFreshnessInfoLabel": "Rate freshness info",
"changeChartPairLabel": "Change chart pair",
"changeBaseCurrencyLabel": "Change base currency, currently {code}",
"@changeBaseCurrencyLabel": { "placeholders": { "code": { "type": "String" } } },
"editAmountLabel": "Edit amount, currently {amount}",
"@editAmountLabel": { "placeholders": { "amount": { "type": "String" } } },
"openPairLabel": "Open {code} conversion",
"@openPairLabel": { "placeholders": { "code": { "type": "String" } } },
"chartRangeLabel": "{range} range",
"@chartRangeLabel": { "placeholders": { "range": { "type": "String" } } }
```

- [ ] **Step 2: Add the same keys to the other four ARBs** with translations.

`app_de.arb`:
```json
"refreshRatesTooltip": "Kurse aktualisieren",
"shareRatesTooltip": "Kurse teilen",
"openSettingsTooltip": "Einstellungen",
"closeTooltip": "Schließen",
"removeCurrencyLabel": "Währung entfernen",
"toggleFavoriteLabel": "Favorit hinzufügen oder entfernen",
"setAsBaseLabel": "Als Basiswährung festlegen",
"swapCurrenciesTooltip": "Währungen tauschen",
"rateFreshnessInfoLabel": "Info zur Kursaktualität",
"changeChartPairLabel": "Diagrammpaar ändern",
"changeBaseCurrencyLabel": "Basiswährung ändern, aktuell {code}",
"editAmountLabel": "Betrag bearbeiten, aktuell {amount}",
"openPairLabel": "{code}-Umrechnung öffnen",
"chartRangeLabel": "Zeitraum {range}"
```

`app_es.arb`:
```json
"refreshRatesTooltip": "Actualizar tasas",
"shareRatesTooltip": "Compartir tasas",
"openSettingsTooltip": "Ajustes",
"closeTooltip": "Cerrar",
"removeCurrencyLabel": "Quitar moneda",
"toggleFavoriteLabel": "Añadir o quitar favorito",
"setAsBaseLabel": "Establecer como moneda base",
"swapCurrenciesTooltip": "Intercambiar monedas",
"rateFreshnessInfoLabel": "Información de actualidad de tasas",
"changeChartPairLabel": "Cambiar par del gráfico",
"changeBaseCurrencyLabel": "Cambiar moneda base, actualmente {code}",
"editAmountLabel": "Editar importe, actualmente {amount}",
"openPairLabel": "Abrir conversión de {code}",
"chartRangeLabel": "Periodo {range}"
```

`app_it.arb`:
```json
"refreshRatesTooltip": "Aggiorna tassi",
"shareRatesTooltip": "Condividi tassi",
"openSettingsTooltip": "Impostazioni",
"closeTooltip": "Chiudi",
"removeCurrencyLabel": "Rimuovi valuta",
"toggleFavoriteLabel": "Aggiungi o rimuovi preferito",
"setAsBaseLabel": "Imposta come valuta base",
"swapCurrenciesTooltip": "Scambia valute",
"rateFreshnessInfoLabel": "Informazioni sull'aggiornamento dei tassi",
"changeChartPairLabel": "Cambia coppia del grafico",
"changeBaseCurrencyLabel": "Cambia valuta base, attualmente {code}",
"editAmountLabel": "Modifica importo, attualmente {amount}",
"openPairLabel": "Apri conversione {code}",
"chartRangeLabel": "Periodo {range}"
```

`app_fr.arb`:
```json
"refreshRatesTooltip": "Actualiser les taux",
"shareRatesTooltip": "Partager les taux",
"openSettingsTooltip": "Réglages",
"closeTooltip": "Fermer",
"removeCurrencyLabel": "Supprimer la devise",
"toggleFavoriteLabel": "Ajouter ou retirer des favoris",
"setAsBaseLabel": "Définir comme devise de base",
"swapCurrenciesTooltip": "Échanger les devises",
"rateFreshnessInfoLabel": "Infos sur la fraîcheur des taux",
"changeChartPairLabel": "Changer la paire du graphique",
"changeBaseCurrencyLabel": "Changer la devise de base, actuellement {code}",
"editAmountLabel": "Modifier le montant, actuellement {amount}",
"openPairLabel": "Ouvrir la conversion {code}",
"chartRangeLabel": "Période {range}"
```

- [ ] **Step 3: Regenerate + verify.**
Run: `flutter gen-l10n && flutter analyze lib/l10n`
Expected: generation succeeds; `grep -c "refreshRatesTooltip\|changeBaseCurrencyLabel\|openPairLabel" lib/l10n/app_localizations.dart` returns ≥ 3. No analyze errors.

- [ ] **Step 4: Commit.**
```bash
git add lib/l10n
git commit -m "i18n(a11y): add semantic-label strings for accessibility pass"
```

---

## Task 2: Shared widgets + bottom nav + decorative flags

**Files:**
- Modify: `lib/src/shared/widgets/floating_pill_nav_item.dart` (~line 34-47)
- Modify: `lib/src/shared/widgets/currency_picker_chrome.dart` (~line 43-45, close button)
- Modify: `lib/src/features/settings/widgets/base_currency_picker.dart` (~line 42-45, close button)
- Modify: `lib/src/shared/widgets/currency_flag_icon.dart` (exclude from a11y tree)
- Test: `test/a11y_shared_test.dart` (new)

- [ ] **Step 1: Write the failing test.** Create `test/a11y_shared_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/shared/widgets/currency_flag_icon.dart';

void main() {
  testWidgets('CurrencyFlagIcon is excluded from the semantics tree',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: CurrencyFlagIcon(code: 'EUR', symbol: '€', radius: 18),
      ),
    ));
    // The flag duplicates the currency code spoken elsewhere, so it must not
    // appear as its own semantics node.
    expect(find.bySemanticsLabel('EUR'), findsNothing);
    expect(find.bySemanticsLabel('€'), findsNothing);
    handle.dispose();
  });
}
```

- [ ] **Step 2: Run to verify it fails.**
Run: `flutter test test/a11y_shared_test.dart`
Expected: FAIL (the symbol/`€` text currently exposes semantics, or the test compiles and finds a node).

- [ ] **Step 3: Exclude the decorative flag.** In `currency_flag_icon.dart`, wrap the returned widget's root in `ExcludeSemantics(child: ...)`. Example (adapt to the actual build method):

```dart
@override
Widget build(BuildContext context) {
  return ExcludeSemantics(
    child: _buildFlag(context), // existing CircleAvatar / fallback content
  );
}
```
(If the build is inline rather than a helper, wrap the existing returned widget in `ExcludeSemantics(child: ...)`.)

- [ ] **Step 4: Run to verify it passes.**
Run: `flutter test test/a11y_shared_test.dart`
Expected: PASS.

- [ ] **Step 5: Label the bottom-nav items.** In `floating_pill_nav_item.dart`, wrap the item root (the `PressScale`/`SizedBox.expand` at ~line 34) in:

```dart
Semantics(
  button: true,
  selected: isSelected, // use the existing selected/active flag in this widget
  label: label,         // the existing tab label String already in scope
  child: ExcludeSemantics(child: /* existing icon + text column */),
)
```
Use the field name this widget actually has for selection/label (the inventory shows a `label` text and a selected state). `ExcludeSemantics` on the inner content prevents the icon/text from creating duplicate nodes under the labeled button.

- [ ] **Step 6: Label the two close buttons.** In `currency_picker_chrome.dart` (~line 43) and `base_currency_picker.dart` (~line 42), add `tooltip: l10n(context).closeTooltip` to the `IconButton(...)` and wrap it as `Semantics(button: true, label: l10n(context).closeTooltip, child: IconButton(...))`. Add the safe-l10n import if missing.

- [ ] **Step 7: Verify + commit.**
Run: `./scripts/check.sh`
Expected: analyze clean + all tests pass.
```bash
git add lib/src/shared/widgets/floating_pill_nav_item.dart lib/src/shared/widgets/currency_picker_chrome.dart lib/src/features/settings/widgets/base_currency_picker.dart lib/src/shared/widgets/currency_flag_icon.dart test/a11y_shared_test.dart
git commit -m "feat(a11y): label bottom nav + close buttons, hide decorative flags"
```

---

## Task 3: Convert tab semantic labels (+ localize hardcoded ones)

**Files:**
- Modify: `lib/src/features/convert/widgets/amount_utility_pill.dart` (~line 32-84, 3 tooltips)
- Modify: `lib/src/features/convert/widgets/currency_rate_row.dart` (~line 23-24, open InkWell)
- Modify: `lib/src/features/convert/widgets/swipe_action_widgets.dart` (~line 52-90, localize labels)
- Modify: `lib/src/features/convert/widgets/amount_base_button.dart` (~line 36, localize label)
- Modify: `lib/src/features/convert/widgets/amount_editing_field.dart` (~line 27, localize label)
- Modify: `lib/src/features/convert/widgets/amount_status_bar.dart` (~line 28-59, `(i)` label)
- Test: `test/a11y_convert_test.dart` (new)

- [ ] **Step 1: Write the failing test.** Create `test/a11y_convert_test.dart` covering the currency-row open label (the clearest gap). Use the row widget directly:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/features/convert/models/currency_quote.dart';
import 'package:currency_converter/src/features/convert/widgets/currency_rate_row.dart';

void main() {
  testWidgets('currency row exposes an open-conversion button label',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('en'),
      localizationsDelegates: AppTheme.localizationsDelegatesForTest, // see note
      supportedLocales: const [Locale('en')],
      home: Scaffold(
        body: CurrencyRateRow(
          quote: const CurrencyQuote('€', 'EUR', 'Euro', '86.20', '1 USD = 0.86 EUR'),
        ),
      ),
    ));
    expect(find.bySemanticsLabel('Open EUR conversion'), findsOneWidget);
    handle.dispose();
  });
}
```
**Note:** if `AppTheme.localizationsDelegatesForTest` does not exist, use the real ones:
`localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales` with `import 'package:currency_converter/l10n/app_localizations.dart';`. Confirm the `CurrencyQuote` constructor signature in `lib/src/features/convert/models/currency_quote.dart` and adjust the positional args to match (the existing `favorites_trend_row_test.dart` shows how quotes/snapshots are built — mirror it).

- [ ] **Step 2: Run to verify it fails.**
Run: `flutter test test/a11y_convert_test.dart`
Expected: FAIL — no node labeled "Open EUR conversion".

- [ ] **Step 3: Label the currency row.** In `currency_rate_row.dart`, wrap the `InkWell` (line ~23) in:

```dart
Semantics(
  button: true,
  label: l10n(context).openPairLabel(quote.code),
  child: InkWell( /* existing */ ),
)
```
Add `import '../../../../l10n/app_localizations_safe.dart';` if missing.

- [ ] **Step 4: Run to verify it passes.**
Run: `flutter test test/a11y_convert_test.dart`
Expected: PASS.

- [ ] **Step 5: Localize the toolbar tooltips.** In `amount_utility_pill.dart`, replace the three hardcoded tooltips and add `Semantics`:
  - Refresh → `tooltip: l10n(context).refreshRatesTooltip`, wrap `Semantics(button: true, label: l10n(context).refreshRatesTooltip, child: IconButton(...))`.
  - Share → `shareRatesTooltip` (same wrap).
  - Settings → `openSettingsTooltip` (same wrap).

- [ ] **Step 6: Localize swipe-action labels.** In `swipe_action_widgets.dart`, replace the hardcoded `Semantics` labels: `"Remove currency"` → `l10n(context).removeCurrencyLabel`; `"Add/Remove favorite"` → `l10n(context).toggleFavoriteLabel`; `"Set as base currency"` → `l10n(context).setAsBaseLabel`.

- [ ] **Step 7: Localize base + amount labels.** In `amount_base_button.dart` replace `'Change base currency, currently $base'` → `l10n(context).changeBaseCurrencyLabel(base)`. In `amount_editing_field.dart` replace `'Edit amount, currently ...'` → `l10n(context).editAmountLabel(amountText.isEmpty ? '0' : amountText)`.

- [ ] **Step 8: Label the freshness `(i)` button.** In `amount_status_bar.dart`, add `Semantics(button: true, label: l10n(context).rateFreshnessInfoLabel, child: <existing InkWell/Tooltip>)` around the info control (~line 28).

- [ ] **Step 9: Verify + commit.**
Run: `./scripts/check.sh`
Expected: analyze clean + all tests pass.
```bash
git add lib/src/features/convert/widgets/ test/a11y_convert_test.dart
git commit -m "feat(a11y): localize + label Convert tab controls"
```

---

## Task 4: Favorites + Charts semantic labels

**Files:**
- Modify: `lib/src/features/favorites/widgets/favorite_pair_row.dart` (~line 50, open InkWell)
- Modify: `lib/src/features/charts/widgets/chart_pair_pill.dart` (~line 32, selector)
- Modify: `lib/src/features/charts/widgets/range_selector.dart` (~line 35-99, range buttons)
- Modify: `lib/src/features/charts/widgets/chart_header.dart` (~line 96-116, swap button)
- Test: `test/a11y_favorites_charts_test.dart` (new)

- [ ] **Step 1: Write the failing test.** Create `test/a11y_favorites_charts_test.dart` asserting the favorites open-row label and a chart range button label. Build the favorites row mirroring `test/favorites_trend_row_test.dart` (use `theme: AppTheme.light`, English locale + `AppLocalizations` delegates, `index: 0`). Assert:

```dart
expect(find.bySemanticsLabel('Open USD → EUR'), findsOneWidget);
```
Use the actual label string the implementation will produce (see Step 3 — reuse the existing `openFavoriteTooltip` localized value if it reads better than a new one; pick one and assert exactly that). For the chart range button, pump `RangeSelector` and assert `find.bySemanticsLabel('1W range')` exists for the `1W` button.

- [ ] **Step 2: Run to verify it fails.**
Run: `flutter test test/a11y_favorites_charts_test.dart`
Expected: FAIL — labels absent.

- [ ] **Step 3: Label the favorites open row.** In `favorite_pair_row.dart`, wrap the top-level `InkWell` (line ~50) in `Semantics(button: true, label: l10n(context).openFavoriteTooltip, child: InkWell(...))`. (Reuse the existing `openFavoriteTooltip` key — "Open pair in Convert".) Adjust the test in Step 1 to assert that exact string instead of "Open USD → EUR".

- [ ] **Step 4: Label chart controls.**
  - `chart_pair_pill.dart` (~line 32): wrap the `InkWell` in `Semantics(button: true, label: l10n(context).changeChartPairLabel, child: ...)`.
  - `range_selector.dart` (~line 35-99): wrap each range button in `Semantics(button: true, selected: isSelected, label: l10n(context).chartRangeLabel(rangeText), child: <existing GestureDetector>)` where `rangeText` is the button's existing label (e.g. "1W") and `isSelected` is the existing selected flag.
  - `chart_header.dart` (~line 96): wrap the swap `GestureDetector` in `Semantics(button: true, label: l10n(context).swapCurrenciesTooltip, child: ...)`.

- [ ] **Step 5: Run to verify it passes.**
Run: `flutter test test/a11y_favorites_charts_test.dart`
Expected: PASS.

- [ ] **Step 6: Verify + commit.**
Run: `./scripts/check.sh`
Expected: analyze clean + all tests pass.
```bash
git add lib/src/features/favorites/widgets/favorite_pair_row.dart lib/src/features/charts/widgets/ test/a11y_favorites_charts_test.dart
git commit -m "feat(a11y): label Favorites open row + Charts controls"
```

---

## Task 5: Settings semantic labels

**Files:**
- Modify: `lib/src/features/settings/widgets/settings_tile.dart` (~line 33, tap target)
- Modify: `lib/src/features/settings/widgets/switch_tile.dart` (~line 25, toggle)
- Test: `test/a11y_settings_test.dart` (new)

- [ ] **Step 1: Inspect the tiles first.** Read `settings_tile.dart` and `switch_tile.dart` fully to confirm the title text field name and how the toggle is built. (The tile already shows a title `Text`; the goal is to make the row a labeled button and the switch announce its title + on/off state.)

- [ ] **Step 2: Write the failing test.** Create `test/a11y_settings_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/features/settings/widgets/switch_tile.dart';

void main() {
  testWidgets('switch tile exposes a labeled toggle with on/off state',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: SwitchTile(
          title: 'Dark Mode',
          value: true,
          onChanged: (_) {},
        ),
      ),
    ));
    expect(find.bySemanticsLabel('Dark Mode'), findsOneWidget);
    handle.dispose();
  });
}
```
Confirm `SwitchTile`'s real constructor params (title/value/onChanged) from Step 1 and adjust.

- [ ] **Step 3: Run to verify it fails.**
Run: `flutter test test/a11y_settings_test.dart`
Expected: FAIL.

- [ ] **Step 4: Label the switch tile.** Wrap the tile in `Semantics(container: true, label: title, toggled: value, child: <existing row>)`, and ensure the inner `Switch` is reachable (don't double-announce — `ExcludeSemantics` the duplicate title text if it would read twice). The `toggled:` flag makes screen readers announce on/off.

- [ ] **Step 5: Label the tappable settings tile.** In `settings_tile.dart`, when the tile has an `onTap`, wrap its `InkWell` in `Semantics(button: true, label: <tile title text>, child: InkWell(...))`. Leave non-interactive tiles (e.g. version display) as plain text (they read fine).

- [ ] **Step 6: Run to verify it passes.**
Run: `flutter test test/a11y_settings_test.dart`
Expected: PASS.

- [ ] **Step 7: Verify + commit.**
Run: `./scripts/check.sh`
Expected: analyze clean + all tests pass.
```bash
git add lib/src/features/settings/widgets/settings_tile.dart lib/src/features/settings/widgets/switch_tile.dart test/a11y_settings_test.dart
git commit -m "feat(a11y): label Settings tiles + toggles"
```

---

## Task 6: Dynamic Type survival pass

**Files:** (fixes applied where the check below fails — likely candidates listed)
- Likely: `lib/src/features/convert/widgets/currency_rate_row.dart`, `amount_panel.dart`, `lib/src/features/charts/widgets/chart_metric_rail.dart`, `range_selector.dart`, `lib/src/features/favorites/widgets/favorite_pair_row.dart`

- [ ] **Step 1: Capture the baseline at the bar.** Build + deploy to both emulators (see Task 9 commands), then set large text:
  - iOS: `xcrun simctl ui 87FB7A6A-58E4-4F45-A44E-EC071B06BC04 content_size extra-extra-extra-large` then capture each tab via `.devtools/sim_screenshot.sh`.
  - Android: `adb -s emulator-5554 shell settings put system font_scale 1.30` then relaunch + `.devtools/android_screenshot.sh`.
  Review each tab's screenshot for clipping/overflow/overlap.

- [ ] **Step 2: Fix overflow where found, using non-destructive techniques only:**
  - Numeric values that can clip (rate value, chart metrics): add `maxLines: 1` + `minimumScaleFactor: 0.6` (mirror the widget pattern already used).
  - Rows that overflow horizontally: allow the label to `Flexible`/`Expanded` with `overflow: TextOverflow.ellipsis`.
  - Vertically tight panels: ensure the containing screen is already scrollable (most tabs use `ListView`); if a fixed `Column` overflows, wrap in `SingleChildScrollView`.
  Apply only where Step 1 showed a problem. Do **not** hard-cap text scale globally (keep system Dynamic Type).

- [ ] **Step 3: Re-capture at the bar and confirm no clipping.** Repeat Step 1 captures; verify the previously-broken screens now render. Reset scale afterward (`content_size medium`; `font_scale 1.0`).

- [ ] **Step 4: Verify + commit.**
Run: `./scripts/check.sh`
Expected: analyze clean + all tests pass.
```bash
git add -A
git commit -m "fix(a11y): survive large Dynamic Type without clipping"
```
(If Step 1 finds **no** clipping anywhere, commit only a one-line note in the spec's verification section — `git commit --allow-empty -m "test(a11y): Dynamic Type bar verified, no clipping"` — and move on.)

---

## Task 7: Contrast pass (light + dark)

**Files:** fixes applied where found; likely muted/subtle text on tinted backgrounds (e.g. `quote_value.dart` rate line, `amount_status_bar.dart` freshness text, chart metric subtitles).

- [ ] **Step 1: Audit.** With both light and dark captures from Task 6 (or fresh captures), check small/muted text against its background for legibility. Focus on text using `colors.muted`/`colors.subtle` with reduced opacity on `colors.container`/paper, in **both** themes.

- [ ] **Step 2: Fix low-contrast spots** by swapping to a stronger existing token (e.g. `colors.muted` instead of `colors.subtle`, or removing an `.withValues(alpha: < .7)` that drops a label below legibility). Do **not** edit `AppColors.dark`; only change which token/opacity a widget uses.

- [ ] **Step 3: Re-capture light + dark; confirm.**

- [ ] **Step 4: Verify + commit.**
Run: `./scripts/check.sh`
Expected: analyze clean + all tests pass.
```bash
git add -A
git commit -m "fix(a11y): raise low-contrast text to AA in light + dark"
```
(If no contrast issues found: `git commit --allow-empty -m "test(a11y): contrast verified AA in light + dark"`.)

---

## Task 8: Light robustness verification + delete dead code

**Files:**
- Delete: `lib/src/shared/widgets/inline_empty_panel.dart`

- [ ] **Step 1: Confirm `InlineEmptyPanel` is unused.**
Run: `grep -rn "InlineEmptyPanel\|inline_empty_panel" lib test`
Expected: only the definition file. If any consumer exists, STOP and report (do not delete).

- [ ] **Step 2: Delete it.**
```bash
git rm lib/src/shared/widgets/inline_empty_panel.dart
```

- [ ] **Step 3: Analyze to confirm nothing broke.**
Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 4: Verify the existing offline/empty/loading states render.** On the Android emulator (fastest): with the app installed, turn the network off (`adb -s emulator-5554 shell svc wifi disable && adb -s emulator-5554 shell svc data disable`), clear app data (`adb -s emulator-5554 shell pm clear com.niduna.currency_converter`), relaunch via `.devtools/android_launch.sh`, and screenshot Convert → expect the `DesignedStatePanel` "No rates… pull to refresh / back online". Re-enable network (`svc wifi enable`), pull to refresh, confirm rates load. Capture Charts + Favorites empty states too. Record screenshots under `.tmp/screens/`.

- [ ] **Step 5: Commit.**
```bash
git add -A
git commit -m "chore(a11y): remove dead InlineEmptyPanel; verify offline/empty states"
```

---

## Task 9: Final verification + deploy to both emulators

**Files:** none (verification + deploy).

- [ ] **Step 1: Full gate.**
Run: `./scripts/check.sh`
Expected: analyze clean + all tests pass.

- [ ] **Step 2: Deploy to the iOS simulator** (auto-signs the widget per the build scripts):
```bash
IOS_SIMULATOR_ID=87FB7A6A-58E4-4F45-A44E-EC071B06BC04 SEED_DAYS=90 ./.devtools/run_seeded_ios_app.sh
```

- [ ] **Step 3: Deploy to the Android emulator:**
```bash
ANDROID_SERIAL=emulator-5554 BUILD_FIRST=1 ./.devtools/android_reinstall_build.sh
ANDROID_SERIAL=emulator-5554 ./.devtools/android_launch.sh
```

- [ ] **Step 4: Hand off for manual testing.** Report to the user: both emulators updated; suggest they test with VoiceOver (iOS: Settings → Accessibility → VoiceOver) and TalkBack (Android: Settings → Accessibility → TalkBack), plus large font, across all 4 tabs.

- [ ] **Step 5: Finish the branch.** Use `superpowers:finishing-a-development-branch` to choose merge/PR.

---

## Notes for the implementer

- **`find.bySemanticsLabel`** requires `tester.ensureSemantics()` and a disposed handle (shown in tests). For widgets needing localized strings, pump with `AppLocalizations.localizationsDelegates` + `supportedLocales` and `locale: const Locale('en')` so labels resolve to known English strings.
- **Reuse before adding:** `openFavoriteTooltip`, `removeFavoriteTooltip`, `reorderFavoriteTooltip` already exist — use them; only the Task 1 keys are new.
- **Don't double-announce:** when wrapping a control whose child already has text/icon semantics, `ExcludeSemantics` the child so the screen reader reads the wrapper label once.
- **File-size caps:** `favorite_pair_row.dart` (169), `chart_header.dart` (134), `amount_status_bar.dart` (114), `range_selector.dart` (106) already exceed caps — adding `Semantics` is fine, but if a file grows materially, extract a small sub-widget rather than letting it balloon.
