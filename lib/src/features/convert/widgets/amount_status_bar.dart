import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/localization/ui_copy.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/convert_state.dart';
import 'daily_rates_info_sheet.dart';

/// Single-line freshness signal strip (D2-CON-3).
class AmountStatusBar extends StatelessWidget {
  const AmountStatusBar({
    required this.isRefreshing,
    required this.lastUpdatedLabel,
    required this.nextUpdateLabel,
    required this.status,
    super.key,
  });

  final bool isRefreshing;
  final String lastUpdatedLabel;
  final String nextUpdateLabel;
  final ConvertStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final accent = _accentColor(context);
    return Semantics(
      button: true,
      label: l10n(context).rateFreshnessInfoLabel,
      child: Tooltip(
        message: dailyRatesTooltip(context),
        child: InkWell(
          onTap: () => _showInfo(context),
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: <Widget>[
                _StatusDot(color: accent, active: isRefreshing),
                const SizedBox(width: AppTheme.space2),
                Expanded(
                  child: Text(
                    _line(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.caption.copyWith(
                      color: colors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: colors.muted.withValues(alpha: .7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _accentColor(BuildContext context) {
    final colors = AppColors.of(context);
    return switch (status) {
      ConvertStatus.stale => const Color(0xFFB8860B),
      ConvertStatus.noCache => colors.trendDown,
      ConvertStatus.loading || ConvertStatus.refreshing => colors.primary,
      ConvertStatus.cached || ConvertStatus.fresh => colors.trendUp,
    };
  }

  String _line(BuildContext context) {
    return switch (status) {
      ConvertStatus.loading => loadingDailyRates(context),
      ConvertStatus.refreshing => refreshingRates(context, lastUpdatedLabel),
      ConvertStatus.stale => cachedRatesLabel(context, lastUpdatedLabel),
      ConvertStatus.noCache => offlineRatesUnavailable(context),
      ConvertStatus.cached || ConvertStatus.fresh =>
        freshRatesLabel(context, lastUpdatedLabel),
    };
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => DailyRatesInfoSheet(
        lastUpdatedLabel: lastUpdatedLabel,
        nextUpdateLabel: nextUpdateLabel,
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color, required this.active});

  final Color color;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? colors.primary : color,
        shape: BoxShape.circle,
      ),
    );
  }
}
