import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations_safe.dart';
import '../../../shared/widgets/settings_tile.dart';
import '../settings_controller.dart';

/// Opens the user's email app with a pre-filled feedback address and
/// subject. Fetches the app version itself (same source as [VersionTile])
/// and hands it to [SettingsController.sendFeedback], which owns the
/// mailto-launch logic and the no-email-app fallback.
class SendFeedbackTile extends StatefulWidget {
  const SendFeedbackTile({required this.controller, super.key});

  final SettingsController controller;

  @override
  State<SendFeedbackTile> createState() => _SendFeedbackTileState();
}

class _SendFeedbackTileState extends State<SendFeedbackTile> {
  String _appVersion = '--';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _appVersion = info.version);
  }

  @override
  Widget build(BuildContext context) {
    final loc = l10n(context);
    return SettingsTile(
      key: const Key('send_feedback'),
      title: loc.labelSendFeedback,
      subtitle: loc.sendFeedbackSubtitle,
      onTap: () => widget.controller.sendFeedback(context, _appVersion),
      trailing: Icon(
        Icons.mail_outline_rounded,
        color: AppColors.of(context).subtle,
      ),
    );
  }
}
