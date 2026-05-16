import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_theme.dart';
import 'amount_input_header.dart';
import 'amount_keypad.dart';
import 'amount_presets.dart';

class AmountInputSheet extends StatefulWidget {
  const AmountInputSheet({
    required this.amountText,
    required this.base,
    required this.onAmountChanged,
    super.key,
  });

  final String amountText;
  final String base;
  final ValueChanged<String> onAmountChanged;

  @override
  State<AmountInputSheet> createState() => _AmountInputSheetState();
}

class _AmountInputSheetState extends State<AmountInputSheet> {
  late String _amount = widget.amountText;
  bool _shouldReplace = true;

  void _setAmount(String value, {bool replaceNext = false}) {
    final next = value == '0' ? '' : value;
    setState(() {
      _amount = next;
      _shouldReplace = replaceNext;
    });
    widget.onAmountChanged(next);
  }

  void _handleDigit(String digit) {
    if (_shouldReplace || _amount == '0') {
      _setAmount(digit);
      return;
    }
    _setAmount('$_amount$digit');
  }

  void _handleDecimal() {
    if (_amount.contains('.')) return;
    _setAmount(_shouldReplace || _amount.isEmpty ? '0.' : '$_amount.');
  }

  void _handleBackspace() {
    if (_amount.isEmpty || _shouldReplace) {
      _setAmount('');
      return;
    }
    _setAmount(_amount.substring(0, _amount.length - 1));
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
            ),
            const SizedBox(height: 16),
            AmountPresets(onSelected: (value) => _setAmount(value)),
            const SizedBox(height: 14),
            AmountKeypad(
              onDigit: _handleDigit,
              onDecimal: _handleDecimal,
              onBackspace: _handleBackspace,
            ),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.card,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
