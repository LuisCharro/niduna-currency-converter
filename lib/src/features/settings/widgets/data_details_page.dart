import 'package:flutter/material.dart';

import '../../../core/rates/provider_usage_info.dart';
import '../../../core/theme/app_theme.dart';

class DataDetailsPage extends StatelessWidget {
  const DataDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usage = ProviderUsageInfo.fromBuildConfig();
    final cryptoLines = <String>[
      'BTC and ETH rates follow the same daily update schedule as fiat rates.',
      if (usage.cryptoChartsEnabled)
        'Crypto charts show daily history for up to 1 year.'
      else
        'Crypto charts are not available in this build.',
      if (usage.cryptoChartsEnabled)
        'For mixed fiat and crypto charts, fiat values stay on the last available market close over weekends and holidays.',
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
          AppTheme.space2,
          AppTheme.pagePadding,
          AppTheme.space7,
        ),
        children: <Widget>[
          Text(
            'Daily data policy',
            style: AppTheme.heading.copyWith(fontFamily: 'Fraunces'),
          ),
          const SizedBox(height: AppTheme.space4),
          const Text(
            'This app uses exchange-rate data to show conversions and charts. Your data stays on this device.',
            style: AppTheme.body,
          ),
          const SizedBox(height: AppTheme.space5),
          const _DetailBlock(
            title: 'Updates',
            lines: <String>[
              'Rates update at most once per day.',
              'Refresh on open only checks for new data when your saved data is old.',
              'You can still use manual refresh to request the latest daily update.',
            ],
          ),
          const _DetailBlock(
            title: 'Fiat data',
            lines: <String>[
              'Fiat rates come from Frankfurter using ECB data.',
              'Fiat charts can show up to 2 years of daily history.',
              'If you are offline, the app uses saved data when available.',
            ],
          ),
          _DetailBlock(title: 'Crypto data', lines: cryptoLines),
          const _DetailBlock(
            title: 'Clear data',
            lines: <String>[
              'Clear all data removes saved rate and chart data from this device.',
              'It also removes temporary chart unlocks.',
              'It does not remove your theme or normal app settings.',
            ],
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  const _DetailBlock({
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
          style: AppTheme.sectionLabel.copyWith(
            color: AppTheme.primary,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: AppTheme.space2),
        for (final line in lines) ...<Widget>[
          Text(
            line,
            style: AppTheme.body.copyWith(color: AppTheme.muted, height: 1.45),
          ),
          const SizedBox(height: AppTheme.space2),
        ],
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.space4),
            child: Divider(
              color: AppTheme.border.withValues(alpha: .14),
              height: .5,
            ),
          ),
      ],
    );
  }
}
