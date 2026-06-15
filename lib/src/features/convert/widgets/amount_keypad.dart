import 'package:flutter/material.dart';

import 'amount_op_key.dart';
import 'digit_grid.dart';

class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    required this.onDigit,
    required this.onDecimal,
    required this.onBackspace,
    this.onOperator,
    this.onEquals,
    super.key,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDecimal;
  final VoidCallback onBackspace;
  final void Function(String)? onOperator;
  final VoidCallback? onEquals;

  bool get _hasOperators => onOperator != null && onEquals != null;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      if (_hasOperators) ...<Widget>[
        SizedBox(
          height: 48,
          child: Row(
            children: <Widget>[
              AmountOpKey(label: '+', onTap: () => onOperator!('+')),
              const SizedBox(width: 10),
              AmountOpKey(label: '−', onTap: () => onOperator!('-')),
              const SizedBox(width: 10),
              AmountOpKey(label: '×', onTap: () => onOperator!('*')),
              const SizedBox(width: 10),
              AmountOpKey(label: '/', onTap: () => onOperator!('/')),
              const SizedBox(width: 10),
              AmountOpKey(label: '=', onTap: onEquals!, bgColor: true),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
      DigitGrid(onDigit: onDigit, onDecimal: onDecimal, onBackspace: onBackspace),
    ];

    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }
}
