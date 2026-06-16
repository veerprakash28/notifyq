import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized Material 3 theme definitions.
/// Switching between light and dark is done by passing [ThemeData.light] vs
/// [ThemeData.dark] — no inline styling needed in widgets.
class AppTheme {
  AppTheme._();

  static const _fontFamily = 'Outfit';

  // ── Light Theme ──────────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surfaceLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: _buildTextTheme(base.textTheme, AppColors.textPrimaryLight),
      appBarTheme: _appBarTheme(AppColors.backgroundLight, AppColors.textPrimaryLight),
      cardTheme: _cardTheme(AppColors.surfaceLight),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: _inputDecorationTheme(),
      elevatedButtonTheme: _elevatedButtonTheme(),
      chipTheme: _chipTheme(),
    );
  }

  // ── Dark Theme ───────────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        error: AppColors.error,
        surface: AppColors.surfaceDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _buildTextTheme(base.textTheme, AppColors.textPrimaryDark),
      appBarTheme: _appBarTheme(AppColors.backgroundDark, AppColors.textPrimaryDark),
      cardTheme: _cardTheme(AppColors.cardDark),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      inputDecorationTheme: _inputDecorationTheme(isDark: true),
      elevatedButtonTheme: _elevatedButtonTheme(),
      chipTheme: _chipTheme(),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static TextTheme _buildTextTheme(TextTheme base, Color textColor) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontFamily: _fontFamily, color: textColor, fontWeight: FontWeight.w700),
      displayMedium: base.displayMedium?.copyWith(fontFamily: _fontFamily, color: textColor, fontWeight: FontWeight.w600),
      headlineLarge: base.headlineLarge?.copyWith(fontFamily: _fontFamily, color: textColor, fontWeight: FontWeight.w700, fontSize: 26),
      headlineMedium: base.headlineMedium?.copyWith(fontFamily: _fontFamily, color: textColor, fontWeight: FontWeight.w600, fontSize: 22),
      headlineSmall: base.headlineSmall?.copyWith(fontFamily: _fontFamily, color: textColor, fontWeight: FontWeight.w600, fontSize: 18),
      titleLarge: base.titleLarge?.copyWith(fontFamily: _fontFamily, color: textColor, fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(fontFamily: _fontFamily, color: textColor, fontWeight: FontWeight.w500),
      titleSmall: base.titleSmall?.copyWith(fontFamily: _fontFamily, color: textColor),
      bodyLarge: base.bodyLarge?.copyWith(fontFamily: _fontFamily, color: textColor),
      bodyMedium: base.bodyMedium?.copyWith(fontFamily: _fontFamily, color: textColor),
      bodySmall: base.bodySmall?.copyWith(fontFamily: _fontFamily, color: textColor.withOpacity(0.7)),
      labelLarge: base.labelLarge?.copyWith(fontFamily: _fontFamily, color: textColor, fontWeight: FontWeight.w600),
    );
  }

  static AppBarTheme _appBarTheme(Color bg, Color fg) => AppBarTheme(
        backgroundColor: bg,
        foregroundColor: fg,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: fg,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      );

  static CardThemeData _cardTheme(Color color) => CardThemeData(
        color: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
      );

  static InputDecorationTheme _inputDecorationTheme({bool isDark = false}) =>
      InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.cardDark : AppColors.cardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  static ElevatedButtonThemeData _elevatedButtonTheme() =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      );

  static ChipThemeData _chipTheme() => ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        labelStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 12),
      );
}
