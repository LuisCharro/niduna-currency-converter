import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/currency_flag_icon.dart';
import '../models/currency_quote.dart';
import 'quote_identity.dart';
import 'quote_value.dart';

class CurrencyRateRow extends StatelessWidget {
  const CurrencyRateRow({required this.quote, this.onSemanticsTap, super.key});

  final CurrencyQuote quote;

  /// Action exposed to assistive technology for the row's long-press action.
  /// The visible gesture remains owned by [CurrencyRowSwipeActions].
  final VoidCallback? onSemanticsTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      focusable: true,
      onTapHint: onSemanticsTap == null
          ? null
          : l10n(context).openPairLabel(quote.code),
      onTap: onSemanticsTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => HapticFeedback.selectionClick(),
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppTheme.rowMinHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.of(
                          context,
                        ).border.withValues(alpha: .32),
                        width: 1.0,
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
                  Expanded(child: QuoteIdentity(quote: quote)),
                  const SizedBox(width: 12),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * .52,
                      ),
                      child: QuoteValue(quote: quote),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
