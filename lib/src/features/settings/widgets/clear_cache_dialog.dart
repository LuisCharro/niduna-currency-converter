import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations_safe.dart';

/// Confirmation dialog for "clear all data", shared by [SettingsController].
Future<void> showClearCacheDialog(
  BuildContext context, {
  required VoidCallback onConfirm,
}) {
  final loc = l10n(context);
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(loc.clearDataDialogTitle),
      content: Text(loc.labelClearAllDataSubtitle),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(loc.btnCancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            onConfirm();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(loc.snackCacheCleared)));
          },
          child: Text(
            loc.btnClear,
            style: TextStyle(color: Colors.red.shade400),
          ),
        ),
      ],
    ),
  );
}
