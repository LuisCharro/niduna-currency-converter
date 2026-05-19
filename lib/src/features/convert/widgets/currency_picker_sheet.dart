import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/currency_picker_chrome.dart';
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
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final currencies = _visibleCurrencies();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .84,
      minChildSize: .42,
      maxChildSize: .92,
      builder: (context, scrollController) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          child: Column(
            children: <Widget>[
              CurrencyPickerHeader(title: widget.title, subtitle: _subtitle),
              const SizedBox(height: 12),
              CurrencyPickerSearchField(
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  itemBuilder: (context, index) {
                    final currency = currencies[index];
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
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: AppTheme.border.withValues(alpha: .15),
                  ),
                  itemCount: currencies.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _matchesQuery(SupportedCurrency currency) {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return currency.code.toLowerCase().contains(normalized) ||
        currency.name.toLowerCase().contains(normalized);
  }

  List<SupportedCurrency> _visibleCurrencies() {
    final currencies = (widget.selectBaseMode
            ? supportedFiatCurrencies
            : allSupportedCurrencies)
        .where(_matchesQuery)
        .toList();
    if (widget.selectBaseMode) return currencies;
    currencies.sort((a, b) {
      final aRank = _rank(a.code);
      final bRank = _rank(b.code);
      if (aRank != bRank) return aRank.compareTo(bRank);
      return a.code.compareTo(b.code);
    });
    return currencies;
  }

  int _rank(String code) {
    if (code == widget.base) return 0;
    if (_selectedCodes.contains(code)) return 1;
    return 2;
  }

  String get _subtitle {
    if (widget.selectBaseMode) return 'Current base ${widget.base}';
    return '${_selectedCodes.length} shown · ${widget.base} base';
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
