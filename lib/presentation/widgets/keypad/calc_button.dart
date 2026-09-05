import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/color_tokens.dart';

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

/// Reusable animated calculator button
class CalcButton extends StatefulWidget {
  final String text;
  final CalcButtonType type;
  final VoidCallback onPressed;
  final int flex;
  final IconData? icon;
  final bool isActive;
  
  const CalcButton({
    super.key,
    required this.text,
    required this.type,
    required this.onPressed,
    this.flex = 1,
    this.icon,
    this.isActive = false,
  });

  @override
  State<CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<CalcButton> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Expanded(
      flex: widget.flex,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            HapticFeedback.lightImpact();
            widget.onPressed();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.92 : 1.0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              height: double.infinity,
              decoration: _getDecoration(isDark),
              child: Center(
                child: widget.icon != null
                    ? Icon(widget.icon, size: 22, color: _getIconColor(isDark))
                    : Text(widget.text, style: _getTextStyle(isDark)),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  BoxDecoration _getDecoration(bool isDark) {
    Color bgColor;
    
    switch (widget.type) {
      case CalcButtonType.digit:
        bgColor = isDark ? ColorTokens.darkSurfaceVariant : ColorTokens.lightSurfaceVariant;
        break;
      case CalcButtonType.operator:
        bgColor = isDark 
            ? ColorTokens.buttonOperator.withOpacity(0.7)
            : ColorTokens.buttonOperatorLight;
        break;
      case CalcButtonType.operatorOnDark:
        bgColor = ColorTokens.buttonOperator.withOpacity(0.7);
        break;
      case CalcButtonType.equals:
        bgColor = isDark ? ColorTokens.electricCyan : ColorTokens.buttonEqualsLight;
        break;
      case CalcButtonType.clear:
        bgColor = isDark ? ColorTokens.buttonClear.withOpacity(0.8) : ColorTokens.buttonClearLight;
        break;
      case CalcButtonType.function:
        bgColor = isDark
            ? ColorTokens.darkSurface.withOpacity(0.8)
            : ColorTokens.lightSurface.withOpacity(0.9);
        break;
      case CalcButtonType.memory:
        bgColor = isDark
            ? ColorTokens.darkSurface.withOpacity(0.6)
            : ColorTokens.lightSurface.withOpacity(0.7);
        break;
      case CalcButtonType.scientific:
        bgColor = isDark
            ? ColorTokens.accentPurple.withOpacity(0.15)
            : ColorTokens.accentPurple.withOpacity(0.1);
        break;
      case CalcButtonType.hexDigit:
        bgColor = isDark
            ? ColorTokens.accentBlue.withOpacity(0.15)
            : ColorTokens.accentBlue.withOpacity(0.1);
        break;
    }
    
    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      boxShadow: _isPressed
          ? []
          : [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }
  
  Color _getIconColor(bool isDark) {
    switch (widget.type) {
      case CalcButtonType.clear:
      case CalcButtonType.equals:
        return Colors.white;
      default:
        return isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground;
    }
  }
  
  TextStyle _getTextStyle(bool isDark) {
    Color textColor;
    double fontSize = 20;
    
    switch (widget.type) {
      case CalcButtonType.digit:
        textColor = isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground;
        fontSize = 22;
        break;
      case CalcButtonType.operator:
      case CalcButtonType.operatorOnDark:
        textColor = Colors.white;
        fontSize = 22;
        break;
      case CalcButtonType.equals:
        textColor = Colors.white;
        fontSize = 24;
        break;
      case CalcButtonType.clear:
        textColor = Colors.white;
        fontSize = 18;
        break;
      case CalcButtonType.function:
        textColor = isDark ? ColorTokens.accentBlue : ColorTokens.deepBlue;
        fontSize = 14;
        break;
      case CalcButtonType.memory:
        textColor = isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface;
        fontSize = 12;
        break;
      case CalcButtonType.scientific:
        textColor = ColorTokens.accentPurple;
        fontSize = 14;
        break;
      case CalcButtonType.hexDigit:
        textColor = ColorTokens.accentBlue;
        fontSize = 16;
        break;
    }
    
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: widget.type == CalcButtonType.equals ? FontWeight.w700 : FontWeight.w500,
      color: textColor,
    );
  }
}
