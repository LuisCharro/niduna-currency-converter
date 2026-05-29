import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class NidunaRefreshIndicator extends StatelessWidget {
  const NidunaRefreshIndicator({
    required this.child,
    required this.onRefresh,
    super.key,
  });

  final Widget child;
  final RefreshCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: colors.trendUp,
      backgroundColor: colors.card,
      edgeOffset: 20,
      displacement: 20,
      strokeWidth: 2.5,
      child: child,
    );
  }
}
