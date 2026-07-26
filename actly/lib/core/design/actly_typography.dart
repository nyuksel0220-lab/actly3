import 'dart:ui';

import 'package:actly/core/design/actly_colors.dart';
import 'package:flutter/material.dart';

abstract final class ActlyTypography {
  static const displayFamily = 'Roboto Condensed';
  static const bodyFamily = 'Roboto';
  static const dataFamily = 'monospace';

  static TextTheme textTheme() {
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: displayFamily,
        fontFamilyFallback: ['Arial Narrow', 'sans-serif-condensed'],
        fontSize: 40,
        height: 1.02,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: ActlyColors.paperBlue,
      ),
      displayMedium: TextStyle(
        fontFamily: displayFamily,
        fontFamilyFallback: ['Arial Narrow', 'sans-serif-condensed'],
        fontSize: 31,
        height: 1.08,
        fontWeight: FontWeight.w700,
        color: ActlyColors.paperBlue,
      ),
      headlineLarge: TextStyle(
        fontFamily: displayFamily,
        fontFamilyFallback: ['Arial Narrow', 'sans-serif-condensed'],
        fontSize: 26,
        height: 1.12,
        fontWeight: FontWeight.w700,
        color: ActlyColors.paperBlue,
      ),
      headlineMedium: TextStyle(
        fontFamily: displayFamily,
        fontFamilyFallback: ['Arial Narrow', 'sans-serif-condensed'],
        fontSize: 22,
        height: 1.15,
        fontWeight: FontWeight.w700,
        color: ActlyColors.paperBlue,
      ),
      titleLarge: TextStyle(
        fontFamily: bodyFamily,
        fontFamilyFallback: ['SF Pro Text', 'sans-serif'],
        fontSize: 18,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: ActlyColors.paperBlue,
      ),
      titleMedium: TextStyle(
        fontFamily: bodyFamily,
        fontFamilyFallback: ['SF Pro Text', 'sans-serif'],
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: ActlyColors.paperBlue,
      ),
      bodyLarge: TextStyle(
        fontFamily: bodyFamily,
        fontFamilyFallback: ['SF Pro Text', 'sans-serif'],
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: ActlyColors.paperBlue,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFamily,
        fontFamilyFallback: ['SF Pro Text', 'sans-serif'],
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: ActlyColors.paperBlue,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFamily,
        fontFamilyFallback: ['SF Pro Text', 'sans-serif'],
        fontSize: 12,
        height: 1.35,
        color: ActlyColors.mutedSteel,
      ),
      labelLarge: TextStyle(
        fontFamily: bodyFamily,
        fontFamilyFallback: ['SF Pro Text', 'sans-serif'],
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: ActlyColors.paperBlue,
      ),
      labelMedium: TextStyle(
        fontFamily: dataFamily,
        fontFamilyFallback: ['Roboto Mono', 'Menlo'],
        fontFeatures: [FontFeature.tabularFigures()],
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: ActlyColors.mutedSteel,
      ),
    );
  }

  static TextStyle data({
    double size = 20,
    FontWeight weight = FontWeight.w700,
    Color color = ActlyColors.paperBlue,
  }) {
    return TextStyle(
      fontFamily: dataFamily,
      fontFamilyFallback: const ['Roboto Mono', 'Menlo'],
      fontFeatures: const [FontFeature.tabularFigures()],
      fontSize: size,
      height: 1.0,
      fontWeight: weight,
      color: color,
    );
  }
}
