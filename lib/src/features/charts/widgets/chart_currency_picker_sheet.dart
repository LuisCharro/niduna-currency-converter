import 'package:flutter/material.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/theme/app_theme.dart';
import '../../convert/widgets/ad_banner_placeholder.dart';

class ChartCurrencyPickerSheet extends StatefulWidget {
  const ChartCurrencyPickerSheet({
    required this.title,
    required this.selectedCode,
    required this.adsEnabled,
    required this.canSelectAnyPair,
    super.key,
  });

  final String title;
  final String selectedCode;
  final bool adsEnabled;
  final bool canSelectAnyPair;

  @override
  State<ChartCurrencyPickerSheet> createState() => _ChartCurrencyPickerSheetState();
}

class _ChartCurrencyPickerSheetState extends State<ChartCurrencyPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final currencies = supportedCurrencies.where(_matches).toList();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
        child: Column(
          children: <Widget>[
            Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => setState(() => _query = value.trim().toUpperCase()),
              decoration: InputDecoration(
                hintText: 'Search code or currency name',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                filled: true,
                fillColor: AppTheme.container.withValues(alpha: .55),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  borderSide: BorderSide(color: AppTheme.border),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (widget.adsEnabled) ...[
              const AdBannerPlaceholder(),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: ListView.separated(
                itemCount: currencies.length,
                separatorBuilder: (context, index) =>
                    Divider(height: 1, color: AppTheme.border),
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  final isSelected = currency.code == widget.selectedCode;
                  final isFreePair = currency.code == 'USD' || currency.code == 'EUR';
                  final isEnabled = widget.canSelectAnyPair || isFreePair;
                  return ListTile(
                    enabled: isEnabled,
                    onTap: isEnabled
                        ? () => Navigator.of(context).pop(currency.code)
                        : null,
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.container,
                      child: Text(currency.symbol),
                    ),
                    title: Text(currency.code),
                    subtitle: Text(currency.name),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: AppTheme.primary)
                        : isEnabled
                        ? Icon(Icons.chevron_right, color: AppTheme.subtle)
                        : Icon(Icons.lock_outline, color: AppTheme.muted),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _matches(SupportedCurrency currency) {
    if (_query.isEmpty) return true;
    final code = currency.code.toUpperCase();
    final name = currency.name.toUpperCase();
    return code.contains(_query) || name.contains(_query);
  }
}
