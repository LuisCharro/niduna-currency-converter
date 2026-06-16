import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:currency_converter/src/core/theme/app_theme.dart';
import 'package:currency_converter/l10n/app_localizations.dart';
import 'package:currency_converter/src/features/convert/models/currency_quote.dart';
import 'package:currency_converter/src/features/convert/widgets/currency_rate_row.dart';

void main() {
  testWidgets('currency row exposes an open-conversion button label', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: CurrencyRateRow(
          quote: const CurrencyQuote(
            '€',
            'EUR',
            'Euro',
            '1.08',
            '1 USD = 1.08 EUR',
            rate: 1.08,
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(find.byType(CurrencyRateRow)),
      matchesSemantics(
        hasTapAction: true,
        hasFocusAction: true,
        isFocusable: true,
        onTapHint: 'Open EUR conversion',
      ),
    );
    handle.dispose();
  });
}
