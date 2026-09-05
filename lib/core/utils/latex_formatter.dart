/// Converts mathematical expressions to LaTeX format for display
class LaTeXFormatter {
  LaTeXFormatter._();

  /// Convert a plain text expression to LaTeX
  static String toLatex(String expression) {
    if (expression.isEmpty) return '';
    
    String result = expression;
    
    // Replace constants
    result = result.replaceAll('π', r'\pi ');
    result = result.replaceAllMapped(
      RegExp(r'\be\b'),
      (m) => r'e ',
    );
    result = result.replaceAll('φ', r'\varphi ');
    
    // Replace common functions
    result = _replaceFunction(result, 'sin', r'\sin');
    result = _replaceFunction(result, 'cos', r'\cos');
    result = _replaceFunction(result, 'tan', r'\tan');
    result = _replaceFunction(result, 'asin', r'\arcsin');
    result = _replaceFunction(result, 'acos', r'\arccos');
    result = _replaceFunction(result, 'atan', r'\arctan');
    result = _replaceFunction(result, 'sinh', r'\sinh');
    result = _replaceFunction(result, 'cosh', r'\cosh');
    result = _replaceFunction(result, 'tanh', r'\tanh');
    result = _replaceFunction(result, 'asinh', r'\text{arcsinh}');
    result = _replaceFunction(result, 'acosh', r'\text{arccosh}');
    result = _replaceFunction(result, 'atanh', r'\text{arctanh}');
    result = _replaceFunction(result, 'log', r'\log');
    result = _replaceFunction(result, 'ln', r'\ln');
    result = _replaceFunction(result, 'sqrt', r'\sqrt');
    result = _replaceFunction(result, 'abs', r'\left|');
    
    // Replace operators
    result = result.replaceAll('×', r'\times ');
    result = result.replaceAll('÷', r'\div ');
    result = result.replaceAllMapped(
      RegExp(r'(\d+)\^(\d+)'),
      (m) => '${m.group(1)}^{${m.group(2)}}',
    );
    result = result.replaceAllMapped(
      RegExp(r'(\d+)\^(?:\{([^}]+)\})'),
      (m) => '${m.group(1)}^{${m.group(2)}}',
    );
    
    // Replace √ with \sqrt
    result = result.replaceAllMapped(
      RegExp(r'√\(([^)]+)\)'),
      (m) => r'\sqrt{' + '${m.group(1)}}',
    );
    
    // Replace integrals
    result = result.replaceAll('∫', r'\int ');
    result = result.replaceAll('∑', r'\sum ');
    result = result.replaceAll('∏', r'\prod ');
    result = result.replaceAll('∞', r'\infty ');
    
    // Replace floor/ceiling
    result = result.replaceAll('⌊', r'\lfloor ');
    result = result.replaceAll('⌋', r'\rfloor ');
    result = result.replaceAll('⌈', r'\lceil ');
    result = result.replaceAll('⌉', r'\rceil ');
    
    // Handle factorial
    result = result.replaceAll('!', '!');
    
    // Handle fractions a/b → \frac{a}{b}
    result = _handleFractions(result);
    
    return result.trim();
  }

  static String _replaceFunction(String text, String funcName, String latexFunc) {
    return text.replaceAll(funcName, '$latexFunc ');
  }

  static String _handleFractions(String text) {
    // Simple fraction pattern: a/b where a and b are numbers or simple expressions
    return text.replaceAllMapped(
      RegExp(r'(\d+(?:\.\d+)?)\s*/\s*(\d+(?:\.\d+)?)'),
      (m) => r'\frac{' + '${m.group(1)}}{${m.group(2)}}',
    );
  }

  /// Format a number for display
  static String formatNumber(double value, {int precision = 10}) {
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) {
      return value > 0 ? '∞' : '-∞';
    }
    
    // Check if the number is an integer
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    
    // For very large or very small numbers, use scientific notation
    if (value.abs() >= 1e15 || (value.abs() < 1e-6 && value != 0)) {
      return value.toStringAsExponential(precision > 6 ? 6 : precision);
    }
    
    // Trim trailing zeros
    String formatted = value.toStringAsFixed(precision);
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0+$'), '');
      formatted = formatted.replaceAll(RegExp(r'\.$'), '');
    }
    
    return formatted;
  }

  /// Format result for display, trying different precisions
  static String formatResult(double value) {
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) {
      return value > 0 ? '∞' : '-∞';
    }
    if (value == 0) return '0';
    
    // Check for exact integer
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    
    // Try progressively lower precision
    for (int precision = 10; precision >= 0; precision--) {
      String formatted = value.toStringAsFixed(precision);
      if (precision > 0) {
        formatted = formatted.replaceAll(RegExp(r'0+$'), '');
        formatted = formatted.replaceAll(RegExp(r'\.$'), '');
      }
      
      String repr = double.parse(formatted).toString();
      if (repr == formatted || precision == 0) {
        if (formatted.contains('.') || formatted.contains('e')) return formatted;
        return formatted;
      }
    }
    
    return value.toString();
  }

  /// Format large numbers with commas
  static String formatWithCommas(double value) {
    if (value.isNaN || value.isInfinite) return formatResult(value);
    
    String text = formatResult(value);
    if (text.contains('e') || text.contains('-')) return text;
    
    final parts = text.split('.');
    final intPart = parts[0];
    final sign = intPart.startsWith('-') ? '-' : '';
    final digits = intPart.replaceAll('-', '');
    
    final buffer = StringBuffer(sign);
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    
    if (parts.length > 1) {
      buffer.write('.');
      buffer.write(parts[1]);
    }
    
    return buffer.toString();
  }
}
