import 'package:flutter/material.dart';

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
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              quote.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
            Text(
              quote.code,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8E8E93),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
