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
}
