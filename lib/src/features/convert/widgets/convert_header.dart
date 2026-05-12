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
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
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
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isRefreshing ? 'Refreshing rates' : 'Private daily rates',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.caption.copyWith(color: AppTheme.muted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            onPressed: onMore,
            icon: Icon(Icons.tune_rounded, color: AppTheme.muted, size: 21),
          ),
        ],
      ),
    );
  }
}
