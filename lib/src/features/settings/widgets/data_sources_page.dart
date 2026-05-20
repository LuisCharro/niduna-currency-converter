import 'package:flutter/material.dart';

import '../../../core/rates/provider_config.dart';
import '../../../core/theme/app_theme.dart';

class DataSourcesPage extends StatelessWidget {
  const DataSourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cryptoChartsDetail = ProviderConfig.cryptoChartsEnabled
        ? 'Crypto-involved charts use ${ProviderConfig.chartsProviderLabel}. Crypto ranges stay limited to 1 year on the no-key path.'
        : 'Crypto charts are disabled in this build to keep the release profile safe for store publication.';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bg,
        foregroundColor: AppTheme.text,
        elevation: 0,
        title: const Text('Data sources'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: <Widget>[
          Text(
            'Sources and limits',
            style: AppTheme.heading.copyWith(fontFamily: 'Fraunces'),
          ),
          const SizedBox(height: 12),
          const _SourceCard(
            title: 'Fiat latest and fiat charts',
            provider: 'Frankfurter / ECB',
            detail:
                'Frankfurter provides the fiat latest and historical exchange rates used by the app. Fiat charts support daily ranges up to 2 years.',
          ),
          const SizedBox(height: 16),
          _SourceCard(
            title: 'Crypto latest',
            provider: 'Configured by build profile',
            detail:
                'BTC and ETH latest prices use the active crypto provider chain for this build. Developer profile details are shown only inside the Dev Sandbox.',
          ),
          const SizedBox(height: 16),
          _SourceCard(
            title: 'Crypto charts',
            provider: ProviderConfig.chartsProviderLabel,
            detail:
                '$cryptoChartsDetail Crypto pricing data provided by CoinGecko.',
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({
    required this.title,
    required this.provider,
    required this.detail,
  });

  final String title;
  final String provider;
  final String detail;

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
            const SizedBox(height: 6),
            Text(
              provider,
              style: AppTheme.caption.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              detail,
              style: AppTheme.body.copyWith(
                color: AppTheme.muted,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
