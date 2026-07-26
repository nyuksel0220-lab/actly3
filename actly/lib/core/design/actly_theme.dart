import 'package:actly/core/design/actly_colors.dart';
import 'package:actly/core/design/actly_typography.dart';
import 'package:flutter/material.dart';

abstract final class ActlyTheme {
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: ActlyColors.signalCyan,
      brightness: Brightness.dark,
      primary: ActlyColors.signalCyan,
      secondary: ActlyColors.rescueAmber,
      surface: ActlyColors.panelBlue,
      error: ActlyColors.faultRed,
    );

    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: ActlyColors.inkNavy,
      textTheme: ActlyTypography.textTheme(),
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
    );

    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );

    return base.copyWith(
      dividerColor: ActlyColors.divider,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ActlyColors.blueprintBlue,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ActlyColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: ActlyColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: ActlyColors.signalCyan, width: 2),
        ),
        labelStyle: const TextStyle(color: ActlyColors.mutedSteel),
        hintStyle: TextStyle(
          color: ActlyColors.mutedSteel.withValues(alpha: 0.75),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 50)),
          shape: const WidgetStatePropertyAll(shape),
          backgroundColor:
              const WidgetStatePropertyAll(ActlyColors.signalCyan),
          foregroundColor:
              const WidgetStatePropertyAll(ActlyColors.inkNavy),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          overlayColor: WidgetStatePropertyAll(
            ActlyColors.paperBlue.withValues(alpha: 0.10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 50)),
          shape: const WidgetStatePropertyAll(shape),
          foregroundColor:
              const WidgetStatePropertyAll(ActlyColors.paperBlue),
          side: const WidgetStatePropertyAll(
            BorderSide(color: ActlyColors.divider),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 48)),
          foregroundColor:
              const WidgetStatePropertyAll(ActlyColors.signalCyan),
          shape: const WidgetStatePropertyAll(shape),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: ActlyColors.paperBlue,
        contentTextStyle: TextStyle(color: ActlyColors.inkNavy),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: ActlyColors.panelBlue,
        shape: shape,
        titleTextStyle: ActlyTypography.textTheme().headlineMedium,
        contentTextStyle: ActlyTypography.textTheme().bodyMedium,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ActlyColors.panelBlue,
        modalBackgroundColor: ActlyColors.panelBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        ),
      ),
    );
  }
}
