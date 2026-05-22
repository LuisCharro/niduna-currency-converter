import 'package:flutter/material.dart';

import '../../../core/rates/provider_usage_info.dart';
import '../../../core/theme/app_theme.dart';

class DataDetailsPage extends StatelessWidget {
  const DataDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usage = ProviderUsageInfo.fromBuildConfig();
    final cryptoLines = <String>[
      'BTC and ETH latest rates refresh on the same daily app policy.',
      if (usage.cryptoChartsEnabled)
        'Crypto charts support daily ranges up to 1 year.'
      else
        'Crypto charts are disabled in this release-safe build.',
      if (usage.cryptoChartsEnabled)
        'Mixed fiat/crypto charts carry forward the last fiat close across weekends and holidays.',
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        foregroundColor: AppTheme.text,
        elevation: 0,
        title: const Text('Data details'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.pagePadding,
          8,
          AppTheme.pagePadding,
          32,
        ),
        children: <Widget>[
          Text(
            'Daily data policy',
            style: AppTheme.heading.copyWith(fontFamily: 'Fraunces'),
          ),
          const SizedBox(height: 12),
          const _DetailSection(
            title: 'Refresh policy',
            lines: <String>[
              'The app refreshes rates at most once per local day.',
              'Refresh on open only fetches when cached data is stale.',
              'Manual refresh still lets you request a fresh daily snapshot.',
            ],
          ),
          const _DetailSection(
            title: 'Fiat data',
            lines: <String>[
              'Fiat latest rates come from Frankfurter / ECB data.',
              'Fiat charts support up to 2 years of daily history.',
              'When offline, the app shows cached fiat data if available.',
            ],
          ),
          _DetailSection(title: 'Crypto data', lines: cryptoLines),
          const _DetailSection(
            title: 'Clear cache',
            lines: <String>[
              'Clear all data removes latest fiat cache.',
              'It also removes crypto latest cache, fiat charts, crypto chart history, and temporary chart unlocks.',
              'It does not remove your theme or normal app preferences.',
            ],
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.lines,
    this.showDivider = true,
  });

  final String title;
  final List<String> lines;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: AppTheme.caption.copyWith(
            color: AppTheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        for (final line in lines) ...<Widget>[
          Text(
            line,
            style: AppTheme.body.copyWith(color: AppTheme.muted, height: 1.45),
          ),
          const SizedBox(height: 8),
        ],
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: Divider(
              color: AppTheme.border.withValues(alpha: .14),
              height: .5,
            ),
          )
        else
          const SizedBox(height: 8),
      ],
    );
  }
}
