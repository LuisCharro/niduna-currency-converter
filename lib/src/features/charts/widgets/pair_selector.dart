import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_theme.dart';

class PairSelector extends StatelessWidget {
  const PairSelector({
    required this.base,
    required this.quote,
    required this.onPairChanged,
    super.key,
  });

  final String base;
  final String quote;
  final void Function(String base, String quote) onPairChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: AppTheme.border.withValues(alpha: .5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: '$base-$quote',
          isDense: true,
          icon: Icon(Icons.arrow_drop_down, color: AppTheme.muted, size: 22),
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.text),
          dropdownColor: AppTheme.card,
          items: _buildItems(),
          onChanged: (value) {
            if (value == null) return;
            final parts = value.split('-');
            onPairChanged(parts[0], parts[1]);
          },
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildItems() {
    final bases = ['USD', 'EUR', 'GBP', 'CHF'];
    final items = <DropdownMenuItem<String>>[];

    for (final b in bases) {
      for (final q in supportedCurrencies) {
        if (q.code == b) continue;
        items.add(DropdownMenuItem(
          value: '$b-${q.code}',
          child: Text('$b \u2192 ${q.code}', style: TextStyle(fontSize: 15)),
        ));
      }
    }
    return items;
  }
}