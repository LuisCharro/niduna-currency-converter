import 'package:flutter/material.dart';

import '../../../core/localization/ui_copy.dart';
import '../../../core/monetization/models/temporary_unlock.dart';
import '../../../core/monetization/monetization_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'chart_currency_picker_sheet.dart';
import 'chart_pair_pill.dart';

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
    super.key,
  });

  final String base;
  final String quote;
  final bool allowCryptoCharts;
  final void Function(String base, String quote) onPairChanged;
  final VoidCallback onSwap;
  final MonetizationController controller;
  final bool compact;

  static const _freeDefaults = {'USD', 'EUR'};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppTheme.pageInsets.copyWith(
        top: compact ? AppTheme.space2 : AppTheme.space3,
        bottom: compact ? AppTheme.space1 : AppTheme.space2,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: ChartPairPill(
              key: const Key('charts_pair_base'),
              code: base,
              locked: false,
              tempBadge: _showsTempBadgeFor(base),
              onTap: () => _openPicker(context, selectingBase: true),
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          GestureDetector(
            onTap: onSwap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.of(context).container,
                border: Border.all(
                  color: AppColors.of(context).border.withValues(alpha: .15),
                ),
              ),
              child: Icon(
                Icons.swap_vert_rounded,
                color: AppColors.of(context).text,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: ChartPairPill(
              key: const Key('charts_pair_quote'),
              code: quote,
              locked: !_isUnlocked(quote),
              tempBadge: _showsTempBadgeFor(quote),
              onTap: () => _openPicker(context, selectingBase: false),
            ),
          ),
        ],
      ),
    );
  }

  bool _isUnlocked(String code) {
    if (code == base) return true;
    if (_freeDefaults.contains(code)) return true;
    return controller.isChartPairUnlocked(base, quote);
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
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => ChartCurrencyPickerSheet(
        title: selectingBase
            ? selectBaseCurrencyForChart(context)
            : selectQuoteCurrencyForChart(context),
        selectedCode: selectingBase ? base : quote,
        allowCryptoCharts: allowCryptoCharts,
        controller: controller,
        baseCurrency: base,
        quoteCurrency: quote,
        selectingBase: selectingBase,
      ),
    );

    if (!context.mounted || selected == null) return;

    final nextBase = selectingBase ? selected : base;
    final nextQuote = selectingBase ? quote : selected;
    if (nextBase == nextQuote) return;

    onPairChanged(nextBase, nextQuote);
  }
}
