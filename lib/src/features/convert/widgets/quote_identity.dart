import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/currency_flag_icon.dart';
import '../models/currency_quote.dart';

class QuoteIdentity extends StatelessWidget {
  const QuoteIdentity({required this.quote, this.isActive = false, super.key});

  final CurrencyQuote quote;
  final bool isActive;

  static const double _flagSize = 36;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: _flagSize,
          height: _flagSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.border.withValues(alpha: .2),
              width: 1,
            ),
          ),
          child: Center(
            child: CurrencyFlagIcon(
              code: quote.code,
              symbol: quote.symbol,
              radius: 17,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.space3),
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
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              Text(
                quote.code,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
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
