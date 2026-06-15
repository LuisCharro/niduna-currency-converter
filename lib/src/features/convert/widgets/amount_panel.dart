import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/instrument_panel.dart';
import '../domain/convert_state.dart';
import 'amount_header_row.dart';
import 'amount_status_bar.dart';
import 'amount_value_row.dart';

/// Hero conversion instrument well (D2-CON-1).
class AmountPanel extends StatelessWidget {
  const AmountPanel({
    required this.isRefreshing,
    required this.lastUpdatedLabel,
    required this.nextUpdateLabel,
    required this.status,
    required this.amountText,
    required this.base,
    required this.onRefresh,
    required this.onShare,
    required this.onMore,
    required this.onAmountChanged,
    required this.onBaseTap,
    super.key,
  });

  final bool isRefreshing;
  final String lastUpdatedLabel;
  final String nextUpdateLabel;
  final ConvertStatus status;
  final String amountText;
  final String base;
  final Future<void> Function() onRefresh;
  final VoidCallback? onShare;
  final VoidCallback onMore;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onBaseTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppTheme.pageInsets.copyWith(
        top: AppTheme.space2,
        bottom: AppTheme.space3,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AmountHeaderRow(onRefresh: () => onRefresh(), onShare: onShare, onMore: onMore),
          const SizedBox(height: AppTheme.space3),
          InstrumentPanel(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.space4,
              AppTheme.space5,
              AppTheme.space4,
              AppTheme.space3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                AmountValueRow(
                  amountText: amountText,
                  base: base,
                  onAmountChanged: onAmountChanged,
                  onBaseTap: onBaseTap,
                ),
                const SizedBox(height: AppTheme.space3),
                AmountStatusBar(
                  isRefreshing: isRefreshing,
                  lastUpdatedLabel: lastUpdatedLabel,
                  nextUpdateLabel: nextUpdateLabel,
                  status: status,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
