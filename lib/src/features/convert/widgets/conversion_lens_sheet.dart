import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../models/currency_quote.dart';

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
    const horizontalMargin = 20.0;
    const topMargin = 20.0;
    const bottomMargin = 52.0;
    final width = math.min(media.size.width - (horizontalMargin * 2), 380.0);
    final safeHeight = media.size.height - media.padding.top - media.padding.bottom;
    final availableHeight = math.max(320.0, safeHeight - topMargin - bottomMargin);
    final height = math.min(
      availableHeight,
      math.min(560.0, math.max(360.0, availableHeight * .74)),
    );
    final left = (media.size.width - width) / 2;
    final top = media.size.height - media.padding.bottom - bottomMargin - height;
    final alignment = Alignment(
      ((anchor.dx - left) / width).clamp(0.1, 0.9) * 2 - 1,
      ((anchor.dy - top) / height).clamp(0.1, 0.9) * 2 - 1,
    );

    return showGeneralDialog<void>(
      context: context,
      barrierLabel: 'Dismiss conversion lens',
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: .16),
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalMargin,
            media.padding.top + topMargin,
            horizontalMargin,
            media.padding.bottom + bottomMargin,
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: width,
              height: height,
              child: _LensCard(
                quote: quote,
                base: base,
                amount: amount,
                onAmountChanged: onAmountChanged,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        final scale = Tween<double>(begin: .9, end: 1).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: fade,
          child: ScaleTransition(
            scale: scale,
            alignment: alignment,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _LensCard(
      quote: quote,
      base: base,
      amount: amount,
      onAmountChanged: onAmountChanged,
    );
  }
}

class _LensCard extends StatelessWidget {
  const _LensCard({
    required this.quote,
    required this.base,
    required this.amount,
    required this.onAmountChanged,
  });

  final CurrencyQuote quote;
  final String base;
  final double amount;
  final ValueChanged<String> onAmountChanged;

  @override
  Widget build(BuildContext context) {
    final quickBase = _baseValues(amount);
    final reverseTargets = _reverseTargets();
    final amountLabel = _formatValue(amount, base);
    final convertedLabel = _formatValue(amount * quote.rate, quote.code);
    final copyLabel = '$amountLabel $base = $convertedLabel ${quote.code}';

    return Material(
      color: Colors.transparent,
      child: Container(
        key: const Key('conversion_lens'),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const <BoxShadow>[
            BoxShadow(color: Color(0x1A171D14), blurRadius: 26, offset: Offset(0, 14)),
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
                      Text('CONVERSION LENS', style: AppTheme.sectionLabel),
                      const SizedBox(height: 6),
                      Text(
                        '${quote.name} · ${quote.code}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close lens',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.container,
                borderRadius: BorderRadius.circular(20),
              ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(amountLabel, style: AppTheme.sectionLabel.copyWith(letterSpacing: 0.4)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '$convertedLabel ${quote.code}',
                            style: AppTheme.pairTitleFraunces.copyWith(fontSize: 26),
                          ),
                        ),
                        IconButton(
                          key: const Key('conversion_lens_copy_button'),
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: copyLabel));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Copied $copyLabel')),
                              );
                            }
                          },
                          tooltip: 'Copy conversion to clipboard',
                          icon: const Icon(Icons.content_copy_rounded, size: 20),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1 $base = ${_formatRaw(quote.rate, quote.code)} ${quote.code}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _LensSection(
                      title: 'Quick base amounts',
                      children: quickBase
                          .map(
                            (value) => _LensRow(
                              leading: _formatValue(value, base),
                              trailing: '${_formatValue(value * quote.rate, quote.code)} ${quote.code}',
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    _LensSection(
                      title: 'Reverse targets',
                      children: reverseTargets
                          .map(
                            (target) => _LensRow(
                              leading: '${_formatValue(target, quote.code)} ${quote.code}',
                              trailing:
                                  '${_formatValue(target / quote.rate, base)} $base',
                              actionLabel: 'Use',
                              onAction: () {
                                HapticFeedback.selectionClick();
                                onAmountChanged(_formatInput(target / quote.rate));
                                Navigator.of(context).pop();
                              },
                            ),
                          )
                          .toList(),
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

  List<double> _baseValues(double currentAmount) {
    final values = <double>{1, 10, 50, 100, 1000};
    if (currentAmount > 0) values.add(double.parse(currentAmount.toStringAsFixed(2)));
    final sorted = values.toList()..sort();
    return sorted;
  }

  List<double> _reverseTargets() {
    if (quote.code == 'BTC') return <double>[0.001, 0.01, 0.1];
    if (quote.code == 'ETH') return <double>[0.01, 0.1, 1];
    return <double>[10, 50, 100];
  }

  String _formatValue(double value, String code) {
    final digits = code == 'BTC'
        ? 8
        : code == 'ETH'
        ? 6
        : value >= 100
        ? 0
        : value >= 10
        ? 2
        : 3;
    return NumberFormat('#,##0.${'0' * digits}', 'en').format(value);
  }

  String _formatRaw(double value, String code) {
    final digits = code == 'BTC' ? 8 : code == 'ETH' ? 6 : 4;
    return NumberFormat('0.${'0' * digits}', 'en').format(value);
  }

  String _formatInput(double value) {
    if (value >= 100) return value.toStringAsFixed(0);
    if (value >= 10) return value.toStringAsFixed(2);
    return value.toStringAsFixed(3);
  }
}

class _LensSection extends StatelessWidget {
  const _LensSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: AppTheme.sectionLabel),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _LensRow extends StatelessWidget {
  const _LensRow({
    required this.leading,
    required this.trailing,
    this.actionLabel,
    this.onAction,
  });

  final String leading;
  final String trailing;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              leading,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              trailing,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
            ),
          ),
          if (actionLabel != null) ...<Widget>[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
