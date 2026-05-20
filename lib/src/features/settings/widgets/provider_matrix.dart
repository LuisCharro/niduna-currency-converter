import 'package:flutter/material.dart';

import '../../../core/rates/provider_usage_info.dart';
import '../../../core/theme/app_theme.dart';

class ProviderMatrix extends StatelessWidget {
  const ProviderMatrix({required this.rows, super.key});

  final List<ProviderMatrixRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.container.withValues(alpha: .5),
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Provider matrix',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (final row in rows) ...<Widget>[
            _ProviderRow(row: row),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _ProviderRow extends StatelessWidget {
  const _ProviderRow({required this.row});

  final ProviderMatrixRow row;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: Text(
            row.provider,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            row.role,
            style: const TextStyle(fontSize: 12, color: AppTheme.muted),
          ),
        ),
        _StatusPill(status: row.status),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isPrimary = status.contains('Primary');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppTheme.trendUp.withValues(alpha: .12)
            : AppTheme.container,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          color: isPrimary ? AppTheme.trendUp : AppTheme.muted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
