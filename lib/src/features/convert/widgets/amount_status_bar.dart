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
    required this.onRefresh,
    required this.onMore,
    super.key,
  });

  final bool isRefreshing;
  final String lastUpdatedLabel;
  final String nextUpdateLabel;
  final ConvertStatus status;
  final Future<void> Function() onRefresh;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _FreshnessButton(
            status: status,
            isRefreshing: isRefreshing,
            lastUpdatedLabel: lastUpdatedLabel,
            nextUpdateLabel: nextUpdateLabel,
          ),
        ),
        _ActionButton(
          tooltip: 'Refresh rates',
          icon: Icons.sync_rounded,
          onPressed: onRefresh,
        ),
        const SizedBox(width: 6),
        _ActionButton(
          tooltip: 'Settings',
          icon: Icons.tune_rounded,
          onPressed: onMore,
        ),
      ],
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
    return Tooltip(
      message: 'Rates update once per day. Tap for details.',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: () => _showInfo(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _StatusDot(active: isRefreshing),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      nextUpdateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.subtle,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppTheme.subtle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _title {
    return switch (status) {
      ConvertStatus.loading => 'Daily rates · Loading',
      ConvertStatus.refreshing => 'Daily rates · Refreshing',
      ConvertStatus.stale => 'Cached daily rates · $lastUpdatedLabel',
      ConvertStatus.noCache => 'Daily rates unavailable',
      ConvertStatus.cached ||
      ConvertStatus.fresh => 'Daily rates · $lastUpdatedLabel',
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
        backgroundColor: AppTheme.card.withValues(alpha: .72),
        foregroundColor: AppTheme.primary,
        fixedSize: const Size(42, 42),
        minimumSize: const Size(42, 42),
        padding: EdgeInsets.zero,
        side: BorderSide(color: AppTheme.border.withValues(alpha: .16)),
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
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppTheme.primary : AppTheme.trendUp,
        shape: BoxShape.circle,
      ),
    );
  }
}
