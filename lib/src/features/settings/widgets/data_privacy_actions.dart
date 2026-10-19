import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/ads/ad_consent_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../settings_links.dart';

class DataPrivacyActions extends StatelessWidget {
  const DataPrivacyActions({
    required this.links,
    required this.consent,
    required this.onOpenSources,
    super.key,
  });

  final SettingsLinks links;
  final AdConsentManager consent;
  final VoidCallback onOpenSources;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final color = AppColors.of(context).subtle;
    return Column(
      children: <Widget>[
        SettingsTile(
          title: loc.rateSourcesTitle,
          trailing: Icon(Icons.chevron_right_rounded, color: color),
          onTap: onOpenSources,
        ),
        SettingsTile(
          title: loc.labelPrivacy,
          trailing: Icon(Icons.open_in_new_rounded, color: color),
          onTap: links.openPrivacyPolicy,
        ),
        ListenableBuilder(
          listenable: consent,
          builder: (context, _) => consent.privacyOptionsRequired
              ? SettingsTile(
                  title: loc.privacyOptionsTitle,
                  trailing: Icon(Icons.tune_rounded, color: color),
                  onTap: consent.showPrivacyOptions,
                  showDivider: false,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
