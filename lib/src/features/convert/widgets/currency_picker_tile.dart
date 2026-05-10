import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/currency_flag_icon.dart';

class CurrencyPickerTile extends StatelessWidget {
  const CurrencyPickerTile({
    required this.currency,
    required this.isBase,
    required this.isSelected,
    required this.selectBaseMode,
    required this.onTap,
    super.key,
  });

  final SupportedCurrency currency;
  final bool isBase;
  final bool isSelected;
  final bool selectBaseMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CurrencyFlagIcon(
        code: currency.code,
        symbol: currency.symbol,
        radius: 16,
      ),
      title: Text(currency.name),
      subtitle: Text(currency.code),
      trailing: Icon(_icon, color: _color),
      enabled: selectBaseMode || !isBase,
      onTap: onTap,
    );
  }

  IconData get _icon {
    if (selectBaseMode) {
      return isBase ? Icons.radio_button_checked : Icons.radio_button_unchecked;
    }
    return isSelected ? Icons.check_circle : Icons.circle_outlined;
  }

  Color get _color {
    return isBase || isSelected ? AppTheme.primary : AppTheme.subtle;
  }
}
