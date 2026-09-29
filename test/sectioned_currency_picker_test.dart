import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/currency/currency_groups.dart';
import 'package:currency_converter/src/core/currency/supported_currencies.dart';
import 'package:currency_converter/src/shared/widgets/currency_section_header.dart';
import 'package:currency_converter/src/shared/widgets/sectioned_currency_picker.dart';

void main() {
  Widget harness(Widget child) => MaterialApp(home: Scaffold(body: child));

  Widget simpleTile(
    BuildContext context,
    SupportedCurrency currency, {
    VoidCallback? onTap,
  }) => ListTile(
    key: ValueKey('tile_${currency.code}'),
    title: Text(currency.name),
    subtitle: Text(currency.code),
    onTap: onTap ?? () {},
  );

  testWidgets('opens with the selection and popular currencies visible', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        SectionedCurrencyPicker(
          title: 'Select base currency',
          currencies: supportedFiatCurrencies,
          highlightedCodes: const ['USD'],
          tileBuilder: simpleTile,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Selected'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    // USD is highlighted, so it appears once under "Selected" and is skipped
    // from the "Popular" row even though it's in the default popular list.
    expect(find.byKey(const ValueKey('tile_USD')), findsOneWidget);
    // EUR is a popular default and not the highlighted code.
    expect(find.byKey(const ValueKey('tile_EUR')), findsOneWidget);
    // Region groups are present but collapsed, except the one auto-expanded
    // by expandSectionsForCodes (none given here), so a non-popular,
    // non-selected currency stays hidden until its group is expanded.
    expect(find.byKey(const ValueKey('tile_PLN')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('expands the group containing the current selection', (
    tester,
  ) async {
    // Tall viewport so every region group renders without needing to
    // scroll the lazy list to find headers below the fold.
    tester.view.physicalSize = const Size(400, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      harness(
        SectionedCurrencyPicker(
          title: 'Select base currency',
          currencies: supportedFiatCurrencies,
          highlightedCodes: const ['USD'],
          expandSectionsForCodes: const ['USD'],
          tileBuilder: simpleTile,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final americasHeader = find.byWidgetPredicate(
      (w) => w is CurrencySectionHeader && w.group.section == CurrencySection.americas,
    );
    expect(americasHeader, findsOneWidget);
    expect(tester.widget<CurrencySectionHeader>(americasHeader).isExpanded, isTrue);
    // A currency only present in the Americas group (not selected/popular)
    // is visible without tapping anything (no need to expand the group).
    expect(find.byKey(const ValueKey('tile_MXN')), findsOneWidget);

    final europeHeader = find.byWidgetPredicate(
      (w) => w is CurrencySectionHeader && w.group.section == CurrencySection.europe,
    );
    expect(tester.widget<CurrencySectionHeader>(europeHeader).isExpanded, isFalse);
  });

  testWidgets('searching hides the top section and filters flat results', (
    tester,
  ) async {
    await tester.pumpWidget(
      harness(
        SectionedCurrencyPicker(
          title: 'Select base currency',
          currencies: supportedFiatCurrencies,
          highlightedCodes: const ['USD'],
          tileBuilder: simpleTile,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'PLN');
    await tester.pumpAndSettle();

    expect(find.text('Selected'), findsNothing);
    expect(find.text('Popular'), findsNothing);
    expect(find.text('Europe (1)'), findsOneWidget);
    // Search results are shown without needing to expand the group.
    await tester.tap(find.text('Europe (1)'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('tile_PLN')), findsOneWidget);
  });

  testWidgets('single-select tile taps report the tapped code once', (
    tester,
  ) async {
    final taps = <String>[];
    await tester.pumpWidget(
      harness(
        SectionedCurrencyPicker(
          title: 'Select base currency',
          currencies: supportedFiatCurrencies,
          highlightedCodes: const ['USD'],
          tileBuilder: (context, currency) =>
              simpleTile(context, currency, onTap: () => taps.add(currency.code)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('tile_EUR')));
    expect(taps, ['EUR']);
  });

  testWidgets('multi-toggle tile taps can add and remove several codes', (
    tester,
  ) async {
    final selected = <String>{'USD', 'EUR'};
    late StateSetter setState;
    await tester.pumpWidget(
      harness(
        StatefulBuilder(
          builder: (context, setter) {
            setState = setter;
            return SectionedCurrencyPicker(
              title: 'Add currencies',
              currencies: supportedFiatCurrencies,
              highlightedCodes: selected.toList(),
              tileBuilder: (context, currency) => simpleTile(
                context,
                currency,
                onTap: () => setState(() {
                  if (!selected.add(currency.code)) {
                    selected.remove(currency.code);
                  }
                }),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('tile_GBP')));
    await tester.pumpAndSettle();
    expect(selected, containsAll(['USD', 'EUR', 'GBP']));

    await tester.tap(find.byKey(const ValueKey('tile_USD')).first);
    await tester.pumpAndSettle();
    expect(selected.contains('USD'), isFalse);
  });

  testWidgets('a locked-currency callback builder is invoked on tap', (
    tester,
  ) async {
    const lockedCode = 'JPY';
    String? unlockRequestedFor;
    await tester.pumpWidget(
      harness(
        SectionedCurrencyPicker(
          title: 'Select quote currency',
          currencies: supportedFiatCurrencies,
          highlightedCodes: const ['USD'],
          expandSectionsForCodes: const ['JPY'],
          tileBuilder: (context, currency) {
            final isLocked = currency.code == lockedCode;
            return ListTile(
              key: ValueKey('tile_${currency.code}'),
              title: Text(currency.name),
              trailing: isLocked ? const Icon(Icons.lock) : null,
              onTap: isLocked
                  ? () => unlockRequestedFor = currency.code
                  : () {},
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('tile_JPY')));
    expect(unlockRequestedFor, 'JPY');
  });

  testWidgets('no overflow at text scale 2.0 on a 360x640 viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: Scaffold(
            body: SectionedCurrencyPicker(
              title: 'Select base currency',
              subtitle: 'Current base USD',
              currencies: allSupportedCurrencies,
              highlightedCodes: const ['USD'],
              expandSectionsForCodes: const ['USD'],
              tileBuilder: simpleTile,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Select base currency'), findsOneWidget);
  });
}
