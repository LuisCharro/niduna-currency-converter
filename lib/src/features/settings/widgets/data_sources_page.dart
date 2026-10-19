import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../settings_links.dart';
import 'settings_info_page.dart';

class DataSourcesPage extends StatelessWidget {
  const DataSourcesPage({this.links = const SettingsLinks(), super.key});

  final SettingsLinks links;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final external = Icon(
      Icons.open_in_new_rounded,
      color: AppColors.of(context).subtle,
    );
    return SettingsInfoPage(
      title: loc.rateSourcesTitle,
      children: <Widget>[
        SettingsInfoPage.paragraph(context, loc.rateSourcesIntro),
        SettingsTile(
          title: 'Frankfurter',
          subtitle: loc.fiatDataTitle,
          trailing: external,
          onTap: links.openFiatSource,
        ),
        SettingsTile(
          title: 'exchange-api · fawazahmed0',
          subtitle: loc.cryptoDataTitle,
          trailing: external,
          onTap: links.openCryptoSource,
          showDivider: false,
        ),
      ],
    );
  }
}
