import 'package:flutter/material.dart';

/// Custom color tokens for CalcPro Studio design system
class ColorTokens {
  ColorTokens._();

  // Primary gradient colors
  static const Color deepBlue = Color(0xFF1A237E);
  static const Color electricCyan = Color(0xFF00BCD4);
  
  // Dark theme
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkSurfaceVariant = Color(0xFF21262D);
  static const Color darkOnBackground = Color(0xFFE6EDF3);
  static const Color darkOnSurface = Color(0xFFC9D1D9);
  
  // Light theme
  static const Color lightBackground = Color(0xFFF6F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFE1E4E8);
  static const Color lightOnBackground = Color(0xFF1F2328);
  static const Color lightOnSurface = Color(0xFF24292F);
  
  // AMOLED theme
  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF0A0A0A);
  static const Color amoledSurfaceVariant = Color(0xFF141414);
  
  // Accent colors
  static const Color accentBlue = Color(0xFF58A6FF);
  static const Color accentGreen = Color(0xFF3FB950);
  static const Color accentRed = Color(0xFFF85149);
  static const Color accentOrange = Color(0xFFF0883E);
  static const Color accentPurple = Color(0xFFBC8CFF);
  static const Color accentYellow = Color(0xFFD29922);
  static const Color accentPink = Color(0xFFDB61A2);
  
  // Button colors
  static const Color buttonPrimary = Color(0xFF1A237E);
  static const Color buttonPrimaryLight = Color(0xFF3949AB);
  static const Color buttonSecondary = Color(0xFF2D333B);
  static const Color buttonSecondaryLight = Color(0xFFE1E4E8);
  static const Color buttonOperator = Color(0xFFF59E0B);
  static const Color buttonOperatorLight = Color(0xFFD97706);
  static const Color buttonEquals = Color(0xFF00BCD4);
  static const Color buttonEqualsLight = Color(0xFF0097A7);
  static const Color buttonClear = Color(0xFFE53935);
  static const Color buttonClearLight = Color(0xFFC62828);
  
  // Syntax highlighting
  static const Color syntaxNumber = Color(0xFF79C0FF);
  static const Color syntaxOperator = Color(0xFFFF7B72);
  static const Color syntaxFunction = Color(0xFFD2A8FF);
  static const Color syntaxParenthesis = Color(0xFFFFA657);
  static const Color syntaxVariable = Color(0xFF7EE787);
  static const Color syntaxConstant = Color(0xFF79C0FF);
  static const Color syntaxUnit = Color(0xFFA5D6FF);
  
  // Syntax highlighting - Light
  static const Color syntaxNumberLight = Color(0xFF0550AE);
  static const Color syntaxOperatorLight = Color(0xFFCF222E);
  static const Color syntaxFunctionLight = Color(0xFF8250DF);
  static const Color syntaxParenthesisLight = Color(0xFF953800);
  static const Color syntaxVariableLight = Color(0xFF116329);
  static const Color syntaxConstantLight = Color(0xFF0550AE);
  
  // Semantic colors
  static const Color error = Color(0xFFF85149);
  static const Color success = Color(0xFF3FB950);
  static const Color warning = Color(0xFFD29922);
  static const Color info = Color(0xFF58A6FF);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [deepBlue, electricCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF0D47A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient equalsGradient = LinearGradient(
    colors: [Color(0xFF00838F), Color(0xFF00BCD4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
