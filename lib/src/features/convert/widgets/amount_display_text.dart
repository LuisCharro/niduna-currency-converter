import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AdaptiveAmountText extends StatelessWidget {
  const AdaptiveAmountText({required this.display, super.key});

  final String display;

  static const List<double> _sizes = [34.0, 30.0, 26.0, 22.0];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final style = _adaptiveStyle(
          display,
          constraints.maxWidth,
          colors.text,
        );
        return AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          style: style,
          child: Text(
            display,
            key: ValueKey<String>(display),
            maxLines: 1,
            overflow: TextOverflow.visible,
          ),
        );
      },
    );
  }

  TextStyle _adaptiveStyle(String text, double maxWidth, Color textColor) {
    final baseStyle = TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.4,
      height: 1.1,
      color: textColor,
    );
    for (final fontSize in _sizes) {
      if (fontSize > baseStyle.fontSize!) break;
      final candidate = baseStyle.copyWith(fontSize: fontSize);
      final painter = TextPainter(
        text: TextSpan(text: text, style: candidate),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout(maxWidth: maxWidth);
      if (painter.didExceedMaxLines == false) {
        painter.dispose();
        return candidate;
      }
      painter.dispose();
    }
    return baseStyle.copyWith(fontSize: _sizes.last);
  }
}
