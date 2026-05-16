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
    return Tooltip(
      message: 'Rates update once per day. Tap for details.',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        onTap: () => _showInfo(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: AppTheme.container.withValues(alpha: .5),
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            border: Border.all(color: AppTheme.border.withValues(alpha: .1)),
          ),
          child: Row(
            children: <Widget>[
              _StatusDot(active: isRefreshing),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      _title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.text,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      nextUpdateLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppTheme.muted.withValues(alpha: .74),
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
