import 'package:flutter/material.dart';

/// Centralized design tokens for the app
class AppTokens {
  // Colors
  // Primary palette inspired by E‑Learning UI kit
  static const Color primary = Color(0xFF5B6BFD); // Indigo 600
  static const Color secondary = Color(0xFFFFC24B); // Amber 500
  static const Color tertiary = Color(0xFF7C3AED); // Violet 600 (accents)
  static const Color error = Color(0xFFEF4444);

  static const Color bg = Color(0xFFF7F9FC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color outline = Color(0xFFE5E7EB);

  // Spacing
  static const double s2 = 2;
  static const double s4 = 4;
  static const double s6 = 6;
  static const double s8 = 8;
  static const double s10 = 10;
  static const double s12 = 12;
  static const double s14 = 14;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s28 = 28;
  static const double s32 = 32;

  // Radii
  static const BorderRadius r8 = BorderRadius.all(Radius.circular(8));
  static const BorderRadius r12 = BorderRadius.all(Radius.circular(12));
  static const BorderRadius r16 = BorderRadius.all(Radius.circular(16));
  static const BorderRadius r20 = BorderRadius.all(Radius.circular(20));
  static const BorderRadius rPill = BorderRadius.all(Radius.circular(999));

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(.05),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}

class AppInsets extends EdgeInsets {
  const AppInsets.all16() : super.all(AppTokens.s16);
  const AppInsets.h16() : super.symmetric(horizontal: AppTokens.s16);
  const AppInsets.v16() : super.symmetric(vertical: AppTokens.s16);
}

TextStyle tsLabel(BuildContext context) => Theme.of(context).textTheme.titleSmall!.copyWith(
      fontWeight: FontWeight.w600,
      color: AppTokens.textSecondary,
      letterSpacing: -0.2,
    );

TextStyle tsTitle(BuildContext context) => Theme.of(context).textTheme.titleLarge!.copyWith(
      fontWeight: FontWeight.w700,
      color: AppTokens.textPrimary,
      letterSpacing: -0.2,
    );

class Elevations {
  static const double appBar = 2;
  static const double card = 3;
  static const double nav = 12;
}

