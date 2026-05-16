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
    return Tooltip(
      message: 'Rates update once per day. Tap for details.',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        onTap: () => _showInfo(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _StatusDot(active: isRefreshing),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  '$title · $nextUpdateLabel',
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

class AmountActionButton extends StatelessWidget {
  const AmountActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    super.key,
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
        backgroundColor: AppTheme.card.withValues(alpha: .48),
        foregroundColor: AppTheme.primary,
        fixedSize: const Size(44, 44),
        minimumSize: const Size(44, 44),
        padding: EdgeInsets.zero,
        side: BorderSide(color: AppTheme.border.withValues(alpha: .12)),
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
