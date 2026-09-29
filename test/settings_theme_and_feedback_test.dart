import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:currency_converter/src/core/monetization/monetization_controller.dart';
import 'package:currency_converter/src/core/preferences/app_preferences.dart';
import 'package:currency_converter/src/features/settings/settings_controller.dart';
import 'package:currency_converter/src/features/settings/settings_screen.dart';

/// Records launch requests instead of touching a platform channel, so
/// SettingsController.sendFeedback / openPrivacyPolicy can be exercised in a
/// plain widget test.
class _FakeUrlLauncher extends UrlLauncherPlatform {
  _FakeUrlLauncher({this.launchResult = true});

  final bool launchResult;
  String? lastLaunchedUrl;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => launchResult;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    lastLaunchedUrl = url;
    return launchResult;
  }
}

void main() {
  late SharedPreferences prefs;
  late AppPreferences preferences;
  late MonetizationController monetization;
  late SettingsController controller;
  late UrlLauncherPlatform originalLauncher;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    preferences = AppPreferences(prefs);
    monetization = MonetizationController(prefs);
    controller = SettingsController(
      preferences: preferences,
      monetization: monetization,
      onClearCache: () {},
    );
    originalLauncher = UrlLauncherPlatform.instance;
  });

  tearDown(() {
    UrlLauncherPlatform.instance = originalLauncher;
    controller.dispose();
  });

  Future<void> pumpSettings(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsScreen(controller: controller, preferences: preferences),
      ),
    );
  }

  group('Theme mode selector', () {
    testWidgets('defaults to System selected', (tester) async {
      await pumpSettings(tester);
      expect(preferences.themeMode, AppThemeMode.system);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('tapping Dark switches the persisted theme mode', (
      tester,
    ) async {
      await pumpSettings(tester);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(preferences.themeMode, AppThemeMode.dark);
      expect(prefs.getString('pref_theme_mode'), 'dark');
    });

    testWidgets('tapping Light then System updates the mode each time', (
      tester,
    ) async {
      await pumpSettings(tester);

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(preferences.themeMode, AppThemeMode.light);

      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();
      expect(preferences.themeMode, AppThemeMode.system);
    });
  });

  group('Send feedback tile', () {
    testWidgets('is present in the About section', (tester) async {
      await pumpSettings(tester);
      await tester.dragUntilVisible(
        find.text('Send feedback'),
        find.byType(Scrollable),
        const Offset(0, -300),
      );
      expect(find.byKey(const Key('send_feedback')), findsOneWidget);
      expect(
        find.text('Questions, ideas or bugs — we read everything'),
        findsOneWidget,
      );
    });

    testWidgets('tapping it launches a mailto link via the controller', (
      tester,
    ) async {
      final fake = _FakeUrlLauncher();
      UrlLauncherPlatform.instance = fake;
      await pumpSettings(tester);

      await tester.dragUntilVisible(
        find.text('Send feedback'),
        find.byType(Scrollable),
        const Offset(0, -300),
      );
      await tester.tap(find.text('Send feedback'));
      await tester.pumpAndSettle();

      expect(fake.lastLaunchedUrl, isNotNull);
      expect(fake.lastLaunchedUrl, startsWith('mailto:support@honestfern.com'));
      expect(fake.lastLaunchedUrl, contains('subject='));
    });

    testWidgets('shows a snackbar with the address when no email app exists', (
      tester,
    ) async {
      final fake = _FakeUrlLauncher(launchResult: false);
      UrlLauncherPlatform.instance = fake;
      await pumpSettings(tester);

      await tester.dragUntilVisible(
        find.text('Send feedback'),
        find.byType(Scrollable),
        const Offset(0, -300),
      );
      await tester.tap(find.text('Send feedback'));
      await tester.pumpAndSettle();

      expect(find.textContaining('support@honestfern.com'), findsWidgets);
    });
  });
}
