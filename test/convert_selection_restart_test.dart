import 'package:currency_converter/src/core/preferences/app_preferences.dart';
import 'dart:async';
import 'package:currency_converter/src/app.dart';
import 'package:currency_converter/src/features/settings/settings_screen.dart';
import 'package:currency_converter/src/features/convert/presentation/convert_controller.dart';
import 'package:currency_converter/src/features/convert/convert_screen.dart';
import 'package:currency_converter/src/features/convert/data/latest_rates_repository.dart';
import 'package:currency_converter/src/features/convert/domain/latest_rates_snapshot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'an old rates response cannot replace the newly selected base rates',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final preferences = AppPreferences(await SharedPreferences.getInstance());
      final repo = _DelayedRates();
      final controller = ConvertController(
        repository: repo,
        preferences: preferences,
        selectedCodes: ['EUR', 'CHF'],
      );
      final oldRefresh = controller.refresh();
      await controller.setBase('CHF');
      repo.usd.complete(
        LatestRatesSnapshot(
          base: 'USD',
          date: DateTime.now(),
          savedAt: DateTime.now(),
          rates: {'EUR': 1, 'CHF': 2},
        ),
      );
      await oldRefresh;
      expect(controller.state.base, 'CHF');
      expect(controller.snapshot!.base, 'CHF');
      expect(controller.snapshot!.rates['EUR'], 3);
      controller.dispose();
    },
  );
  testWidgets('explicit Settings default survives a later Convert edit', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final repo = _Rates();
    await tester.pumpWidget(CurrencyConverterApp(convertRepository: repo));
    await tester.pumpAndSettle();
    final controller = tester
        .widget<ConvertScreen>(find.byType(ConvertScreen))
        .controller;
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    final preferences = tester
        .widget<SettingsScreen>(find.byType(SettingsScreen))
        .preferences;
    await preferences.setDefaultBaseCurrency('CHF');
    await tester.pumpAndSettle();
    controller.toggleCode('CAD');
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      CurrencyConverterApp(
        key: const ValueKey('restart'),
        convertRepository: repo,
      ),
    );
    await tester.pumpAndSettle();
    final restarted = tester
        .widget<ConvertScreen>(find.byType(ConvertScreen))
        .controller;
    expect(restarted.state.base, 'CHF');
    expect(restarted.state.savedCodes, contains('CHF'));
    await restarted.setBase('USD');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester
        .widget<SettingsScreen>(find.byType(SettingsScreen))
        .preferences
        .setDefaultBaseCurrency('CHF');
    await tester.pumpAndSettle();
    expect(
      restarted.state.base,
      'CHF',
      reason:
          're-selecting the same Settings default is still an explicit choice',
    );
  });
  testWidgets(
    'Undo restores a removed Convert currency in its saved position',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'pref_selected_codes': <String>['EUR', 'CHF'],
      });
      await tester.pumpWidget(
        CurrencyConverterApp(convertRepository: _Rates()),
      );
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const Key('convert_row_EUR')),
        const Offset(-300, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('remove_EUR')));
      await tester.pumpAndSettle();
      final controller = tester
          .widget<ConvertScreen>(find.byType(ConvertScreen))
          .controller;
      expect(controller.state.selectedCodes, ['CHF']);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(controller.state.selectedCodes, ['EUR', 'CHF']);
      await tester.drag(
        find.byKey(const Key('convert_row_EUR')),
        const Offset(-300, 0),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('remove_EUR')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      expect(find.text('Undo'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(controller.state.selectedCodes, ['CHF']);
    },
  );
  testWidgets(
    'base picker offers only saved currencies and can switch directly',
    (tester) async {
      SharedPreferences.setMockInitialValues({
        'pref_selected_codes': <String>['EUR', 'BTC'],
      });
      await tester.pumpWidget(
        CurrencyConverterApp(convertRepository: _Rates()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('open_base_currency_picker')));
      await tester.pumpAndSettle();
      // A catalog group would expose currencies outside the saved collection.
      expect(find.text('Swiss Franc'), findsNothing);
      expect(find.text('Euro'), findsWidgets);
      await tester.tap(find.text('Euro').last);
      await tester.pumpAndSettle();
      final controller = tester
          .widget<ConvertScreen>(find.byType(ConvertScreen))
          .controller;
      expect(controller.state.base, 'EUR');
      expect(controller.state.selectedCodes, ['USD', 'BTC']);
    },
  );
  testWidgets('selected base and currency collection survive app recreation', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'pref_selected_codes': <String>['EUR', 'CHF', 'BTC'],
    });
    Future<void> launch(int key) async {
      await tester.pumpWidget(
        CurrencyConverterApp(key: ValueKey(key), convertRepository: _Rates()),
      );
      await tester.pumpAndSettle();
    }

    await launch(1);
    var controller = tester
        .widget<ConvertScreen>(find.byType(ConvertScreen))
        .controller;
    await controller.setBase('CHF');
    await tester.pumpAndSettle();
    expect(controller.state.base, 'CHF');
    expect(controller.state.selectedCodes, ['USD', 'EUR', 'BTC']);
    await launch(2);
    controller = tester
        .widget<ConvertScreen>(find.byType(ConvertScreen))
        .controller;
    expect(controller.state.base, 'CHF');
    expect(controller.state.selectedCodes, ['USD', 'EUR', 'BTC']);
    await controller.setBase('BTC');
    await tester.pumpAndSettle();
    await launch(3);
    controller = tester
        .widget<ConvertScreen>(find.byType(ConvertScreen))
        .controller;
    expect(controller.state.base, 'BTC');
    expect(controller.state.selectedCodes, ['USD', 'EUR', 'CHF']);
    controller.toggleCode('EUR');
    controller.toggleCode('CAD');
    await tester.pumpAndSettle();
    await launch(4);
    controller = tester
        .widget<ConvertScreen>(find.byType(ConvertScreen))
        .controller;
    expect(controller.state.base, 'BTC');
    expect(controller.state.selectedCodes, ['USD', 'CHF', 'CAD']);
  });
}

class _DelayedRates extends _Rates {
  final usd = Completer<LatestRatesSnapshot>();
  @override
  Future<LatestRatesSnapshot> fetchLatest(String base) => base == 'USD'
      ? usd.future
      : Future.value(
          LatestRatesSnapshot(
            base: base,
            date: DateTime.now(),
            savedAt: DateTime.now(),
            rates: {'EUR': 3, 'USD': 4},
          ),
        );
}

class _Rates implements ConvertRatesRepository {
  @override
  Future<LatestRatesSnapshot?> readCached(String base) async => null;
  @override
  Future<LatestRatesSnapshot> fetchLatest(String base) async =>
      LatestRatesSnapshot(
        base: base,
        date: DateTime(2026, 10, 14),
        savedAt: DateTime.now(),
        rates: {
          for (final code in ['USD', 'EUR', 'CHF', 'BTC', 'CAD'])
            if (code != base) code: 1,
        },
      );
  @override
  Future<void> cacheSnapshot(LatestRatesSnapshot snapshot) async {}
  @override
  Future<Map<String, double>?> fetchPreviousRates(
    String base, {
    DateTime? referenceDate,
  }) async => null;
}
