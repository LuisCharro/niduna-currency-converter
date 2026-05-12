import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/currency_flag_icon.dart';
import '../models/currency_quote.dart';

class QuoteIdentity extends StatelessWidget {
  const QuoteIdentity({required this.quote, this.isActive = false, super.key});

  final CurrencyQuote quote;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.trendUp.withValues(alpha: .18),
              width: 1,
            ),
          ),
          child: Center(
            child: CurrencyFlagIcon(
              code: quote.code,
              symbol: quote.symbol,
              radius: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                quote.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              Text(
                quote.code,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.muted,
                  letterSpacing: 0.3,
                ),
              ),
              if (isActive)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Set as base',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
