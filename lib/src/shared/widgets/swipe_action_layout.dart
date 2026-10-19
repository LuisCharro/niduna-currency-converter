import '../../core/theme/app_theme.dart';

/// Shared geometry for swipe actions, independent of the content row height.
class SwipeActionLayout {
  static const double buttonWidth = 60;
  static const double trayHeight = AppTheme.rowMinHeight;
  static const double leadingSpace = 64;
  static const double singleReveal = leadingSpace + buttonWidth;
  static const double convertReveal = leadingSpace + 3 * buttonWidth;
}
