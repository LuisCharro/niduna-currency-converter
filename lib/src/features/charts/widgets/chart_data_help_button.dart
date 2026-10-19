import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/localization/ui_copy.dart';
import '../../../core/rates/provider_usage_info.dart';
import '../../../core/theme/app_theme.dart';

class ChartDataHelpButton extends StatelessWidget {
  const ChartDataHelpButton({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: l10n(context).chartDataHelpTitle,
    child: TextButton(
      style: TextButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      onPressed: () => _showHelp(context),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.supportingTextStyle(context),
      ),
    ),
  );

  void _showHelp(BuildContext context) {
    final loc = l10n(context);
    final usage = ProviderUsageInfo.fromBuildConfig();
    final lines = <String>[
      dailyRatesBody(context),
      loc.fiatDataLine2,
      ...cryptoDataLines(context, usage.cryptoChartsEnabled),
    ];
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(loc.chartDataHelpTitle, style: AppTheme.heading),
              for (final line in lines) ...[
                const SizedBox(height: AppTheme.space4),
                Text(line, style: AppTheme.body),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
