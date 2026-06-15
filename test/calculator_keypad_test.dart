import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/features/convert/widgets/amount_input_sheet.dart';
import 'package:currency_converter/src/features/convert/widgets/amount_key.dart';
import 'package:currency_converter/src/features/convert/widgets/amount_op_key.dart';

// End-to-end test for the in-amount calculator. Taps the real keypad so each
// operator is exercised through the UI — the original bug was that −, ×, ÷ all
// behaved as + because the operator was dropped before reaching the evaluator.
void main() {
  Future<void> pumpSheet(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AmountInputSheet(amountText: '100.00', base: 'USD'),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapDigit(WidgetTester tester, String d) async {
    await tester.tap(find.widgetWithText(AmountKey, d));
    await tester.pump();
  }

  Future<void> tapOp(WidgetTester tester, String op) async {
    await tester.tap(find.widgetWithText(AmountOpKey, op));
    await tester.pump();
  }

  Future<void> tapEquals(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(AmountOpKey, '='));
    await tester.pump();
  }

  Future<void> enter(WidgetTester tester, String digits) async {
    for (final ch in digits.split('')) {
      await tapDigit(tester, ch);
    }
  }

  // op symbol -> (a, b, expected display fragment)
  final cases = <String, ({String a, String b, String result})>{
    '+': (a: '100', b: '50', result: '150.00'),
    '−': (a: '100', b: '30', result: '70.00'),
    '×': (a: '12', b: '5', result: '60.00'),
    '/': (a: '100', b: '4', result: '25.00'),
  };

  cases.forEach((op, c) {
    testWidgets('$op evaluates ${c.a} $op ${c.b} = ${c.result}',
        (tester) async {
      await pumpSheet(tester);
      await enter(tester, c.a);
      await tapOp(tester, op);
      await enter(tester, c.b);
      await tapEquals(tester);
      await tester.pumpAndSettle();

      expect(find.textContaining(c.result), findsOneWidget);
    });
  });

  testWidgets('chains left-to-right: 10 + 5 × 2 = 30.00', (tester) async {
    await pumpSheet(tester);
    await enter(tester, '10');
    await tapOp(tester, '+');
    await enter(tester, '5');
    await tapOp(tester, '×');
    await enter(tester, '2');
    await tapEquals(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('30.00'), findsOneWidget);
  });

  testWidgets('shows the running expression while building', (tester) async {
    await pumpSheet(tester);
    await enter(tester, '100');
    await tapOp(tester, '×');
    await enter(tester, '2');

    expect(find.textContaining('100 × 2'), findsOneWidget);
  });

  testWidgets('a second operator replaces the pending one', (tester) async {
    await pumpSheet(tester);
    await enter(tester, '100');
    await tapOp(tester, '+');
    await tapOp(tester, '×'); // replaces the '+'
    await enter(tester, '2');
    await tapEquals(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('200.00'), findsOneWidget);
  });
}
