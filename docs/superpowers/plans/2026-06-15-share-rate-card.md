# Share Rate Card Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Share action to the Convert screen that renders a branded "rate card" image (base amount + visible pairs) off-screen and opens the OS share sheet.

**Architecture:** A pure mapper turns `ConvertState` into plain `RateCardData`. A stateless `RateCardImage` renders that data as an always-light branded card. `RateCardRenderer.captureBoundary` turns a mounted `RepaintBoundary` into PNG bytes (testable). `shareRateCard` mounts the card off-screen in an `OverlayEntry`, captures it, writes a temp PNG, and shares via `share_plus`. A Share icon in the Convert header triggers it.

**Tech Stack:** Flutter 3.41 / Dart 3.11, `share_plus`, `path_provider`. Spec: `docs/superpowers/specs/2026-06-15-share-rate-card-design.md`.

**Note on rendering approach:** The spec described a detached `RenderView` pipeline. This plan uses an off-screen `OverlayEntry` + `RepaintBoundary` instead — same "off-screen, no flash" outcome, but version-stable on Flutter 3.41 (the `RenderView`/`ViewConfiguration` constructor is version-fragile).

---

### Task 1: Add dependencies

**Files:**
- Modify: `pubspec.yaml`

- [ ] **Step 1: Add the packages**

Run: `flutter pub add share_plus path_provider`
Expected: `pubspec.yaml` gains `share_plus:` and `path_provider:` under dependencies; `flutter pub get` runs.

- [ ] **Step 2: Verify resolution**

Run: `flutter pub get`
Expected: "Got dependencies!" with no version conflicts.

- [ ] **Step 3: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add share_plus + path_provider for rate-card sharing"
```

---

### Task 2: RateCardData model

**Files:**
- Create: `lib/src/features/convert/models/rate_card_data.dart`

- [ ] **Step 1: Write the model**

```dart
/// Plain data for the shareable rate card — independent of ConvertState so the
/// card widget can be rendered and tested in isolation.
class RateCardData {
  const RateCardData({
    required this.baseAmountLabel,
    required this.rows,
    required this.footerLabel,
  });

  final String baseAmountLabel; // e.g. "100 USD"
  final List<RateCardRowData> rows;
  final String footerLabel; // e.g. "Updated Jun 15"
}

class RateCardRowData {
  const RateCardRowData({required this.name, required this.valueLabel});

  final String name; // e.g. "Euro"
  final String valueLabel; // e.g. "€ 86.34"
}
```

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/src/features/convert/models/rate_card_data.dart`
Expected: "No issues found!"

- [ ] **Step 3: Commit**

```bash
git add lib/src/features/convert/models/rate_card_data.dart
git commit -m "feat(share): add RateCardData model"
```

---

### Task 3: Map ConvertState → RateCardData

**Files:**
- Create: `lib/src/features/convert/presentation/rate_card_data_mapper.dart`
- Test: `test/rate_card_data_mapper_test.dart`

- [ ] **Step 1: Write the failing test**

```dart
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/features/convert/domain/convert_state.dart';
import 'package:currency_converter/src/features/convert/models/currency_quote.dart';
import 'package:currency_converter/src/features/convert/presentation/rate_card_data_mapper.dart';

void main() {
  ConvertState state() => ConvertState(
        status: ConvertStatus.fresh,
        quotes: const <CurrencyQuote>[
          CurrencyQuote('€', 'EUR', 'Euro', '86.34', '1 USD = 0.86 EUR',
              rate: 0.8634),
          CurrencyQuote('£', 'GBP', 'British Pound', '74.57', '1 USD = 0.75 GBP',
              rate: 0.7457),
        ],
        lastUpdatedLabel: 'Updated Jun 15',
        nextUpdateLabel: 'Next around 4pm',
        base: 'USD',
        amountText: '100.00',
        selectedCodes: const <String>['EUR', 'GBP'],
      );

  test('maps base amount, rows, and footer', () {
    final data = rateCardDataFromState(state());

    expect(data.baseAmountLabel, '100 USD');
    expect(data.footerLabel, 'Updated Jun 15');
    expect(data.rows.length, 2);
    expect(data.rows.first.name, 'Euro');
    expect(data.rows.first.valueLabel, '€ 86.34');
  });

  test('keeps two decimals for non-integer amounts', () {
    final data = rateCardDataFromState(
      state().copyWith(amountText: '12.50'),
    );
    expect(data.baseAmountLabel, '12.50 USD');
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/rate_card_data_mapper_test.dart`
Expected: FAIL — `rateCardDataFromState` is undefined.

- [ ] **Step 3: Write the mapper**

```dart
import '../domain/convert_state.dart';
import '../models/rate_card_data.dart';

/// Builds the rate-card payload from the current Convert state. Pure.
RateCardData rateCardDataFromState(ConvertState state) {
  final amount = double.tryParse(state.amountText);
  final amountLabel = amount == null
      ? state.amountText
      : (amount == amount.roundToDouble()
          ? amount.round().toString()
          : amount.toStringAsFixed(2));

  return RateCardData(
    baseAmountLabel: '$amountLabel ${state.base}',
    rows: state.quotes
        .map((q) => RateCardRowData(
              name: q.name,
              valueLabel: '${q.symbol} ${q.amount}',
            ))
        .toList(),
    footerLabel: state.lastUpdatedLabel,
  );
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/rate_card_data_mapper_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/src/features/convert/presentation/rate_card_data_mapper.dart test/rate_card_data_mapper_test.dart
git commit -m "feat(share): map ConvertState to RateCardData"
```

---

### Task 4: RateCardImage + RateCardRow widgets

**Files:**
- Create: `lib/src/features/convert/widgets/share/rate_card_row.dart`
- Create: `lib/src/features/convert/widgets/share/rate_card_image.dart`
- Test: `test/rate_card_image_test.dart`

- [ ] **Step 1: Write the row widget**

`lib/src/features/convert/widgets/share/rate_card_row.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/rate_card_data.dart';

/// One "Name ............ value" line on the share card. Always light colors.
class RateCardRow extends StatelessWidget {
  const RateCardRow({required this.data, super.key});

  final RateCardRowData data;

  @override
  Widget build(BuildContext context) {
    const colors = AppColors.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              data.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            data.valueLabel,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colors.text,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Write the card widget**

`lib/src/features/convert/widgets/share/rate_card_image.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/rate_card_data.dart';
import 'rate_card_row.dart';

/// The branded, always-light rate card rendered off-screen and shared as PNG.
/// Fixed width so it lays out under loose (off-screen) constraints.
class RateCardImage extends StatelessWidget {
  const RateCardImage({required this.data, super.key});

  static const double width = 360;
  final RateCardData data;

  @override
  Widget build(BuildContext context) {
    const colors = AppColors.light;
    final divider = Divider(
      color: colors.border.withValues(alpha: .5),
      height: 24,
      thickness: 1,
    );
    return Container(
      width: width,
      color: colors.bg,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Niduna · Currency',
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            data.baseAmountLabel,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 30,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: colors.text,
            ),
          ),
          divider,
          for (final row in data.rows) RateCardRow(data: row),
          divider,
          Text(
            data.footerLabel,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 3: Write the widget test**

`test/rate_card_image_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/features/convert/models/rate_card_data.dart';
import 'package:currency_converter/src/features/convert/widgets/share/rate_card_image.dart';

void main() {
  const data = RateCardData(
    baseAmountLabel: '100 USD',
    rows: <RateCardRowData>[
      RateCardRowData(name: 'Euro', valueLabel: '€ 86.34'),
      RateCardRowData(name: 'British Pound', valueLabel: '£ 74.57'),
    ],
    footerLabel: 'Updated Jun 15',
  );

  testWidgets('renders wordmark, amount, rows, and footer without overflow',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: RateCardImage(data: data)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Niduna · Currency'), findsOneWidget);
    expect(find.text('100 USD'), findsOneWidget);
    expect(find.text('Euro'), findsOneWidget);
    expect(find.text('€ 86.34'), findsOneWidget);
    expect(find.text('Updated Jun 15'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/rate_card_image_test.dart`
Expected: PASS (1 test).

- [ ] **Step 5: Analyze**

Run: `flutter analyze lib/src/features/convert/widgets/share`
Expected: "No issues found!"

- [ ] **Step 6: Commit**

```bash
git add lib/src/features/convert/widgets/share test/rate_card_image_test.dart
git commit -m "feat(share): add RateCardImage + RateCardRow widgets"
```

---

### Task 5: RateCardRenderer — boundary to PNG bytes

**Files:**
- Create: `lib/src/core/share/rate_card_renderer.dart`
- Test: `test/rate_card_renderer_test.dart`

- [ ] **Step 1: Write the failing test**

`test/rate_card_renderer_test.dart`:

```dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/share/rate_card_renderer.dart';

void main() {
  testWidgets('captureBoundary returns PNG bytes for a mounted boundary',
      (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RepaintBoundary(
            key: key,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: ColoredBox(color: Color(0xFF112233)),
            ),
          ),
        ),
      ),
    );

    Uint8List? bytes;
    await tester.runAsync(() async {
      bytes = await RateCardRenderer.captureBoundary(key, pixelRatio: 1);
    });

    expect(bytes, isNotNull);
    expect(bytes!.length, greaterThan(8));
    // PNG signature.
    expect(
      bytes!.sublist(0, 8),
      equals(<int>[137, 80, 78, 71, 13, 10, 26, 10]),
    );
  });

  testWidgets('returns null when the key has no boundary', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(const SizedBox());
    expect(await RateCardRenderer.captureBoundary(key), isNull);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/rate_card_renderer_test.dart`
Expected: FAIL — `RateCardRenderer` is undefined.

- [ ] **Step 3: Write the renderer**

`lib/src/core/share/rate_card_renderer.dart`:

```dart
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Captures a mounted RepaintBoundary (referenced by [key]) to PNG bytes.
/// Separated from the share orchestration so it can be unit-tested.
class RateCardRenderer {
  static Future<Uint8List?> captureBoundary(
    GlobalKey key, {
    double pixelRatio = 3,
  }) async {
    final object = key.currentContext?.findRenderObject();
    if (object is! RenderRepaintBoundary) return null;
    final ui.Image image = await object.toImage(pixelRatio: pixelRatio);
    final ByteData? data =
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/rate_card_renderer_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/src/core/share/rate_card_renderer.dart test/rate_card_renderer_test.dart
git commit -m "feat(share): add RateCardRenderer.captureBoundary"
```

---

### Task 6: shareRateCard orchestration

**Files:**
- Create: `lib/src/core/share/share_rate_card.dart`

No unit test — this composes `path_provider` and `share_plus` platform channels, verified on device in Task 8. The renderable parts are already covered by Tasks 3–5.

- [ ] **Step 1: Write the orchestration**

`lib/src/core/share/share_rate_card.dart`:

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../features/convert/models/rate_card_data.dart';
import '../../features/convert/widgets/share/rate_card_image.dart';
import 'rate_card_renderer.dart';

/// Renders [data] as a branded card off-screen, writes a temp PNG, and opens
/// the OS share sheet. Off-screen (Positioned far left) so there is no flash.
Future<void> shareRateCard(BuildContext context, RateCardData data) async {
  final overlay = Overlay.of(context);
  final key = GlobalKey();
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -10000,
      top: 0,
      child: Material(
        type: MaterialType.transparency,
        child: RepaintBoundary(key: key, child: RateCardImage(data: data)),
      ),
    ),
  );
  final messenger = ScaffoldMessenger.of(context);
  overlay.insert(entry);
  try {
    // Let the off-screen card lay out and paint before capturing.
    await Future<void>.delayed(const Duration(milliseconds: 40));
    final bytes = await RateCardRenderer.captureBoundary(key, pixelRatio: 3);
    if (bytes == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Couldn’t create the image, try again')),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/niduna-rates.png');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: <XFile>[XFile(file.path)],
        text: 'Exchange rates · ${data.baseAmountLabel} — via Niduna',
      ),
    );
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Couldn’t share the rates, try again')),
    );
  } finally {
    entry.remove();
  }
}
```

> **share_plus API note:** This targets share_plus ≥ 10 (`SharePlus.instance.share(ShareParams(...))`). If `flutter pub add` resolved an older major (< 9), replace the call with `Share.shareXFiles(<XFile>[XFile(file.path)], text: ...)` and import as before.

- [ ] **Step 2: Analyze**

Run: `flutter analyze lib/src/core/share`
Expected: "No issues found!" (if the share_plus symbol errors, apply the API note above, then re-run.)

- [ ] **Step 3: Commit**

```bash
git add lib/src/core/share/share_rate_card.dart
git commit -m "feat(share): orchestrate off-screen render + temp file + share sheet"
```

---

### Task 7: Wire the Share button through the Convert UI

**Files:**
- Modify: `lib/src/features/convert/widgets/amount_utility_pill.dart`
- Modify: `lib/src/features/convert/widgets/amount_header_row.dart`
- Modify: `lib/src/features/convert/widgets/amount_panel.dart`
- Modify: `lib/src/features/convert/widgets/convert_content.dart`
- Modify: `lib/src/features/convert/convert_screen.dart`

- [ ] **Step 1: Add onShare to AmountUtilityPill**

In `amount_utility_pill.dart`, add the field and a third icon button. Update the constructor and the `Row`:

```dart
  const AmountUtilityPill({
    required this.onRefresh,
    required this.onShare,
    required this.onMore,
    super.key,
  });

  final VoidCallback onRefresh;
  final VoidCallback onShare;
  final VoidCallback onMore;
```

Inside the `Row` children, between the refresh button's trailing divider and the settings button, insert a Share button + divider (mirror the existing `_UtilityIconButton` + `VerticalDivider` pattern already in the file):

```dart
          _UtilityIconButton(
            key: const Key('convert_share'),
            tooltip: 'Share rates',
            icon: Icons.ios_share_rounded,
            onPressed: onShare,
          ),
          SizedBox(
            height: 20,
            child: VerticalDivider(
              width: 1,
              thickness: 1,
              color: colors.border.withValues(alpha: .1),
            ),
          ),
```

(Place this block immediately before the existing "Settings" `_UtilityIconButton`.)

- [ ] **Step 2: Thread onShare through AmountHeaderRow**

In `amount_header_row.dart`:

```dart
  const AmountHeaderRow({
    required this.onRefresh,
    required this.onShare,
    required this.onMore,
    super.key,
  });

  final VoidCallback onRefresh;
  final VoidCallback onShare;
  final VoidCallback onMore;
```

And pass it on:

```dart
        AmountUtilityPill(onRefresh: onRefresh, onShare: onShare, onMore: onMore),
```

- [ ] **Step 3: Thread onShare through AmountPanel**

In `amount_panel.dart`, add `required this.onShare,` to the constructor, add `final VoidCallback onShare;`, and update the `AmountHeaderRow` call:

```dart
          AmountHeaderRow(
            onRefresh: () => onRefresh(),
            onShare: onShare,
            onMore: onMore,
          ),
```

- [ ] **Step 4: Thread onShare through ConvertContent**

In `convert_content.dart`, add `required this.onShare,` to the constructor, add `final VoidCallback onShare;`, and pass it to `AmountPanel`:

```dart
        AmountPanel(
          isRefreshing: widget.state.isRefreshing,
          lastUpdatedLabel: widget.state.lastUpdatedLabel,
          nextUpdateLabel: widget.state.nextUpdateLabel,
          status: widget.state.status,
          amountText: widget.state.amountText,
          base: widget.state.base,
          onRefresh: widget.onRefresh,
          onShare: widget.onShare,
          onMore: widget.onMore,
          onAmountChanged: widget.onAmountChanged,
          onBaseTap: () => _openPicker(context, selectBaseMode: true),
        ),
```

- [ ] **Step 5: Wire it in ConvertScreen**

In `convert_screen.dart`, add the import:

```dart
import '../../core/share/share_rate_card.dart';
import 'presentation/rate_card_data_mapper.dart';
```

Add `onShare` to the `ConvertContent` call (inside the `builder`, where `context` is available):

```dart
              builder: (context, _) => ConvertContent(
                state: controller.state,
                onRefresh: controller.refresh,
                onShare: () {
                  if (!controller.state.hasQuotes) return;
                  shareRateCard(
                    context,
                    rateCardDataFromState(controller.state),
                  );
                },
                onAmountChanged: controller.setAmountText,
                onSelectBase: controller.setBase,
                onToggleCode: controller.toggleCode,
                onToggleFavorite: controller.tryToggleFavorite,
                onPairOpened: controller.recordPairUsage,
                onMore: onNavigateToSettings,
                maxFavoritesReached: controller.maxFavoritesReached,
              ),
```

- [ ] **Step 6: Update the existing ConvertContent test for the new required param**

In `test/ui_redesign_widget_test.dart`, add `onShare: () {},` to the `ConvertContent(...)` constructor call (alongside `onMore: () {}`), so the test still compiles.

- [ ] **Step 7: Analyze + run affected tests**

Run: `flutter analyze lib/src/features/convert && flutter test test/ui_redesign_widget_test.dart`
Expected: "No issues found!" and all tests pass.

- [ ] **Step 8: Commit**

```bash
git add lib/src/features/convert test/ui_redesign_widget_test.dart
git commit -m "feat(share): add Share button to the Convert header"
```

---

### Task 8: Full verification + device check

**Files:** none (verification only)

- [ ] **Step 1: Full suite**

Run: `FLUTTER_BIN=/opt/homebrew/bin/flutter ./scripts/check.sh`
Expected: analyze clean, all tests pass.

- [ ] **Step 2: Build + install on the emulator**

Run: `ANDROID_SERIAL=emulator-5554 BUILD_FIRST=1 ./.devtools/android_reinstall_build.sh && ./.devtools/android_launch.sh`
Expected: app launches to Convert.

- [ ] **Step 3: Capture and confirm the Share button is present**

Run: `MAX_DIM=1400 ./.devtools/android_screenshot.sh share_button`
Expected: the header pill shows refresh • share • settings icons. Read the PNG to confirm.

- [ ] **Step 4: Manually verify the share sheet**

Tap the Share icon in the header. Confirm the Android share sheet opens with the `niduna-rates.png` image attached and the caption text. (Manual — `share_plus` is a platform channel, not unit-tested.)

- [ ] **Step 5: Final commit (if any verification fixups were needed)**

```bash
git add -A
git commit -m "chore(share): verification fixups"
```

---

## Out of scope (per spec)

Trend badges on the card, choosing/reordering pairs, a logo image asset, a dark-theme card variant, and a deep-link CTA. The footer uses `lastUpdatedLabel` (date) rather than asserting "ECB", which would be inaccurate when crypto rows are present.
