import 'package:flutter/material.dart';

import '../../../core/localization/ui_copy.dart';
import '../../../core/rates/provider_usage_info.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations_safe.dart';

class DataDetailsPage extends StatelessWidget {
  const DataDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final usage = ProviderUsageInfo.fromBuildConfig();
    final loc = l10n(context);
    final cryptoLines = cryptoDataLines(context, usage.cryptoChartsEnabled);

    return Scaffold(
      backgroundColor: AppColors.of(context).bg,
      appBar: AppBar(
        backgroundColor: AppColors.of(context).bg,
        foregroundColor: AppColors.of(context).text,
        elevation: 0,
        title: Text(loc.dataDetailsTitle),
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
            loc.dataPolicyTitle,
            style: AppTheme.heading.copyWith(
              fontFamily: 'Fraunces',
              color: AppColors.of(context).text,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          Text(
            loc.dataPrivacyLine,
            style: AppTheme.body.copyWith(color: AppColors.of(context).text),
          ),
          const SizedBox(height: AppTheme.space5),
          _DetailBlock(
            title: loc.updatesTitle,
            lines: <String>[
              loc.updatesLine1,
              loc.updatesLine2,
              loc.updatesLine3,
            ],
          ),
          _DetailBlock(
            title: loc.fiatDataTitle,
            lines: <String>[
              loc.fiatDataLine1,
              loc.fiatDataLine2,
              loc.fiatDataLine3,
            ],
          ),
          _DetailBlock(title: loc.cryptoDataTitle, lines: cryptoLines),
          _DetailBlock(
            title: loc.clearDataTitle,
            lines: <String>[
              loc.clearDataLine1,
              loc.clearDataLine2,
              loc.clearDataLine3,
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
          style: AppTheme.sectionLabelStyle(
            context,
          ).copyWith(color: AppColors.of(context).primary, letterSpacing: 0.6),
        ),
        const SizedBox(height: AppTheme.space2),
        for (final line in lines) ...<Widget>[
          Text(
            line,
            style: AppTheme.body.copyWith(
              color: AppColors.of(context).muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppTheme.space2),
        ],
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.space4),
            child: Divider(
              color: AppColors.of(context).border.withValues(alpha: .14),
              height: .5,
            ),
          ),
      ],
    );
  }
}
