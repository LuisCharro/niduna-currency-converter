import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AmountKey extends StatelessWidget {
  const AmountKey({this.label, this.icon, required this.onTap, super.key});

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: colors.container.withValues(alpha: .9),
      borderRadius: BorderRadius.circular(18),
      shadowColor: colors.primary.withValues(alpha: .08),
      elevation: 1,
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
            child: icon == null
                ? Text(
                    label!,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      color: colors.text,
                    ),
                  )
                : Icon(icon, color: colors.text, size: 22),
          ),
        ),
      ),
    );
  }
}
