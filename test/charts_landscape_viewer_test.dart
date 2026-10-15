import 'package:currency_converter/l10n/app_localizations.dart';
import 'package:currency_converter/src/core/monetization/monetization_controller.dart';
import 'package:currency_converter/src/core/rates/models/rates_result.dart';
import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/features/charts/charts_screen.dart';
import 'package:currency_converter/src/features/charts/domain/chart_repository.dart';
import 'package:currency_converter/src/features/charts/domain/chart_range.dart';
import 'package:currency_converter/src/features/charts/presentation/charts_controller.dart';
import 'package:currency_converter/src/features/charts/widgets/chart_currency_picker_sheet.dart';
import 'package:currency_converter/src/features/charts/widgets/chart_currency_tile.dart';
import 'package:flutter/material.dart';
import 'package:currency_converter/src/shared/widgets/currency_section_header.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountingChartRepository implements ChartRepository {
  int calls = 0;
  @override
  Future<HistoricalResult> getHistoricalRates({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  }) async {
    calls++;
    return const HistoricalResult(status: HistoricalStatus.noCache);
  }
}

void main() {
  testWidgets(
    'USD candidate in a restricted pair uses pair entitlement, not free currency shortcut',
    (tester) async {
      tester.view.physicalSize = const Size(640, 320);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({
        'entitlement_remove_ads_lifetime': true,
      });
      final monetization = MonetizationController(
        await SharedPreferences.getInstance(),
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ChartCurrencyPickerSheet(
              title: 'Quote',
              selectedCode: 'JPY',
              allowCryptoCharts: true,
              controller: monetization,
              baseCurrency: 'CHF',
              quoteCurrency: 'JPY',
              selectingBase: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'USD');
      await tester.pumpAndSettle();
      await tester.tap(
        find.byWidgetPredicate(
          (w) =>
              w is CurrencySectionHeader &&
              w.group.currencies.any((c) => c.code == 'USD'),
        ),
      );
      await tester.pumpAndSettle();
      final tile = tester.widget<ChartCurrencyTile>(
        find.byWidgetPredicate(
          (w) => w is ChartCurrencyTile && w.code == 'USD',
        ),
      );
      expect(tile.unlocked, isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      monetization.dispose();
    },
  );
  testWidgets(
    'expanded chart shares selection, preserves dark theme and returns without reload',
    (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({
        'entitlement_remove_ads_lifetime': true,
        'entitlement_charts_pro_lifetime': true,
      });
      final monetization = MonetizationController(
        await SharedPreferences.getInstance(),
      );
      final repository = CountingChartRepository();
      final controller = ChartsController(
        repository: repository,
        allowCryptoCharts: true,
      );
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Theme(
            data: AppTheme.dark,
            child: Scaffold(
              body: ChartsScreen(
                controller: controller,
                monetization: monetization,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(repository.calls, 1);
      await tester.tap(find.byKey(const Key('charts_expand')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('charts_landscape_viewer')), findsOneWidget);
      final viewerContext = tester.element(
        find.byKey(const Key('charts_landscape_viewer')),
      );
      expect(Theme.of(viewerContext).brightness, Brightness.dark);
      expect(repository.calls, 1);
      controller.setRange(ChartRange.oneWeek);
      await tester.pumpAndSettle();
      expect(repository.calls, 2);
      await tester.tap(find.byKey(const Key('charts_collapse')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('charts_landscape_viewer')), findsNothing);
      expect(controller.state.range, ChartRange.oneWeek);
      expect(repository.calls, 2);
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      monetization.dispose();
    },
  );
}
