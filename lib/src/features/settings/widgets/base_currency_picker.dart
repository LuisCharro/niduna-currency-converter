import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/localization/ui_copy.dart';
import '../../../../l10n/app_localizations_safe.dart';
import '../../../shared/widgets/sectioned_currency_picker.dart';
import '../../../shared/widgets/currency_picker/currency_picker_tile.dart';

/// Single-select currency picker for the Settings "Default base currency"
/// row. Built on the same shared sheet as Convert's and Charts' pickers.
class BaseCurrencyPicker extends StatelessWidget {
  const BaseCurrencyPicker({required this.currentBase, super.key});

  final String currentBase;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    return SectionedCurrencyPicker(
      title: loc.selectBaseCurrency,
      subtitle: currentBaseSubtitle(context, currentBase),
      currencies: supportedCurrencies,
      highlightedCodes: [currentBase],
      expandSectionsForCodes: [currentBase],
      tileBuilder: (context, currency) {
        final isBase = currency.code == currentBase;
        return CurrencyPickerTile(
          currency: currency,
          isBase: isBase,
          isSelected: false,
          selectBaseMode: true,
          onTap: () => Navigator.of(context).pop(currency.code),
        );
      },
    );
  }
}
