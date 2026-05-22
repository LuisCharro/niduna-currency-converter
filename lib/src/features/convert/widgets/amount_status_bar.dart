import 'package:flutter/material.dart';

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
    final accent = _accentColor;
    return Tooltip(
      message: 'Rates update once per day. Tap for details.',
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
                  _line,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.info_outline_rounded,
                size: 15,
                color: AppTheme.muted.withValues(alpha: .7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color get _accentColor {
    return switch (status) {
      ConvertStatus.stale => const Color(0xFFB8860B),
      ConvertStatus.noCache => AppTheme.trendDown,
      ConvertStatus.loading || ConvertStatus.refreshing => AppTheme.primary,
      ConvertStatus.cached || ConvertStatus.fresh => AppTheme.trendUp,
    };
  }

  String get _line {
    return switch (status) {
      ConvertStatus.loading => 'Loading daily rates…',
      ConvertStatus.refreshing => 'Refreshing · $lastUpdatedLabel',
      ConvertStatus.stale => 'Cached · $lastUpdatedLabel',
      ConvertStatus.noCache => 'Offline — rates unavailable',
      ConvertStatus.cached || ConvertStatus.fresh =>
        'Fresh · $lastUpdatedLabel',
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? AppTheme.primary : color,
        shape: BoxShape.circle,
      ),
    );
  }
}
