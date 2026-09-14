import 'package:flutter/material.dart';

import '../../../core/localization/ui_copy.dart';
import '../../../core/currency/supported_currencies.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../shared/widgets/sectioned_currency_picker.dart';
import 'currency_picker_tile.dart';

class CurrencyPickerSheet extends StatefulWidget {
  const CurrencyPickerSheet({
    required this.title,
    required this.base,
    required this.selectedCodes,
    required this.onSelectBase,
    required this.onToggleCode,
    required this.selectBaseMode,
    super.key,
  });

  final String title;
  final String base;
  final List<String> selectedCodes;
  final ValueChanged<String> onSelectBase;
  final ValueChanged<String> onToggleCode;
  final bool selectBaseMode;

  @override
  State<CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<CurrencyPickerSheet> {
  late final Set<String> _selectedCodes = widget.selectedCodes.toSet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SectionedCurrencyPicker(
      title: widget.title,
      subtitle: _subtitle(l10n),
      currencies: allSupportedCurrencies,
      itemComparator: _compareItems,
      tileBuilder: (context, currency) {
        final isBase = currency.code == widget.base;
        final isSelected = _selectedCodes.contains(currency.code);
        return CurrencyPickerTile(
          currency: currency,
          isBase: isBase,
          isSelected: isSelected,
          selectBaseMode: widget.selectBaseMode,
          onTap: () {
            if (widget.selectBaseMode) {
              widget.onSelectBase(currency.code);
            } else {
              _toggle(currency.code);
            }
          },
        );
      },
    );
  }

  int _compareItems(SupportedCurrency a, SupportedCurrency b) {
    final aRank = _itemRank(a.code);
    final bRank = _itemRank(b.code);
    if (aRank != bRank) return aRank.compareTo(bRank);
    return a.code.compareTo(b.code);
  }

  int _itemRank(String code) {
    if (code == widget.base) return 0;
    if (_selectedCodes.contains(code)) return 1;
    return 2;
  }

  String _subtitle(AppLocalizations? l10n) {
    if (widget.selectBaseMode) {
      return currentBaseSubtitle(context, widget.base);
    }
    return shownBaseSubtitle(context, _selectedCodes.length, widget.base);
  }

  void _toggle(String code) {
    if (code == widget.base) return;
    setState(() {
      if (_selectedCodes.contains(code)) {
        if (_selectedCodes.length == 1) return;
        _selectedCodes.remove(code);
      } else {
        _selectedCodes.add(code);
      }
    });
    widget.onToggleCode(code);
  }
}
