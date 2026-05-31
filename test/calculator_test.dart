import 'package:flutter_test/flutter_test.dart';

import 'package:currency_converter/src/core/calculator/simple_expression_eval.dart';

void main() {
  test('basic add', () {
    expect(evaluateExpression('100+50'), 150.0);
  });

  test('basic subtract', () {
    expect(evaluateExpression('100-30'), 70.0);
  });

  test('basic multiply', () {
    expect(evaluateExpression('12*5'), 60.0);
  });

  test('basic divide', () {
    expect(evaluateExpression('100/4'), 25.0);
  });

  test('division by zero returns null', () {
    expect(evaluateExpression('10/0'), isNull);
  });

  test('left-to-right chaining', () {
    expect(evaluateExpression('10+5*2-3'), 27.0);
  });

  test('decimal numbers', () {
    expect(evaluateExpression('10.5+2.3'), closeTo(12.8, 0.01));
  });

  test('empty string returns null', () {
    expect(evaluateExpression(''), isNull);
  });

  test('single number', () {
    expect(evaluateExpression('42'), 42.0);
  });

  test('negative intermediate result', () {
    expect(evaluateExpression('5-10'), -5.0);
  });

  test('trailing operator ignored', () {
    expect(evaluateExpression('10+'), 10.0);
  });

  test('multiple digit numbers', () {
    expect(evaluateExpression('100+200'), 300.0);
  });
}
