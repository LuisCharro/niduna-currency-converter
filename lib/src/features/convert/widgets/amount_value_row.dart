import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class AmountValueRow extends StatelessWidget {
  const AmountValueRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const Expanded(
          child: Text(
            '100.00',
            style: TextStyle(
              fontSize: 46,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.2,
            ),
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: () {},
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          label: const Text(
            'USD',
            style: TextStyle(fontWeight: FontWeight.w800),
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
