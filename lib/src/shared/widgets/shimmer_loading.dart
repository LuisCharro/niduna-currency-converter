import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class ShimmerLoading extends StatefulWidget {
  const ShimmerLoading({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment(-1.5, 0),
          end: Alignment(1.5, 0),
          colors: <Color>[
            Colors.transparent,
            Colors.white.withValues(alpha: .15),
            Colors.white.withValues(alpha: .15),
            Colors.transparent,
          ],
          stops: const <double>[0, .35, .65, 1],
        ).animate(_controller).value.evaluate(bounds),
        child: widget.child,
      ),
    );
  }
}

class RateRowSkeleton extends StatelessWidget {
  const RateRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.border.withValues(alpha: .12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: colors.border.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 50,
                  height: 11,
                  decoration: BoxDecoration(
                    color: colors.border.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 72,
            height: 20,
            decoration: BoxDecoration(
              color: colors.border.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
          ),
        ],
      ),
    );
  }
}
