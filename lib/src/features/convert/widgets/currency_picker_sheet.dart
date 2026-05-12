import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_theme.dart';
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
    final currencies = supportedCurrencies.where(_matchesQuery).toList();
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
              _PickerHeader(title: widget.title),
              const SizedBox(height: 12),
              _SearchField(
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

class _PickerHeader extends StatelessWidget {
  const _PickerHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const SizedBox(width: 48),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.check_circle_rounded, color: AppTheme.primary),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Currency, country, or code',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: AppTheme.container,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.pillRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
