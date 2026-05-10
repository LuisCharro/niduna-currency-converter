import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/currency_flag_icon.dart';
import '../models/currency_quote.dart';

class QuoteIdentity extends StatelessWidget {
  const QuoteIdentity({required this.quote, super.key});

  final CurrencyQuote quote;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CurrencyFlagIcon(
          code: quote.code,
          symbol: quote.symbol,
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              quote.code,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              quote.name,
              style: const TextStyle(
                color: AppTheme.muted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
