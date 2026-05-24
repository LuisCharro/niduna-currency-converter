import 'package:flutter/material.dart';

import '../../core/monetization/monetization_controller.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations_safe.dart';
import '../../shared/widgets/canvas_background.dart';
import '../../shared/widgets/screen_title.dart';
import 'settings_controller.dart';
import 'widgets/base_currency_tile.dart';
import 'widgets/decimal_places_tile.dart';
import 'widgets/dev_sandbox_section.dart';
import 'widgets/premium_section.dart';
import 'widgets/settings_about_section.dart';
import 'widgets/settings_data_section.dart';
import 'widgets/section_header.dart';
import 'widgets/switch_tile.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.monetization,
    required this.preferences,
    required this.onClearCache,
    super.key,
  });

  final MonetizationController monetization;
  final AppPreferences preferences;
  final VoidCallback onClearCache;

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    final controller = SettingsController(
      preferences: preferences,
      monetization: monetization,
      onClearCache: onClearCache,
    );

    return Material(
      color: Colors.transparent,
      child: CanvasBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: Listenable.merge([monetization, preferences]),
            builder: (context, _) => Scaffold(
              backgroundColor: Colors.transparent,
              body: ListView(
                padding: EdgeInsets.fromLTRB(
                  AppTheme.pagePadding,
                  AppTheme.space6,
                  AppTheme.pagePadding,
                  AppTheme.tabScrollBottomPadding(context),
                ),
                children: <Widget>[
                  ScreenTitle(loc.tabSettings),
                  const SizedBox(height: AppTheme.space5),
                  SectionHeader(title: loc.labelConversion),
                  BaseCurrencyTile(controller: controller),
                  DecimalPlacesTile(controller: controller),
                  SwitchTile(
                    title: loc.labelDarkMode,
                    subtitle: preferences.isDarkMode
                        ? loc.labelDarkModeOn
                        : loc.labelDarkModeFollowsSystem,
                    value: preferences.isDarkMode,
                    onChanged: controller.toggleDarkMode,
                  ),
                  const SizedBox(height: AppTheme.sectionGap),
                  SettingsDataSection(controller: controller),
                  const SizedBox(height: AppTheme.sectionGap),
                  SectionHeader(title: loc.labelPremium),
                  PremiumSection(controller: controller),
                  const SizedBox(height: AppTheme.sectionGap),
                  if (preferences.devMode) ...[
                    const SectionHeader(title: 'Dev Sandbox'),
                    DevSandboxSection(monetization: monetization),
                    const SizedBox(height: AppTheme.sectionGap),
                  ],
                  SettingsAboutSection(controller: controller),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
