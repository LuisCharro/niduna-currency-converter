import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class DividerListRow extends StatelessWidget {
  const DividerListRow({
    required this.child,
    this.onTap,
    this.leadingAccent,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(vertical: 10),
    this.showDivider = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? leadingAccent;
  final Widget? trailing;
  final EdgeInsets padding;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final row = Padding(
      padding: padding,
      child: Row(
        children: <Widget>[
          Container(
            width: 3,
            height: 44,
            decoration: BoxDecoration(
              color: leadingAccent ?? Colors.transparent,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
          if (trailing != null) ...<Widget>[
            const SizedBox(width: 12),
            trailing!,
          ],
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: colors.border.withValues(alpha: .14),
                  width: .7,
                ),
              )
            : null,
      ),
      child: InkWell(onTap: onTap, child: row),
    );
  }
}
