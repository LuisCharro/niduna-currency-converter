import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../models/rate_card_data.dart';

/// One "Name ............ value" line on the share card. Always light colors.
class RateCardRow extends StatelessWidget {
  const RateCardRow({required this.data, super.key});

  final RateCardRowData data;

  @override
  Widget build(BuildContext context) {
    const colors = AppColors.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              data.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            data.valueLabel,
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: colors.text,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
