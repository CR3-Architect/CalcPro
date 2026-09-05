/// Validation helpers for calculator input
class Validators {
  Validators._();

  /// Check if the expression has balanced parentheses
  static bool hasBalancedParentheses(String expression) {
    int depth = 0;
    for (int i = 0; i < expression.length; i++) {
      if (expression[i] == '(') {
        depth++;
      } else if (expression[i] == ')') {
        depth--;
        if (depth < 0) return false;
      }
    }
    return depth == 0;
  }

  /// Check if the expression is valid for evaluation
  static ValidationResult validateExpression(String expression) {
    if (expression.isEmpty) {
      return ValidationResult(false, 'Expression is empty');
    }
    
    if (!hasBalancedParentheses(expression)) {
      return ValidationResult(false, 'Unbalanced parentheses');
    }
    
    // Check for invalid characters (allow math symbols)
    final validChars = RegExp(
      r'^[0-9+\-×÷/().%^!|, \t\na-zA-Zπeφ√∫∑∏∞⌊⌋⌈⌉°]+$',
    );
    if (!validChars.hasMatch(expression)) {
      return ValidationResult(false, 'Invalid characters in expression');
    }
    
    // Check for consecutive operators (except - which can be unary)
    if (RegExp(r'[+\×÷/]{2,}').hasMatch(expression)) {
      return ValidationResult(false, 'Consecutive operators');
    }
    
    // Check for operator at end
    if (RegExp(r'[+\-×÷/]$').hasMatch(expression.trim())) {
      return ValidationResult(false, 'Expression ends with operator');
    }
    
    return ValidationResult(true, null);
  }

  /// Check if a string can be parsed as a number
  static bool isNumeric(String s) {
    if (s.isEmpty) return false;
    return double.tryParse(s) != null;
  }

  /// Check if a character is an operator
  static bool isOperator(String char) {
    return '+-×÷/%'.contains(char);
  }

  /// Check if a character is a digit or decimal point
  static bool isDigitOrDecimal(String char) {
    return RegExp(r'[0-9.]').hasMatch(char);
  }

  /// Check if a string is a function name
  static bool isFunction(String name) {
    const functions = {
      'sin', 'cos', 'tan', 'asin', 'acos', 'atan',
      'sinh', 'cosh', 'tanh', 'asinh', 'acosh', 'atanh',
      'log', 'ln', 'sqrt', 'abs', 'ceil', 'floor',
      'factorial', 'exp', 'pow', 'root',
      'nPr', 'nCr',
    };
    return functions.contains(name.toLowerCase());
  }

  /// Validate matrix dimensions
  static ValidationResult validateMatrixDimensions(int rows, int cols) {
    if (rows < 1 || rows > 10) {
      return ValidationResult(false, 'Rows must be between 1 and 10');
    }
    if (cols < 1 || cols > 10) {
      return ValidationResult(false, 'Columns must be between 1 and 10');
    }
    return ValidationResult(true, null);
  }

  /// Validate a number input for a specific base
  static ValidationResult validateBaseInput(String input, int base) {
    if (input.isEmpty) return ValidationResult(true, null);
    
    String validChars;
    switch (base) {
      case 2:
        validChars = '01';
        break;
      case 8:
        validChars = '01234567';
        break;
      case 10:
        validChars = '0123456789';
        break;
      case 16:
        validChars = '0123456789ABCDEFabcdef';
        break;
      default:
        return ValidationResult(false, 'Invalid base');
    }
    
    for (int i = 0; i < input.length; i++) {
      if (!validChars.contains(input[i])) {
        return ValidationResult(
          false,
          'Invalid digit "${input[i]}" for base $base',
        );
      }
    }
    
    return ValidationResult(true, null);
  }
}

/// Result of a validation check
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult(this.isValid, this.errorMessage);

  @override
  String toString() {
    if (isValid) return 'Valid';
    return 'Invalid: $errorMessage';
  }
}
