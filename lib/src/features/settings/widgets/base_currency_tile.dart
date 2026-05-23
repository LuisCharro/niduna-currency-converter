import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_colors.dart';
import '../settings_controller.dart';
import 'base_currency_picker.dart';
import '../../../shared/widgets/settings_tile.dart';

class BaseCurrencyTile extends StatelessWidget {
  const BaseCurrencyTile({required this.controller, super.key});

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    final currency = currencyByCode(controller.preferences.defaultBaseCurrency);
    return SettingsTile(
      title: 'Default base currency',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            '${currency.symbol} ${currency.code}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.of(context).primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: AppColors.of(context).subtle, size: 20),
        ],
      ),
      onTap: () async {
        final selected = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => BaseCurrencyPicker(
            currentBase: controller.preferences.defaultBaseCurrency,
          ),
        );
        if (selected != null) {
          if (!context.mounted) return;
          controller.pickBaseCurrency(context, selected);
        }
      },
    );
  }
}
