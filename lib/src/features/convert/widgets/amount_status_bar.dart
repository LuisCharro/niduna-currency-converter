import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../domain/convert_state.dart';
import 'daily_rates_info_sheet.dart';

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
    return _FreshnessButton(
      status: status,
      isRefreshing: isRefreshing,
      lastUpdatedLabel: lastUpdatedLabel,
      nextUpdateLabel: nextUpdateLabel,
    );
  }
}

class _FreshnessButton extends StatelessWidget {
  const _FreshnessButton({
    required this.status,
    required this.isRefreshing,
    required this.lastUpdatedLabel,
    required this.nextUpdateLabel,
  });

  final ConvertStatus status;
  final bool isRefreshing;
  final String lastUpdatedLabel;
  final String nextUpdateLabel;

  @override
  Widget build(BuildContext context) {
    final title = _title;
    final nextLabel = nextUpdateLabel.replaceFirst('Next around ', 'Next ');
    return Tooltip(
      message: 'Rates update once per day. Tap for details.',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: () => _showInfo(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: <Widget>[
              _StatusDot(active: isRefreshing),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$title · $nextLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _title {
    return switch (status) {
      ConvertStatus.loading => 'Daily rates loading',
      ConvertStatus.refreshing => 'Refreshing daily rates',
      ConvertStatus.stale => 'Cached · $lastUpdatedLabel',
      ConvertStatus.noCache => 'Daily rates unavailable',
      ConvertStatus.cached || ConvertStatus.fresh => lastUpdatedLabel,
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

class AmountUtilityPill extends StatelessWidget {
  const AmountUtilityPill({
    required this.onRefresh,
    required this.onMore,
    super.key,
  });

  final VoidCallback onRefresh;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.card.withValues(alpha: .62),
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        border: Border.all(color: AppTheme.border.withValues(alpha: .12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _UtilityIconButton(
            tooltip: 'Refresh rates',
            icon: Icons.sync_rounded,
            onPressed: onRefresh,
          ),
          SizedBox(
            height: 20,
            child: VerticalDivider(
              width: 1,
              thickness: 1,
              color: AppTheme.border.withValues(alpha: .1),
            ),
          ),
          _UtilityIconButton(
            tooltip: 'Settings',
            icon: Icons.tune_rounded,
            onPressed: onMore,
          ),
        ],
      ),
    );
  }
}

class _UtilityIconButton extends StatelessWidget {
  const _UtilityIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 19),
      style: IconButton.styleFrom(
        foregroundColor: AppTheme.primary,
        fixedSize: const Size(44, 44),
        minimumSize: const Size(44, 44),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? AppTheme.primary : AppTheme.trendUp,
        shape: BoxShape.circle,
      ),
    );
  }
}
