import 'package:flutter/material.dart';

class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.text,
    required this.muted,
    required this.subtle,
    required this.card,
    required this.container,
    required this.containerHigh,
    required this.border,
    required this.primary,
    required this.trendUp,
    required this.trendDown,
    required this.greenBadge,
    required this.greenBadgeText,
    required this.coralSurface,
    required this.coralInk,
  });

  final Color bg;
  final Color text;
  final Color muted;
  final Color subtle;
  final Color card;
  final Color container;
  final Color containerHigh;
  final Color border;
  final Color primary;
  final Color trendUp;
  final Color trendDown;
  final Color greenBadge;
  final Color greenBadgeText;
  final Color coralSurface;
  final Color coralInk;

  static const light = AppColors(
    bg: Color(0xFFF5F4F0),
    text: Color(0xFF1C1F18),
    muted: Color(0xFF6B7560),
    subtle: Color(0xFF8A9178),
    card: Color(0xFFFFFFFF),
    container: Color(0xFFFFFFFF),
    containerHigh: Color(0xFFF0EDE9),
    border: Color(0xFF3B5D24),
    primary: Color(0xFF285F3B),
    trendUp: Color(0xFF6F8C49),
    trendDown: Color(0xFFDC6543),
    greenBadge: Color(0xFFEDF5EB),
    greenBadgeText: Color(0xFF3D6E2C),
    coralSurface: Color(0xFFFDF0EC),
    coralInk: Color(0xFFB54E48),
  );

  static const dark = AppColors(
    bg: Color(0xFF141A11),
    text: Color(0xFFE8ECE2),
    muted: Color(0xFF8A9A7E),
    subtle: Color(0xFF7A8B70),
    card: Color(0xFF1E2D18),
    container: Color(0xFF243520),
    containerHigh: Color(0xFF2A3D24),
    border: Color(0xFF4D7E32),
    primary: Color(0xFF6F8C49),
    trendUp: Color(0xFF8AAE62),
    trendDown: Color(0xFFE87A5A),
    greenBadge: Color(0xFF2A4024),
    greenBadgeText: Color(0xFF8CC47A),
    coralSurface: Color(0xFF3A2520),
    coralInk: Color(0xFFE07A6E),
  );

  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ?? light;
  }

  @override
  AppColors copyWith({
    Color? bg,
    Color? text,
    Color? muted,
    Color? subtle,
    Color? card,
    Color? container,
    Color? containerHigh,
    Color? border,
    Color? primary,
    Color? trendUp,
    Color? trendDown,
    Color? greenBadge,
    Color? greenBadgeText,
    Color? coralSurface,
    Color? coralInk,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      subtle: subtle ?? this.subtle,
      card: card ?? this.card,
      container: container ?? this.container,
      containerHigh: containerHigh ?? this.containerHigh,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      trendUp: trendUp ?? this.trendUp,
      trendDown: trendDown ?? this.trendDown,
      greenBadge: greenBadge ?? this.greenBadge,
      greenBadgeText: greenBadgeText ?? this.greenBadgeText,
      coralSurface: coralSurface ?? this.coralSurface,
      coralInk: coralInk ?? this.coralInk,
    );
  }

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      subtle: Color.lerp(subtle, other.subtle, t)!,
      card: Color.lerp(card, other.card, t)!,
      container: Color.lerp(container, other.container, t)!,
      containerHigh: Color.lerp(containerHigh, other.containerHigh, t)!,
      border: Color.lerp(border, other.border, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      trendUp: Color.lerp(trendUp, other.trendUp, t)!,
      trendDown: Color.lerp(trendDown, other.trendDown, t)!,
      greenBadge: Color.lerp(greenBadge, other.greenBadge, t)!,
      greenBadgeText: Color.lerp(greenBadgeText, other.greenBadgeText, t)!,
      coralSurface: Color.lerp(coralSurface, other.coralSurface, t)!,
      coralInk: Color.lerp(coralInk, other.coralInk, t)!,
    );
  }
}
