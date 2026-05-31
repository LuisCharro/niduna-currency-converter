import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/currency/supported_currencies.dart';
import '../../../core/localization/ui_copy.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/currency_quote.dart';
import 'conversion_lens_positioner.dart';
import 'conversion_lens_quick_values.dart' show LensValueRow;

class ConversionLensReverseTarget extends StatelessWidget {
  const ConversionLensReverseTarget({
    required this.quote,
    required this.base,
    required this.onAmountChanged,
    super.key,
  });

  final CurrencyQuote quote;
  final String base;
  final ValueChanged<String> onAmountChanged;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final targets = _reverseTargets();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          reverseTargetsLabel(context),
          style: AppTheme.sectionLabelStyle(context),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: colors.bg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: targets
                .map(
                  (target) => LensValueRow(
                    leading: formatLensValue(target, quote.code),
                    trailing:
                        '${formatLensValue(target / quote.rate, base)} $base',
                    actionLabel: useActionLabel(context),
                    onAction: () {
                      HapticFeedback.selectionClick();
                      onAmountChanged(formatLensInput(target / quote.rate));
                      Navigator.of(context).pop();
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  List<double> _reverseTargets() {
    if (quote.code == 'BTC') return <double>[0.001, 0.01, 0.1];
    if (quote.code == 'USDT' || quote.code == 'USDC' || quote.code == 'DOGE') {
      return <double>[10, 50, 100];
    }
    if (isCryptoCurrency(quote.code)) return <double>[0.01, 0.1, 1];
    return <double>[10, 50, 100];
  }
}
