import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/currency/supported_currencies.dart';
import 'amount_done_button.dart';
import 'amount_expression_state.dart';
import 'amount_input_header.dart';
import 'amount_sheet_handle.dart';
import 'amount_keypad.dart';
import 'amount_presets.dart';

class AmountInputSheet extends StatefulWidget {
  const AmountInputSheet({
    required this.amountText,
    required this.base,
    super.key,
  });

  final String amountText;
  final String base;

  @override
  State<AmountInputSheet> createState() => _AmountInputSheetState();
}

class _AmountInputSheetState extends State<AmountInputSheet>
    with AmountExpressionState {
  late String _amount = widget.amountText;
  bool _shouldReplace = true;

  bool get _isDirty => _amount != widget.amountText || isExpression;

  void _setAmount(String value, {bool replaceNext = false}) {
    final next = value == '0' ? '' : value;
    setState(() {
      _amount = next;
      _shouldReplace = replaceNext;
    });
  }

  void _handleDigit(String digit) {
    HapticFeedback.selectionClick();
    if (_shouldReplace || _amount == '0') {
      _setAmount(digit);
      return;
    }
    _setAmount('$_amount$digit');
  }

  void _handleDecimal() {
    HapticFeedback.selectionClick();
    if (_amount.contains('.')) return;
    _setAmount(_shouldReplace || _amount.isEmpty ? '0.' : '$_amount.');
  }

  void _handleBackspace() {
    HapticFeedback.selectionClick();
    if (_amount.isEmpty || _shouldReplace) {
      resetExpression();
      _setAmount('');
      return;
    }
    _setAmount(_amount.substring(0, _amount.length - 1));
  }

  void _handleOperator(String op) {
    handleOperator(_amount, () => setState(() {
      _amount = '';
      _shouldReplace = true;
    }));
  }

  void _handleEquals() {
    final result = handleEquals(_amount);
    setState(() {
      _amount = result ?? 'Error';
      _shouldReplace = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = currencyByCode(widget.base);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const AmountSheetHandle(),
            const SizedBox(height: 12),
            AmountInputHeader(
              amount: _amount,
              currency: currency,
              base: widget.base,
              onCancel: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 14),
            AmountPresets(
              selectedValue: _amount,
              onSelected: (value) {
                HapticFeedback.selectionClick();
                _setAmount(value);
              },
            ),
            const SizedBox(height: 14),
            AmountKeypad(
              onDigit: _handleDigit,
              onDecimal: _handleDecimal,
              onBackspace: _handleBackspace,
              onOperator: _handleOperator,
              onEquals: _handleEquals,
            ),
            const SizedBox(height: 14),
            AmountDoneButton(isDirty: _isDirty, onTap: () => Navigator.of(context).pop(_amount)),
          ],
        ),
      ),
    );
  }
}
