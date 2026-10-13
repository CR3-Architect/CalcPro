import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/color_tokens.dart';

/// Cached text styles — built once, reused everywhere
class CalcStyles {
  CalcStyles._();

  static const String mono = 'Roboto Mono';
  static const String ui = 'Inter';

  static const TextStyle digit = TextStyle(
    fontFamily: mono,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1,
  );

  static const TextStyle operator_ = TextStyle(
    fontFamily: mono,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1,
  );

  static const TextStyle equals = TextStyle(
    fontFamily: mono,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1,
  );

  static const TextStyle clear = TextStyle(
    fontFamily: ui,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1,
  );

  static const TextStyle function = TextStyle(
    fontFamily: ui,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1,
  );

  static const TextStyle memory = TextStyle(
    fontFamily: ui,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1,
  );

  static const TextStyle scientific = TextStyle(
    fontFamily: ui,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1,
  );

  static const TextStyle hexDigit = TextStyle(
    fontFamily: mono,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1,
  );

  static TextStyle forType(CalcButtonType type, bool isDark) {
    final Color color;
    switch (type) {
      case CalcButtonType.digit:
        color = isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground;
      case CalcButtonType.operator:
      case CalcButtonType.operatorOnDark:
        color = Colors.white;
      case CalcButtonType.equals:
        color = Colors.white;
      case CalcButtonType.clear:
        color = Colors.white;
      case CalcButtonType.function:
        color = isDark ? ColorTokens.accentBlue : ColorTokens.deepBlue;
      case CalcButtonType.memory:
        color = isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface;
      case CalcButtonType.scientific:
        color = ColorTokens.accentPurple;
      case CalcButtonType.hexDigit:
        color = ColorTokens.accentBlue;
    }

    final base = switch (type) {
      CalcButtonType.digit => digit,
      CalcButtonType.operator || CalcButtonType.operatorOnDark => operator_,
      CalcButtonType.equals => equals,
      CalcButtonType.clear => clear,
      CalcButtonType.function => function,
      CalcButtonType.memory => memory,
      CalcButtonType.scientific => scientific,
      CalcButtonType.hexDigit => hexDigit,
    };
    return base.copyWith(color: color);
  }
}

/// Button style types
enum CalcButtonType {
  digit,
  operator,
  function,
  equals,
  clear,
  memory,
  scientific,
  hexDigit,
  operatorOnDark,
}

/// Compact professional calculator button
class CalcButton extends StatelessWidget {
  final String text;
  final CalcButtonType type;
  final VoidCallback onPressed;
  final int flex;
  final IconData? icon;
  final bool isActive;
  final double? height;

  const CalcButton({
    super.key,
    required this.text,
    required this.type,
    required this.onPressed,
    this.flex = 1,
    this.icon,
    this.isActive = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Material(
          color: _bgColor(isDark),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.selectionClick();
              onPressed();
            },
            child: SizedBox(
              height: height,
              child: Center(
                child: icon != null
                    ? Icon(icon, size: 20, color: _iconColor(isDark))
                    : Text(text, style: CalcStyles.forType(type, isDark)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _bgColor(bool isDark) {
    switch (type) {
      case CalcButtonType.digit:
        return isDark ? ColorTokens.darkSurfaceVariant : ColorTokens.lightSurfaceVariant;
      case CalcButtonType.operator:
      case CalcButtonType.operatorOnDark:
        return isDark ? ColorTokens.buttonOperator : ColorTokens.buttonOperatorLight;
      case CalcButtonType.equals:
        return isDark ? ColorTokens.electricCyan : ColorTokens.buttonEqualsLight;
      case CalcButtonType.clear:
        return isDark ? ColorTokens.buttonClear : ColorTokens.buttonClearLight;
      case CalcButtonType.function:
        return isDark ? ColorTokens.darkSurface : Colors.white;
      case CalcButtonType.memory:
        return isDark ? const Color(0xFF1C2128) : const Color(0xFFEEF1F4);
      case CalcButtonType.scientific:
        return isDark
            ? ColorTokens.accentPurple.withOpacity(0.12)
            : ColorTokens.accentPurple.withOpacity(0.08);
      case CalcButtonType.hexDigit:
        return isDark
            ? ColorTokens.accentBlue.withOpacity(0.12)
            : ColorTokens.accentBlue.withOpacity(0.08);
    }
  }

  Color _iconColor(bool isDark) {
    switch (type) {
      case CalcButtonType.clear:
      case CalcButtonType.equals:
        return Colors.white;
      default:
        return isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground;
    }
  }
}
