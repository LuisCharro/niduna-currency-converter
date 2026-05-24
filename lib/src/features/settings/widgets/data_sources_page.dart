import 'package:flutter/material.dart';

import '../../../core/localization/ui_copy.dart';
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
    final cryptoChartsDetail = dataSourceCryptoChartsDetail(
      context,
      cryptoChartsProvider,
      usage.cryptoChartsEnabled,
    );

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
            title: dataSourceFiatTitle(context),
            provider: 'Frankfurter / ECB',
            detail: dataSourceFiatDetail(context),
          ),
          _SourceBlock(
            title: dataSourceCryptoLatestTitle(context),
            provider: cryptoLatestProvider,
            detail: dataSourceCryptoLatestDetail(context),
          ),
          _SourceBlock(
            title: dataSourceCryptoChartsTitle(context),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.of(context).text,
          ),
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
          style: AppTheme.body.copyWith(
            color: AppColors.of(context).muted,
            height: 1.45,
          ),
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
