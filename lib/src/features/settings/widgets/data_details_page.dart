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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          const _DetailCard(
            title: 'Refresh policy',
            lines: <String>[
              'The app refreshes rates at most once per local day.',
              'Refresh on open only fetches when cached data is stale.',
              'Manual refresh still lets you request a fresh daily snapshot.',
            ],
          ),
          const SizedBox(height: 16),
          const _DetailCard(
            title: 'Fiat data',
            lines: <String>[
              'Fiat latest rates come from Frankfurter / ECB data.',
              'Fiat charts support up to 2 years of daily history.',
              'When offline, the app shows cached fiat data if available.',
            ],
          ),
          const SizedBox(height: 16),
          _DetailCard(title: 'Crypto data', lines: cryptoLines),
          const SizedBox(height: 16),
          const _DetailCard(
            title: 'Clear cache',
            lines: <String>[
              'Clear all data removes latest fiat cache.',
              'It also removes crypto latest cache, fiat charts, crypto chart history, and temporary chart unlocks.',
              'It does not remove your theme or normal app preferences.',
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.card.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border.withValues(alpha: .2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final line in lines) ...<Widget>[
              Text(
                line,
                style: AppTheme.body.copyWith(
                  color: AppTheme.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
