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
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      leading: CurrencyFlagIcon(
        code: currency.code,
        symbol: currency.symbol,
        radius: 20,
      ),
      title: Text(
        currency.name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        _subtitle,
        style: const TextStyle(
          color: AppTheme.muted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: .3,
        ),
      ),
      trailing: Icon(_icon, color: _color, size: 26),
      enabled: selectBaseMode || !isBase,
      minLeadingWidth: 44,
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

  String get _subtitle {
    if (selectBaseMode) return currency.code;
    if (isBase) return '${currency.code} · base currency';
    if (isSelected) return '${currency.code} · shown now';
    return '${currency.code} · tap to add';
  }
}
