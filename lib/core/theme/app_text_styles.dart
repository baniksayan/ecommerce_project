import 'package:flutter/material.dart';
import '../responsive/media_query_helper.dart';

/// Typography system mapping utilizing standard modern fonts.
/// Font sizes are responsive using MediaQueryHelper.
class AppTextStyles {
  // Using generic "serif" for headings and default "sans-serif" for body
  // to give a nature-inspired, clean feel without requiring external assets.
  static const String _headingFontFamily = 'Georgia';

  static TextStyle get heading1 => TextStyle(
    fontFamily: _headingFontFamily,
    fontSize: MediaQueryHelper.responsiveFontSize(32),
    fontWeight: FontWeight.bold,
  );

  static TextStyle get heading2 => TextStyle(
    fontFamily: _headingFontFamily,
    fontSize: MediaQueryHelper.responsiveFontSize(24),
    fontWeight: FontWeight.w700,
  );

  static TextStyle get heading3 => TextStyle(
    fontFamily: _headingFontFamily,
    fontSize: MediaQueryHelper.responsiveFontSize(20),
    fontWeight: FontWeight.w600,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontSize: MediaQueryHelper.responsiveFontSize(16),
    fontWeight: FontWeight.w400,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: MediaQueryHelper.responsiveFontSize(14),
    fontWeight: FontWeight.w400,
  );

  static TextStyle get caption => TextStyle(
    fontSize: MediaQueryHelper.responsiveFontSize(12),
    fontWeight: FontWeight.w300,
  );

  static TextStyle get button => TextStyle(
    fontSize: MediaQueryHelper.responsiveFontSize(16),
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );
}
