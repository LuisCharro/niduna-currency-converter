import 'package:flutter/material.dart';

import 'amount_key.dart';

class DigitGrid extends StatelessWidget {
  const DigitGrid({
    required this.onDigit,
    required this.onDecimal,
    required this.onBackspace,
    super.key,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDecimal;
  final VoidCallback onBackspace;

  static const _digits = <String>['1', '2', '3', '4', '5', '6', '7', '8', '9'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final keyWidth = (constraints.maxWidth - 20) / 3;
        return GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: keyWidth / 54,
          children: <Widget>[
            for (final d in _digits) AmountKey(label: d, onTap: () => onDigit(d)),
            AmountKey(label: '.', onTap: onDecimal),
            AmountKey(label: '0', onTap: () => onDigit('0')),
            AmountKey(icon: Icons.backspace_outlined, onTap: onBackspace),
          ],
        );
      },
    );
  }
}
