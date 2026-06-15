import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../core/calculator/simple_expression_eval.dart';

/// Calculator state for the amount sheet: accumulates a left-to-right
/// expression (+ − × ÷) and evaluates it on equals. Pure UI-state logic;
/// arithmetic lives in [evaluateExpression].
mixin AmountExpressionState<T extends StatefulWidget> on State<T> {
  final List<String> _parts = <String>[];
  bool _isExpression = false;

  bool get isExpression => _isExpression;

  static const _operators = <String>{'+', '-', '*', '/'};

  /// Human-readable running expression, e.g. "100 + 50 × 2", including the
  /// operand currently being entered. Empty when no expression is in progress.
  String expressionPreview(String currentAmount) {
    if (_parts.isEmpty) return '';
    final tokens = <String>[
      ..._parts,
      if (currentAmount.isNotEmpty) currentAmount,
    ];
    return tokens.map(_prettyToken).join(' ');
  }

  String _prettyToken(String token) => switch (token) {
        '*' => '×',
        '-' => '−',
        _ => token, // '/' and '+' display as-is
      };

  /// Append [op] after the current [amount]. [onCleared] should reset the
  /// live entry so the next operand starts fresh.
  void handleOperator(String amount, String op, VoidCallback onCleared) {
    HapticFeedback.selectionClick();
    if (amount.isEmpty && _parts.isEmpty) return; // nothing to operate on yet
    if (amount.isNotEmpty) _parts.add(amount);
    // Tapping a second operator back-to-back replaces the pending one.
    if (_parts.isNotEmpty && _operators.contains(_parts.last)) {
      _parts.removeLast();
    }
    _parts.add(op);
    _isExpression = true;
    onCleared();
  }

  /// Evaluate the expression (with the final [amount] appended). Returns the
  /// formatted result, or null when there is nothing/invalid to evaluate
  /// (e.g. division by zero).
  String? handleEquals(String amount) {
    HapticFeedback.mediumImpact();
    if (amount.isNotEmpty) _parts.add(amount);
    if (_parts.isEmpty) {
      _isExpression = false;
      return null;
    }
    final result = evaluateExpression(_parts.join(''));
    _parts.clear();
    _isExpression = false;
    return result?.toStringAsFixed(2);
  }

  void resetExpression() {
    _parts.clear();
    _isExpression = false;
  }
}
