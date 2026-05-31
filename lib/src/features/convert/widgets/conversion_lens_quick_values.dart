import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/localization/ui_copy.dart';
import '../../../core/theme/app_theme.dart';
import '../models/currency_quote.dart';
import 'conversion_lens_positioner.dart';

class ConversionLensQuickValues extends StatelessWidget {
  const ConversionLensQuickValues({
    required this.quote,
    required this.base,
    required this.amount,
    super.key,
  });

  final CurrencyQuote quote;
  final String base;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final values = _baseValues(amount);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          quickBaseAmountsLabel(context),
          style: AppTheme.sectionLabelStyle(context),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: colors.bg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: values
                .map(
                  (value) => LensValueRow(
                    leading: formatLensValue(value, base),
                    trailing:
                        '${formatLensValue(value * quote.rate, quote.code)} ${quote.code}',
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  List<double> _baseValues(double currentAmount) {
    final values = <double>{1, 10, 50, 100, 1000};
    if (currentAmount > 0) values.add(currentAmount);
    final sorted = values.toList()..sort();
    return sorted;
  }
}

class LensValueRow extends StatelessWidget {
  const LensValueRow({
    required this.leading,
    required this.trailing,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String leading;
  final String trailing;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              leading,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
            ),
          ),
          Expanded(
            child: Text(
              trailing,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: colors.text,
              ),
            ),
          ),
          if (actionLabel != null) ...<Widget>[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
