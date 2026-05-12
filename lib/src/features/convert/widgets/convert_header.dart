import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ConvertHeader extends StatelessWidget {
  const ConvertHeader({
    required this.isRefreshing,
    required this.onMore,
    super.key,
  });

  final bool isRefreshing;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Convert',
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isRefreshing
                      ? 'Refreshing rates now'
                      : 'Private daily rates · no tracking',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.caption.copyWith(color: AppTheme.muted),
                ),
              ],
            ),
          ),
          _SettingsAction(label: 'Settings', onTap: onMore),
        ],
      ),
    );
  }
}

class _SettingsAction extends StatelessWidget {
  const _SettingsAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      button: true,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(Icons.tune_rounded, color: AppTheme.muted, size: 21),
          ),
        ),
      ),
    );
  }
}
