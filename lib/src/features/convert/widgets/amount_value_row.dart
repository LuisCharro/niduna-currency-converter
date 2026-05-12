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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: widget.onAmountChanged,
            decoration: const InputDecoration.collapsed(hintText: '0.00'),
            style: const TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              height: 1.05,
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: widget.onBaseTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.container,
              borderRadius: BorderRadius.circular(AppTheme.pillRadius),
              border: Border.all(color: AppTheme.border.withValues(alpha: .22)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CurrencyFlagIcon(
                  code: widget.base,
                  symbol: currency.symbol,
                  radius: 12,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.base,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
