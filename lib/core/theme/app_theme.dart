import 'package:flutter/material.dart';
import 'color_tokens.dart';

/// App themes: Dark (default), Light, AMOLED
enum AppThemeMode { dark, light, amoled }

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(TextTheme base, bool isDark) {
    final fg = isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground;
    final sub = isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface;
    return base.copyWith(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, color: fg),
      displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: fg),
      displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400, color: fg),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: fg),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: fg),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: fg),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: fg),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.15, color: fg),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: fg),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: sub),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: sub),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: sub),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: fg),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: fg),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: fg),
    );
  }

  static ThemeData darkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ColorTokens.deepBlue,
      brightness: Brightness.dark,
      primary: ColorTokens.accentBlue,
      secondary: ColorTokens.electricCyan,
      surface: ColorTokens.darkSurface,
      error: ColorTokens.error,
    );

    final textTheme = _buildTextTheme(ThemeData.dark().textTheme, true);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: ColorTokens.darkBackground,
      cardTheme: CardThemeData(
        color: ColorTokens.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ColorTokens.darkBackground,
        foregroundColor: ColorTokens.darkOnBackground,
        elevation: 0,
        centerTitle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ColorTokens.darkSurface,
        indicatorColor: ColorTokens.accentBlue.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? ColorTokens.accentBlue
                : ColorTokens.darkOnSurface,
          );
        }),
      ),
      dividerTheme: DividerThemeData(color: ColorTokens.darkSurfaceVariant, thickness: 1),
      iconTheme: const IconThemeData(color: ColorTokens.darkOnSurface),
    );
  }

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ColorTokens.deepBlue,
      brightness: Brightness.light,
      primary: const Color(0xFF1A237E),
      secondary: ColorTokens.electricCyan,
      surface: ColorTokens.lightSurface,
      error: const Color(0xFFC62828),
    );

    final textTheme = _buildTextTheme(ThemeData.light().textTheme, false);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: ColorTokens.lightBackground,
      cardTheme: CardThemeData(
        color: ColorTokens.lightSurface,
        elevation: 1,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ColorTokens.lightSurface,
        foregroundColor: ColorTokens.lightOnBackground,
        elevation: 0,
        centerTitle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ColorTokens.lightSurface,
        indicatorColor: ColorTokens.deepBlue.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? ColorTokens.deepBlue
                : ColorTokens.lightOnSurface,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(color: ColorTokens.lightSurfaceVariant, thickness: 1),
      iconTheme: const IconThemeData(color: ColorTokens.lightOnSurface),
    );
  }

  static ThemeData amoledTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ColorTokens.deepBlue,
      brightness: Brightness.dark,
      primary: ColorTokens.accentBlue,
      secondary: ColorTokens.electricCyan,
      surface: ColorTokens.amoledSurface,
      error: ColorTokens.error,
    );

    final textTheme = _buildTextTheme(ThemeData.dark().textTheme, true);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: ColorTokens.amoledBackground,
      cardTheme: CardThemeData(
        color: ColorTokens.amoledSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ColorTokens.amoledBackground,
        foregroundColor: ColorTokens.darkOnBackground,
        elevation: 0,
        centerTitle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ColorTokens.amoledSurface,
        indicatorColor: ColorTokens.accentBlue.withValues(alpha: 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? ColorTokens.accentBlue
                : ColorTokens.darkOnSurface,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(color: ColorTokens.amoledSurfaceVariant, thickness: 1),
      iconTheme: const IconThemeData(color: ColorTokens.darkOnSurface),
    );
  }

  static ThemeData getTheme(AppThemeMode mode, {bool highContrast = false}) {
    final base = switch (mode) {
      AppThemeMode.dark => darkTheme(),
      AppThemeMode.light => lightTheme(),
      AppThemeMode.amoled => amoledTheme(),
    };
    if (!highContrast) return base;
    if (mode == AppThemeMode.light) {
      return base.copyWith(
        textTheme: base.textTheme.apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
          decorationColor: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
      );
    }
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
        decorationColor: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.black,
    );
  }
}
