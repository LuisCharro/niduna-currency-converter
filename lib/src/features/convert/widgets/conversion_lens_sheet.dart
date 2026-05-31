import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/localization/ui_copy.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../models/currency_quote.dart';
import 'conversion_lens_positioner.dart';
import 'conversion_lens_quick_values.dart';
import 'conversion_lens_reverse_target.dart';

class ConversionLensSheet extends StatelessWidget {
  const ConversionLensSheet({
    required this.quote,
    required this.base,
    required this.amount,
    required this.onAmountChanged,
    super.key,
  });

  final CurrencyQuote quote;
  final String base;
  final double amount;
  final ValueChanged<String> onAmountChanged;

  static Future<void> show({
    required BuildContext context,
    required Offset anchor,
    required CurrencyQuote quote,
    required String base,
    required double amount,
    required ValueChanged<String> onAmountChanged,
  }) {
    final media = MediaQuery.of(context);
    final pos = calculateLensPosition(media.size, media.padding, anchor);
    final theme = Theme.of(context);
    return showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Dismiss conversion lens',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: .16),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) => Theme(
        data: theme,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            media.padding.top + 20,
            20,
            media.padding.bottom + 52,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: pos.width,
              height: pos.height,
              child: ConversionLensSheet(
                quote: quote,
                base: base,
                amount: amount,
                onAmountChanged: onAmountChanged,
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        final scale = Tween<double>(begin: .9, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            alignment: pos.alignment,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        key: const Key('conversion_lens'),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(26),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n?.conversionLensTitle ?? "Conversion Lens",
                        style: AppTheme.sectionLabelStyle(context),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${quote.name} · ${quote.code}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: colors.text,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: closeLensTooltip(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            buildLensHero(context, quote, base, amount),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    ConversionLensQuickValues(
                      quote: quote,
                      base: base,
                      amount: amount,
                    ),
                    const SizedBox(height: 12),
                    ConversionLensReverseTarget(
                      quote: quote,
                      base: base,
                      onAmountChanged: onAmountChanged,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
