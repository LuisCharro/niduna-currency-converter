import 'package:flutter/material.dart';

import '../../core/monetization/monetization_controller.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/theme/app_theme.dart';
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
    final controller = SettingsController(
      preferences: preferences,
      monetization: monetization,
      onClearCache: onClearCache,
    );

    return Material(
      color: AppTheme.bg,
      child: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([monetization, preferences]),
          builder: (context, _) => Scaffold(
            backgroundColor: AppTheme.bg,
            body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 118),
              children: <Widget>[
                const Text(
                  'Settings',
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 20),
                const SectionHeader(title: 'Conversion'),
                BaseCurrencyTile(controller: controller),
                DecimalPlacesTile(controller: controller),
                SwitchTile(
                  title: 'Dark mode',
                  subtitle: 'Follow system default',
                  value: preferences.isDarkMode,
                  onChanged: controller.toggleDarkMode,
                ),
                const SizedBox(height: 24),
                SettingsDataSection(controller: controller),
                const SizedBox(height: 24),
                const SectionHeader(title: 'Premium'),
                PremiumSection(controller: controller),
                const SizedBox(height: 24),
                if (preferences.devMode) ...[
                  const SectionHeader(title: 'Dev Sandbox'),
                  DevSandboxSection(monetization: monetization),
                  const SizedBox(height: 24),
                ],
                SettingsAboutSection(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
