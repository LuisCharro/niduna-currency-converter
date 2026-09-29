import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/localization/ui_copy.dart';
import '../../../core/theme/app_colors.dart';
import '../models/currency_quote.dart';
import 'conversion_lens_formatting.dart';

/// Big "$a $base = $c $quote" headline shown at the top of the Conversion
/// Lens, with a raw "1 base = ... quote" rate line and a copy-to-clipboard
/// action.
Widget buildLensHero(
  BuildContext context,
  CurrencyQuote quote,
  String base,
  double amount, {
  int decimalPlaces = lensDefaultDecimalPlaces,
}) {
  final colors = AppColors.of(context);
  final a = formatHeroBase(amount, base);
  final c = formatHeroConverted(
    amount * quote.rate,
    quote.code,
    decimalPlaces: decimalPlaces,
  );
  final copy = '$a $base = $c ${quote.code}';
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colors.container,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '$a $base = $c ${quote.code}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.3,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '1 $base = ${formatLensRaw(quote.rate, quote.code)} ${quote.code}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: colors.muted,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          key: const Key('conversion_lens_copy_button'),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: copy));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(copiedConversionMessage(context, copy))),
              );
            }
          },
          tooltip: copyConversionTooltip(context),
          icon: const Icon(Icons.content_copy_rounded, size: 20),
          visualDensity: VisualDensity.compact,
        ),
      ],
    ),
  );
}
