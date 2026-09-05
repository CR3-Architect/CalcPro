import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/color_tokens.dart';

/// Theme switcher widget
class ThemeSwitcher extends StatelessWidget {
  final AppThemeMode currentTheme;
  final ValueChanged<AppThemeMode> onThemeChanged;
  
  const ThemeSwitcher({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppThemeMode.values.map((mode) {
        final isSelected = mode == currentTheme;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onThemeChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? ColorTokens.electricCyan.withOpacity(0.15)
                    : (mode == AppThemeMode.dark
                        ? ColorTokens.darkSurface
                        : mode == AppThemeMode.light
                            ? ColorTokens.lightSurface
                            : ColorTokens.amoledSurface),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? ColorTokens.electricCyan : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIcon(mode),
                    color: isSelected
                        ? ColorTokens.electricCyan
                        : (mode == AppThemeMode.dark || mode == AppThemeMode.amoled
                            ? ColorTokens.darkOnSurface
                            : ColorTokens.lightOnSurface),
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode.name[0].toUpperCase() + mode.name.substring(1),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? ColorTokens.electricCyan
                          : (mode == AppThemeMode.dark || mode == AppThemeMode.amoled
                              ? ColorTokens.darkOnSurface
                              : ColorTokens.lightOnSurface),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  IconData _getIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.amoled:
        return Icons.brightness_1_rounded;
    }
  }
}
