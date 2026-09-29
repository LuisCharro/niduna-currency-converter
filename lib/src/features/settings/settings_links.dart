import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations_safe.dart';

/// Launches Settings' outbound links (privacy policy, support email).
///
/// Extracted from [SettingsController] to keep the controller within the
/// project's controller line budget; behavior is unchanged.
class SettingsLinks {
  const SettingsLinks();

  static final Uri _privacyPolicyUri = Uri.parse(
    'https://honestfern.com/currency-converter/privacy/',
  );
  static const String feedbackEmailAddress = 'support@honestfern.com';

  Future<void> openPrivacyPolicy() async {
    await launchUrl(_privacyPolicyUri, mode: LaunchMode.externalApplication);
  }

  Future<void> sendFeedback(BuildContext context, String appVersion) async {
    final loc = l10n(context);
    final uri = Uri(
      scheme: 'mailto',
      path: feedbackEmailAddress,
      queryParameters: {'subject': loc.feedbackEmailSubject(appVersion)},
    );
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.snackNoEmailApp(feedbackEmailAddress))),
      );
    }
  }
}
