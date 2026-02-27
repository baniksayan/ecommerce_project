import 'package:flutter/material.dart';

class AppColors {
  // Base Palette defined by the theme
  static const Color teaGreen = Color(0xFFC5EFCB);
  static const Color dustyOlive = Color(0xFF647A67);
  static const Color black = Color(0xFF020402);
  static const Color carbonBlack = Color(0xFF1F241F);
  static const Color charcoalBrown = Color(0xFF3C433B);
  static const Color dustyOlive2 = Color(0xFF758173);
  static const Color mutedTeal = Color(0xFF8FA38A);
  static const Color celadon1 = Color(0xFFA9C5A0);
  static const Color celadon2 = Color(0xFFB8D2B3);
  static const Color teaGreenSoft = Color(0xFFC6DEC6);

  // Semantic Colors - Light Theme
  static const Color lightBackground = teaGreenSoft;
  static const Color lightSurface = Color(
    0xFFF0F5F0,
  ); // Very light greyish green
  static const Color lightPrimary = dustyOlive;
  static const Color lightAccent = mutedTeal;
  static const Color lightTextPrimary = carbonBlack;
  static const Color lightTextSecondary = charcoalBrown;
  static const Color lightDivider = celadon1;
  static const Color lightSuccess = Color(0xFF4CAF50);
  static const Color lightError = Color(0xFFE53935);
  static const Color lightWarning = Color(0xFFFFB300);
  static const Color lightInfo = Color(0xFF1E88E5);

  // Semantic Colors - Dark Theme
  static const Color darkBackground = black;
  static const Color darkSurface = carbonBlack;
  static const Color darkPrimary = teaGreen;
  static const Color darkAccent = celadon2;
  static const Color darkTextPrimary = teaGreenSoft;
  static const Color darkTextSecondary = celadon1;
  static const Color darkDivider = charcoalBrown;
  static const Color darkSuccess = Color(0xFF81C784);
  static const Color darkError = Color(0xFFEF5350);
  static const Color darkWarning = Color(0xFFFFCA28);
  static const Color darkInfo = Color(0xFF42A5F5);
}
