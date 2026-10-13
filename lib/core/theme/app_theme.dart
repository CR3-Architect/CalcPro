import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'color_tokens.dart';

/// App themes: Dark (default), Light, AMOLED
enum AppThemeMode { dark, light, amoled }

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(TextTheme base, bool isDark) {
    return base.copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground,
      ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ColorTokens.darkBackground,
        foregroundColor: ColorTokens.darkOnBackground,
        elevation: 0,
        centerTitle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ColorTokens.darkSurface,
        indicatorColor: ColorTokens.accentBlue.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? ColorTokens.accentBlue
                : ColorTokens.darkOnSurface,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: ColorTokens.darkSurfaceVariant,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: ColorTokens.darkOnSurface,
      ),
    );
  }

  static ThemeData lightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: ColorTokens.deepBlue,
      brightness: Brightness.light,
      primary: Color(0xFF1A237E),
      secondary: ColorTokens.electricCyan,
      surface: ColorTokens.lightSurface,
      error: Color(0xFFC62828),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ColorTokens.lightSurface,
        foregroundColor: ColorTokens.lightOnBackground,
        elevation: 0,
        centerTitle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ColorTokens.lightSurface,
        indicatorColor: ColorTokens.deepBlue.withOpacity(0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? ColorTokens.deepBlue
                : ColorTokens.lightOnSurface,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: ColorTokens.lightSurfaceVariant,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: ColorTokens.lightOnSurface,
      ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: ColorTokens.amoledBackground,
        foregroundColor: ColorTokens.darkOnBackground,
        elevation: 0,
        centerTitle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: ColorTokens.amoledSurface,
        indicatorColor: ColorTokens.accentBlue.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? ColorTokens.accentBlue
                : ColorTokens.darkOnSurface,
          );
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: ColorTokens.amoledSurfaceVariant,
        thickness: 1,
      ),
      iconTheme: const IconThemeData(
        color: ColorTokens.darkOnSurface,
      ),
    );
  }

  static ThemeData getTheme(AppThemeMode mode, {bool highContrast = false}) {
    final base = switch (mode) {
      AppThemeMode.dark => darkTheme(),
      AppThemeMode.light => lightTheme(),
      AppThemeMode.amoled => amoledTheme(),
    };
    if (!highContrast) return base;
    // High contrast: keep light theme text dark, only boost dark themes
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
