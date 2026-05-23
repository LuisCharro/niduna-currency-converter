import 'package:flutter/material.dart';

import '../../../core/rates/provider_usage_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations_safe.dart';

class DataSourcesPage extends StatelessWidget {
  const DataSourcesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usage = ProviderUsageInfo.fromBuildConfig();
    final loc = l10n(context);
    final cryptoLatestProvider = usage.roles
        .firstWhere((role) => role.title == 'Crypto latest')
        .provider;
    final cryptoChartsProvider = usage.roles
        .firstWhere((role) => role.title == 'Crypto charts')
        .provider;
    final cryptoChartsDetail = usage.cryptoChartsEnabled
        ? 'Crypto-involved charts use $cryptoChartsProvider. Crypto ranges stay limited to 1 year on the no-key path.'
        : 'Crypto charts are disabled in this build to keep the release profile safe for store publication.';

    return Scaffold(
      backgroundColor: AppColors.of(context).bg,
      appBar: AppBar(
        backgroundColor: AppColors.of(context).bg,
        foregroundColor: AppColors.of(context).text,
        elevation: 0,
        title: Text(loc.labelDataSources),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.pagePadding,
          AppTheme.space2,
          AppTheme.pagePadding,
          AppTheme.space7,
        ),
        children: <Widget>[
          _SourceBlock(
            title: 'Fiat latest and fiat charts',
            provider: 'Frankfurter / ECB',
            detail:
                'Frankfurter provides the fiat latest and historical exchange rates used by the app. Fiat charts support daily ranges up to 2 years.',
          ),
          _SourceBlock(
            title: 'Crypto latest',
            provider: cryptoLatestProvider,
            detail:
                'BTC and ETH latest prices use the active crypto provider chain for this build. Developer profile details are shown only inside the Dev Sandbox.',
          ),
          _SourceBlock(
            title: 'Crypto charts',
            provider: cryptoChartsProvider,
            detail: cryptoChartsDetail,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _SourceBlock extends StatelessWidget {
  const _SourceBlock({
    required this.title,
    required this.provider,
    required this.detail,
    this.showDivider = true,
  });

  final String title;
  final String provider;
  final String detail;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppTheme.space1),
        Text(
          provider,
          style: AppTheme.caption.copyWith(
             color: AppColors.of(context).primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppTheme.space2),
        Text(
          detail,
          style: AppTheme.body.copyWith(color: AppColors.of(context).muted, height: 1.45),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
            child: Divider(
              color: AppColors.of(context).border.withValues(alpha: .14),
              height: .5,
            ),
          ),
      ],
    );
  }
}
