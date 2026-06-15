import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../models/rate_card_data.dart';
import 'rate_card_row.dart';

/// The branded, always-light rate card rendered off-screen and shared as PNG.
/// Fixed width so it lays out under loose (off-screen) constraints.
class RateCardImage extends StatelessWidget {
  const RateCardImage({required this.data, super.key});

  static const double width = 360;
  final RateCardData data;

  @override
  Widget build(BuildContext context) {
    const colors = AppColors.light;
    final divider = Divider(
      color: colors.border.withValues(alpha: .5),
      height: 24,
      thickness: 1,
    );
    return Theme(
      data: AppTheme.light,
      child: Container(
        width: width,
        color: colors.bg,
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Niduna · Currency',
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              data.baseAmountLabel,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: colors.text,
              ),
            ),
            divider,
            for (final row in data.rows) RateCardRow(data: row),
            divider,
            Text(
              data.footerLabel,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: colors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
