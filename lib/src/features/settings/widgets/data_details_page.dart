import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/ads/ad_consent_manager.dart';
import '../settings_links.dart';
import 'data_privacy_actions.dart';
import 'data_sources_page.dart';
import 'settings_detail_route.dart';
import 'settings_info_page.dart';

class DataDetailsPage extends StatelessWidget {
  const DataDetailsPage({
    this.links = const SettingsLinks(),
    this.adConsent,
    super.key,
  });

  final SettingsLinks links;
  final AdConsentManager? adConsent;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    return SettingsInfoPage(
      title: loc.dataDetailsTitle,
      children: <Widget>[
        SettingsInfoPage.paragraph(context, loc.dataSummaryRates),
        SettingsInfoPage.paragraph(context, loc.dataPrivacyLine),
        DataPrivacyActions(
          links: links,
          consent: adConsent ?? AdConsentManager.instance,
          onOpenSources: () => Navigator.of(context).push(
            buildSettingsDetailRoute<void>(
              theme: Theme.of(context),
              builder: (_) => DataSourcesPage(links: links),
            ),
          ),
        ),
      ],
    );
  }
}
