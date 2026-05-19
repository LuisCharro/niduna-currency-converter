import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class DataSourcesPage extends StatelessWidget {
  const DataSourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        children: const <Widget>[
          _SourceCard(
            title: 'Fiat latest and fiat charts',
            provider: 'Frankfurter / ECB',
            detail:
                'Frankfurter provides the fiat latest and historical exchange rates used by the app. Fiat charts support daily ranges up to 2 years.',
          ),
          SizedBox(height: 16),
          _SourceCard(
            title: 'Crypto latest',
            provider: 'CoinPaprika',
            detail:
                'CoinPaprika is the primary source for BTC and ETH latest prices. The app keeps a no-key fallback for latest crypto rates when needed.',
          ),
          SizedBox(height: 16),
          _SourceCard(
            title: 'Crypto latest fallback',
            provider: 'fawazahmed0/exchange-api',
            detail:
                'This fallback is used only for latest crypto prices if the primary source fails. It is not used for historical chart ranges.',
          ),
          SizedBox(height: 16),
          _SourceCard(
            title: 'Crypto charts',
            provider: 'CoinPaprika historical ticks',
            detail:
                'BTC/ETH and mixed fiat/crypto charts use CoinPaprika daily historical data. Crypto-involved charts are limited to 1 year on the no-key path.',
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
