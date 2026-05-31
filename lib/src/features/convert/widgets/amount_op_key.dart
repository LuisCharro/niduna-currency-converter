import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AmountOpKey extends StatelessWidget {
  const AmountOpKey({
    this.label,
    this.icon,
    required this.onTap,
    this.bgColor = false,
    super.key,
  });

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool bgColor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Expanded(
      child: Material(
        color: bgColor
            ? colors.primary.withValues(alpha: .1)
            : colors.container.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          overlayColor: WidgetStatePropertyAll(
            colors.primary.withValues(alpha: .06),
          ),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.border.withValues(alpha: .08)),
            ),
            child: Center(
              child: label != null
                  ? Text(
                      label!,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.primary,
                      ),
                    )
                  : Icon(
                      icon,
                      size: 20,
                      color: colors.text.withValues(alpha: .6),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
