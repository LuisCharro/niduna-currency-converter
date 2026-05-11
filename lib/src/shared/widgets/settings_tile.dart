import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radius),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title,
                      style:
                          const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppTheme.caption),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
