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
    expect(find.bySemanticsLabel('EUR'), findsNothing);
    expect(find.bySemanticsLabel('€'), findsNothing);
    handle.dispose();
  });

  testWidgets('CurrencyFlagIcon fallback (no asset) is excluded from semantics',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: CurrencyFlagIcon(code: 'XXX', symbol: 'X', radius: 18),
      ),
    ));
    // 'XXX' has no asset, so the widget renders Text(symbol); without
    // ExcludeSemantics this label would be exposed to the AT tree.
    expect(find.bySemanticsLabel('X'), findsNothing);
    handle.dispose();
  });
}
