import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/localization/ui_copy.dart';
import '../../../core/currency/supported_currencies.dart';
import '../models/currency_quote.dart';

class LensPosition {
  const LensPosition({
    required this.width,
    required this.height,
    required this.alignment,
  });

  final double width;
  final double height;
  final Alignment alignment;
}

LensPosition calculateLensPosition(
  Size screenSize,
  EdgeInsets safePadding,
  Offset anchor,
) {
  const hMargin = 20.0;
  const topMargin = 20.0;
  const bottomMargin = 52.0;
  final width = math.min(screenSize.width - hMargin * 2, 380.0);
  final safeHeight = screenSize.height - safePadding.top - safePadding.bottom;
  final availableHeight =
      math.max(320.0, safeHeight - topMargin - bottomMargin);
  final height = math.min(
    availableHeight,
    math.min(560.0, math.max(360.0, availableHeight * .74)),
  );
  final left = (screenSize.width - width) / 2;
  final top = screenSize.height - safePadding.bottom - bottomMargin - height;
  final alignment = Alignment(
    ((anchor.dx - left) / width).clamp(0.1, 0.9) * 2 - 1,
    ((anchor.dy - top) / height).clamp(0.1, 0.9) * 2 - 1,
  );
  return LensPosition(width: width, height: height, alignment: alignment);
}

int cryptoDigits(String code) {
  if (code == 'BTC') return 8;
  if (code == 'USDT' || code == 'USDC') return 2;
  if (code == 'DOGE') return 4;
  return 6;
}

String stripTrailingZeros(String formatted) {
  if (!formatted.contains('.')) return formatted;
  var result = formatted.replaceAll(RegExp(r'0+$'), '');
  if (result.endsWith('.')) result = result.substring(0, result.length - 1);
  return result;
}

String _fmtCrypto(double value, String code) => stripTrailingZeros(
      NumberFormat('#,##0.${'0' * cryptoDigits(code)}', 'en').format(value),
    );

String formatLensValue(double value, String code) {
  if (isCryptoCurrency(code)) {
    return NumberFormat(
      '#,##0.${'0' * cryptoDigits(code)}',
      'en',
    ).format(value);
  }
  final d = value >= 100 ? 0 : value >= 10 ? 2 : 3;
  return NumberFormat('#,##0.${'0' * d}', 'en').format(value);
}

String formatLensInput(double value) {
  if (value >= 100) return value.toStringAsFixed(0);
  if (value >= 10) return value.toStringAsFixed(2);
  return value.toStringAsFixed(3);
}

String formatHeroBase(double v, String c) => isCryptoCurrency(c)
    ? _fmtCrypto(v, c)
    : stripTrailingZeros(NumberFormat('#,##0.######', 'en').format(v));

String formatHeroConverted(double v, String c) {
  if (isCryptoCurrency(c)) return _fmtCrypto(v, c);
  if (v >= 10) return NumberFormat('#,##0.00', 'en').format(v);
  return NumberFormat('#,##0.000', 'en').format(v);
}

String formatLensRaw(double v, String c) => isCryptoCurrency(c)
    ? NumberFormat('0.${'0' * cryptoDigits(c)}', 'en').format(v)
    : NumberFormat('0.0000', 'en').format(v);

Widget buildLensHero(
  BuildContext context,
  CurrencyQuote quote,
  String base,
  double amount,
) {
  final colors = AppColors.of(context);
  final a = formatHeroBase(amount, base);
  final c = formatHeroConverted(amount * quote.rate, quote.code);
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
                SnackBar(
                  content: Text(copiedConversionMessage(context, copy)),
                ),
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
