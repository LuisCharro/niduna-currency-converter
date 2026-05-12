import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ConvertHeader extends StatelessWidget {
  const ConvertHeader({
    required this.onRefresh,
    required this.isRefreshing,
    required this.onAddCurrencies,
    required this.onMore,
    super.key,
  });

  final VoidCallback onRefresh;
  final bool isRefreshing;
  final VoidCallback onAddCurrencies;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Convert',
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isRefreshing
                      ? 'Refreshing daily rates'
                      : 'Private daily rates',
                  style: AppTheme.micro.copyWith(color: AppTheme.subtle),
                ),
              ],
            ),
          ),
          _HeaderPill(
            label: 'Currencies',
            icon: Icons.format_list_bulleted_rounded,
            onTap: onAddCurrencies,
          ),
          const SizedBox(width: 8),
          _RoundAction(
            icon: Icons.tune_rounded,
            label: 'Settings',
            onTap: onMore,
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            border: Border.all(color: AppTheme.border.withValues(alpha: .35)),
            boxShadow: AppTheme.subtleShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, color: AppTheme.primary, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: AppTheme.container,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, color: AppTheme.muted, size: 19),
          ),
        ),
      ),
    );
  }
}
