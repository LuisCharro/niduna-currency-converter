import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations_safe.dart';
import '../../../shared/widgets/currency_flag_icon.dart';

class BaseCurrencyPicker extends StatefulWidget {
  const BaseCurrencyPicker({required this.currentBase, super.key});

  final String currentBase;

  @override
  State<BaseCurrencyPicker> createState() => _BaseCurrencyPickerState();
}

class _BaseCurrencyPickerState extends State<BaseCurrencyPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final currencies = supportedCurrencies.where((c) {
      if (_query.isEmpty) return true;
      return c.code.toUpperCase().contains(_query) ||
          c.name.toUpperCase().contains(_query);
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 12, 8),
          child: Row(
            children: <Widget>[
              Text(
                loc.selectBaseCurrency,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.close, size: 18, color: AppColors.of(context).muted),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v.trim().toUpperCase()),
            decoration: InputDecoration(
              hintText: loc.searchCodeOrName,
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              filled: true,
              fillColor: AppColors.of(context).container.withValues(alpha: .55),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radius),
                borderSide: BorderSide(color: AppColors.of(context).border),
              ),
            ),
          ),
        ),
        Flexible(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            shrinkWrap: true,
            itemCount: currencies.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: AppColors.of(context).border),
            itemBuilder: (context, i) {
              final c = currencies[i];
              final selected = c.code == widget.currentBase;
              return ListTile(
                onTap: selected
                    ? null
                    : () => Navigator.of(context).pop(c.code),
                leading: CurrencyFlagIcon(
                  code: c.code,
                  symbol: c.symbol,
                  radius: 16,
                ),
                title: Text(
                  c.code,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.of(context).muted : AppColors.of(context).text,
                  ),
                ),
                subtitle: Text(c.name),
                trailing: selected
                    ? Icon(Icons.check_circle, color: AppColors.of(context).primary)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
}
