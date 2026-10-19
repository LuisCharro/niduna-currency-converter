import 'package:flutter/material.dart';

import '../../../core/localization/ui_copy.dart';
import '../../../core/monetization/models/temporary_unlock.dart';
import '../../../core/monetization/monetization_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'chart_currency_picker_sheet.dart';
import 'chart_pair_pill.dart';
import '../../../../l10n/app_localizations_safe.dart';

/// Slim pair strip below the plot (D2-CHT-5).
class ChartPairStrip extends StatelessWidget {
  const ChartPairStrip({
    required this.base,
    required this.quote,
    required this.allowCryptoCharts,
    required this.onPairChanged,
    required this.onSwap,
    required this.controller,
    this.compact = false,
    this.dense = false,
    super.key,
  });

  final String base;
  final String quote;
  final bool allowCryptoCharts;
  final void Function(String base, String quote) onPairChanged;
  final VoidCallback onSwap;
  final MonetizationController controller;
  final bool compact;
  final bool dense;

  static const _freeDefaults = {'USD', 'EUR'};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          (dense
                  ? const EdgeInsets.symmetric(horizontal: 0)
                  : AppTheme.pageInsets)
              .copyWith(
                top: dense
                    ? 0
                    : compact
                    ? AppTheme.space2
                    : AppTheme.space3,
                bottom: dense
                    ? 0
                    : compact
                    ? AppTheme.space1
                    : AppTheme.space2,
              ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ChartPairPill(
              key: const Key('charts_pair_base'),
              code: base,
              dense: dense,
              locked: !controller.isChartPairUnlocked(base, quote),
              tempBadge: _showsTempBadgeFor(base),
              onTap: () => _openPicker(context, selectingBase: true),
            ),
          ),
          SizedBox(width: dense ? 4 : AppTheme.space3),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.of(context).container,
            ),
            foregroundDecoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.of(context).border.withValues(alpha: .15),
              ),
            ),
            child: IconButton(
              key: const Key('charts_pair_swap'),
              tooltip: l10n(context).btnSwap,
              onPressed: () {
                if (controller.isChartPairUnlocked(quote, base)) onSwap();
              },
              icon: Icon(
                dense ? Icons.swap_horiz_rounded : Icons.swap_vert_rounded,
                color: AppColors.of(context).text,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: dense ? 4 : AppTheme.space3),
          Expanded(
            child: ChartPairPill(
              key: const Key('charts_pair_quote'),
              code: quote,
              dense: dense,
              locked: !controller.isChartPairUnlocked(base, quote),
              tempBadge: _showsTempBadgeFor(quote),
              onTap: () => _openPicker(context, selectingBase: false),
            ),
          ),
        ],
      ),
    );
  }

  bool _isPairTempUnlocked() {
    if (_isFreeDefaultPair(base, quote)) return false;
    final canonical = TemporaryUnlock.canonicalKey(base, quote);
    return controller.tempUnlockedCodes.contains(canonical);
  }

  /// A temporary unlock belongs to the pair, not to an individual currency.
  /// Show it once, preferring the non-default currency when the pair has one.
  bool _showsTempBadgeFor(String code) {
    if (!_isPairTempUnlocked()) return false;

    final baseIsFree = _freeDefaults.contains(base);
    final quoteIsFree = _freeDefaults.contains(quote);
    if (baseIsFree != quoteIsFree) {
      return code == (baseIsFree ? quote : base);
    }

    // Two restricted currencies share one pair entitlement; keep one marker.
    return code == quote;
  }

  bool _isFreeDefaultPair(String a, String b) {
    final sorted = [a, b]..sort();
    return sorted[0] == 'EUR' && sorted[1] == 'USD';
  }

  Future<void> _openPicker(
    BuildContext context, {
    required bool selectingBase,
  }) async {
    if (!(ModalRoute.isCurrentOf(context) ?? true)) return;
    final picker = ChartCurrencyPickerSheet(
      title: selectingBase
          ? selectBaseCurrencyForChart(context)
          : selectQuoteCurrencyForChart(context),
      selectedCode: selectingBase ? base : quote,
      allowCryptoCharts: allowCryptoCharts,
      controller: controller,
      baseCurrency: base,
      quoteCurrency: quote,
      selectingBase: selectingBase,
    );
    final navigator = Navigator.of(context);
    final themes = InheritedTheme.capture(from: context, to: navigator.context);
    final background = AppColors.of(context).bg;
    final Future<String?> result;
    if (dense) {
      result = navigator.push<String>(
        MaterialPageRoute<String>(
          builder: (_) =>
              themes.wrap(Scaffold(backgroundColor: background, body: picker)),
        ),
      );
    } else {
      result = showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        useSafeArea: true,
        builder: (_) => picker,
      );
    }
    final selected = await result;

    if (!context.mounted || selected == null) return;

    final nextBase = selectingBase ? selected : base;
    final nextQuote = selectingBase ? quote : selected;
    if (nextBase == nextQuote) return;

    if (!controller.isChartPairUnlocked(nextBase, nextQuote)) return;
    onPairChanged(nextBase, nextQuote);
  }
}
