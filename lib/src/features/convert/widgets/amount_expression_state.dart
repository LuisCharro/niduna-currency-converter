import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../core/calculator/simple_expression_eval.dart';

mixin AmountExpressionState<T extends StatefulWidget> on State<T> {
  List<String> _expressionParts = [];
  bool _isExpression = false;

  bool get isExpression => _isExpression;

  void handleOperator(String amount, VoidCallback setAmount) {
    HapticFeedback.selectionClick();
    if (amount.isEmpty) return;
    _expressionParts.add(amount);
    _expressionParts.add('+');
    _isExpression = true;
    setAmount();
  }

  String? handleEquals(String amount) {
    HapticFeedback.mediumImpact();
    _expressionParts.add(amount);
    final expr = _expressionParts.join('');
    final result = evaluateExpression(expr);
    _expressionParts = [];
    _isExpression = false;
    return result?.toStringAsFixed(2);
  }

  void resetExpression() {
    _expressionParts = [];
    _isExpression = false;
  }
}
