import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          children: <Widget>[
            Text(
              widget.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  final currency = supportedCurrencies[index];
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
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemCount: supportedCurrencies.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggle(String code) {
    if (code == widget.base) {
      return;
    }
    setState(() {
      if (_selectedCodes.contains(code)) {
        if (_selectedCodes.length == 1) {
          return;
        }
        _selectedCodes.remove(code);
      } else {
        _selectedCodes.add(code);
      }
    });
    widget.onToggleCode(code);
  }
}
