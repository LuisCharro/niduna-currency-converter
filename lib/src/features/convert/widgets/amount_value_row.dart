import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/currency_flag_icon.dart';

class AmountValueRow extends StatefulWidget {
  const AmountValueRow({
    required this.amountText,
    required this.base,
    required this.onAmountChanged,
    required this.onBaseTap,
    super.key,
  });

  final String amountText;
  final String base;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onBaseTap;

  @override
  State<AmountValueRow> createState() => _AmountValueRowState();
}

class _AmountValueRowState extends State<AmountValueRow> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.amountText,
  );

  @override
  void didUpdateWidget(covariant AmountValueRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.amountText != oldWidget.amountText &&
        widget.amountText != _controller.text) {
      _controller.text = widget.amountText;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currency = currencyByCode(widget.base);
    return Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: widget.onAmountChanged,
                decoration:
                    const InputDecoration.collapsed(hintText: '0.00'),
                style: TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.2,
                ),
              ),
            ),
            FilledButton.tonalIcon(
              onPressed: widget.onBaseTap,
              icon: CurrencyFlagIcon(
                code: widget.base,
                symbol: currency.symbol,
                radius: 10,
              ),
              label: Text(
                widget.base,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.containerHigh,
                foregroundColor: AppTheme.text,
              ),
            ),
      ],
    );
  }
}
