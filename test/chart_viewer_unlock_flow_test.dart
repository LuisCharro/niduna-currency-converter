import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:currency_converter/l10n/app_localizations.dart';
import 'package:currency_converter/src/core/monetization/monetization_controller.dart';
import 'package:currency_converter/src/core/monetization/purchase_service.dart';
import 'package:currency_converter/src/core/monetization/rewarded_ad_service.dart';
import 'package:currency_converter/src/core/rates/models/rates_result.dart';
import 'package:currency_converter/src/core/rates/models/rates_snapshot.dart';
import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/src/features/charts/charts_landscape_screen.dart';
import 'package:currency_converter/src/features/charts/domain/chart_repository.dart';
import 'package:currency_converter/src/features/charts/domain/chart_range.dart';
import 'package:currency_converter/src/features/charts/presentation/chart_viewer_session.dart';
import 'package:currency_converter/src/features/charts/presentation/charts_controller.dart';
import 'package:currency_converter/src/features/charts/widgets/chart_currency_tile.dart';
import 'package:currency_converter/src/features/charts/widgets/locked_pair_action_sheet.dart';
import 'package:currency_converter/src/features/charts/widgets/rewarded_ad_player.dart';
import 'package:currency_converter/src/shared/widgets/currency_section_header.dart';

class _RewardService implements RewardedAdService {
  final Completer<bool> result = Completer<bool>();
  RewardedAdCancellation? cancellation;
  int requests = 0;
  @override
  Future<bool> showRewardedAd({
    required String rewardType,
    RewardedAdCancellation? cancellation,
  }) {
    requests++;
    this.cancellation = cancellation;
    cancellation?.addListener(() {
      if (!result.isCompleted) result.complete(false);
    });
    return result.future;
  }
}

class _PurchaseService implements PurchaseService {
  final List<ProductType> requested = [];
  final result = Completer<bool>();
  @override
  Future<bool> purchase(ProductType product) async {
    requested.add(product);
    return result.future;
  }

  @override
  Future<void> restore() async {}
}

class _Repository implements ChartRepository {
  @override
  Future<HistoricalResult> getHistoricalRates({
    required String base,
    required String quote,
    required DateTime from,
    required DateTime to,
  }) async => HistoricalResult(
    status: HistoricalStatus.fresh,
    snapshot: HistoricalSnapshot(
      base: base,
      quote: quote,
      coveredFrom: from,
      coveredTo: to,
      savedAt: to,
      data: {from: .92, to: .95},
    ),
  );
}

class _Harness {
  final rewards = _RewardService();
  final purchases = _PurchaseService();
  final session = ChartViewerSession(requestOrientation: (_) async {});
  final controller = ChartsController(
    repository: _Repository(),
    allowCryptoCharts: true,
    range: ChartRange.oneYear,
  );
  late MonetizationController monetization;

  Future<void> launch(
    WidgetTester tester, {
    bool paid = false,
    double textScale = 1,
    Size size = const Size(640, 320),
    String language = 'en',
    bool dark = false,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({
      if (paid) 'entitlement_charts_pro_lifetime': true,
    });
    monetization = MonetizationController(
      await SharedPreferences.getInstance(),
      adService: rewards,
      purchaseService: purchases,
    );
    controller.load();
    await tester.pumpWidget(
      MaterialApp(
        theme: dark ? AppTheme.dark : AppTheme.light,
        locale: Locale(language),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => session.open(
                context,
                (_) => ChartsLandscapeScreen(
                  controller: controller,
                  monetization: monetization,
                  session: session,
                ),
              ),
              child: const Text('Open viewer'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open viewer'));
    await tester.pumpAndSettle();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox());
      controller.dispose();
      monetization.dispose();
      session.dispose();
    });
  }

  Future<void> choose(
    WidgetTester tester,
    String code, {
    bool base = false,
  }) async {
    await tester.tap(
      find.byKey(Key(base ? 'charts_pair_base' : 'charts_pair_quote')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), code);
    await tester.pumpAndSettle();
    final tile = find.byWidgetPredicate(
      (w) => w is ChartCurrencyTile && w.code == code,
    );
    if (tile.evaluate().isEmpty) {
      await tester.tap(find.byType(CurrencySectionHeader));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await tester.pumpAndSettle();
  }

  Future<void> watch(WidgetTester tester) async {
    final button = find
        .descendant(
          of: find.byType(LockedPairActionSheet),
          matching: find.byType(FilledButton),
        )
        .first;
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.byType(RewardedAdPlayer), findsOneWidget);
    expect(rewards.requests, 1);
  }
}

void main() {
  testWidgets(
    'reward from blocked quote applies exact pair and retains viewer period',
    (tester) async {
      final h = _Harness();
      await h.launch(tester);
      await h.choose(tester, 'CHF');
      expect(find.byType(LockedPairActionSheet), findsOneWidget);
      expect(h.controller.state.quote, 'EUR');
      await h.watch(tester);
      h.rewards.result.complete(true);
      await tester.pumpAndSettle();
      expect(find.byType(ChartsLandscapeScreen), findsOneWidget);
      expect(find.byType(RewardedAdPlayer), findsNothing);
      expect(h.controller.state.base, 'USD');
      expect(h.controller.state.quote, 'CHF');
      expect(h.controller.state.range, ChartRange.oneYear);
      expect(h.monetization.isChartPairUnlocked('USD', 'CHF'), true);
      expect(h.monetization.isChartPairUnlocked('USD', 'JPY'), false);
      expect(h.purchases.requested, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'cancel loading rewarded route cancels service and preserves old pair',
    (tester) async {
      final h = _Harness();
      await h.launch(tester);
      await h.choose(tester, 'CHF');
      await h.watch(tester);
      await tester.tap(
        find.descendant(
          of: find.byType(RewardedAdPlayer),
          matching: find.byType(TextButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(h.rewards.cancellation!.isCancelled, true);
      expect(h.controller.state.base, 'USD');
      expect(h.controller.state.quote, 'EUR');
      expect(h.monetization.isChartPairUnlocked('USD', 'CHF'), false);
      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await tester.pumpAndSettle();
      expect(find.byType(ChartsLandscapeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'failed reward at 640x320 scale2 stays dismissible and preserves selection',
    (tester) async {
      final h = _Harness();
      await h.launch(tester, textScale: 2);
      expect(tester.takeException(), isNull);
      await h.choose(tester, 'CHF');
      expect(tester.takeException(), isNull);
      await h.watch(tester);
      h.rewards.result.complete(false);
      await tester.pumpAndSettle();
      expect(h.controller.state.quote, 'EUR');
      expect(h.monetization.isChartPairUnlocked('USD', 'CHF'), false);
      expect(tester.takeException(), isNull);
      await tester.tap(
        find.descendant(
          of: find.byType(RewardedAdPlayer),
          matching: find.byType(TextButton),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await tester.pumpAndSettle();
      expect(find.byType(ChartsLandscapeScreen), findsOneWidget);
      expect(h.controller.state.range, ChartRange.oneYear);
    },
  );

  testWidgets(
    'Charts Pro purchase applies the blocked candidate without rewarded ad',
    (tester) async {
      final h = _Harness();
      await h.launch(tester);
      await h.choose(tester, 'CHF');
      final buy = find
          .descendant(
            of: find.byType(LockedPairActionSheet),
            matching: find.byType(FilledButton),
          )
          .last;
      await tester.ensureVisible(buy);
      await tester.tap(buy);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pump(const Duration(milliseconds: 900));
      await tester.pump();
      expect(h.purchases.requested, [ProductType.chartsPro]);
      expect(h.controller.state.quote, 'EUR');
      h.purchases.result.complete(true);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(h.monetization.hasChartsProLifetime, true);
      expect(h.controller.state.quote, 'CHF');
      expect(h.controller.state.range, ChartRange.oneYear);
      expect(h.rewards.requests, 0);
      expect(find.byType(ChartsLandscapeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Charts Pro selects both currencies and swaps without rewarded request',
    (tester) async {
      final h = _Harness();
      await h.launch(tester, paid: true, textScale: 2);
      await h.choose(tester, 'CHF', base: true);
      await h.choose(tester, 'JPY');
      expect(h.controller.state.base, 'CHF');
      expect(h.controller.state.quote, 'JPY');
      await tester.tap(find.byKey(const Key('charts_pair_swap')));
      await tester.pumpAndSettle();
      expect(h.controller.state.base, 'JPY');
      expect(h.controller.state.quote, 'CHF');
      expect(h.controller.state.range, ChartRange.oneYear);
      expect(h.rewards.requests, 0);
      expect(h.purchases.requested, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );
  for (final width in [568.0, 640.0]) {
    for (final scale in [1.0, 1.3, 2.0]) {
      for (final language in ['en', 'es', 'de', 'fr', 'it']) {
        final dark =
            (width.toInt() + (scale * 10).toInt() + language.codeUnitAt(0)) %
                2 ==
            0;
        testWidgets(
          'viewer/picker layout ${width.toInt()}x320 scale$scale $language ${dark ? "dark" : "light"}',
          (tester) async {
            final h = _Harness();
            await h.launch(
              tester,
              size: Size(width, 320),
              textScale: scale,
              language: language,
              dark: dark,
            );
            expect(tester.takeException(), isNull);
            for (final entry in {
              'charts_pair_base': 'USD',
              'charts_pair_quote': 'EUR',
            }.entries) {
              final text = find.descendant(
                of: find.byKey(Key(entry.key)),
                matching: find.text(entry.value),
              );
              expect(text, findsOneWidget);
              expect(
                tester.renderObject<RenderParagraph>(text).didExceedMaxLines,
                false,
                reason: 'the complete currency code must remain visible',
              );
            }
            final swap = tester.getSize(
              find.byKey(const Key('charts_pair_swap')),
            );
            expect(swap.width, greaterThanOrEqualTo(48));
            expect(swap.height, greaterThanOrEqualTo(48));
            final exit = tester.getRect(
              find.byKey(const Key('charts_collapse')),
            );
            expect(exit.left, greaterThanOrEqualTo(0));
            expect(exit.right, lessThanOrEqualTo(width));
            expect(exit.bottom, lessThanOrEqualTo(320));
            await h.choose(tester, 'CHF', base: true);
            expect(find.byType(LockedPairActionSheet), findsOneWidget);
            expect(h.controller.state.base, 'USD');
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
