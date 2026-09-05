import 'lexer.dart';

/// Shunting-yard algorithm: Infix → Postfix (RPN)
class RPNConverter {
  RPNConverter._();
  
  /// Convert a list of tokens to Reverse Polish Notation
  static List<Token> toRPN(List<Token> tokens) {
    final output = <Token>[];
    final stack = <Token>[];
    
    for (final token in tokens) {
      switch (token.type) {
        case TokenType.number:
          output.add(token);
          break;
          
        case TokenType.identifier:
          stack.add(token);
          break;
          
        case TokenType.leftParen:
          stack.add(token);
          break;
          
        case TokenType.rightParen:
          while (stack.isNotEmpty && stack.last.type != TokenType.leftParen) {
            output.add(stack.removeLast());
          }
          if (stack.isNotEmpty) stack.removeLast(); // Remove left paren
          // If identifier on top, pop it (function)
          if (stack.isNotEmpty && stack.last.type == TokenType.identifier) {
            output.add(stack.removeLast());
          }
          break;
          
        case TokenType.comma:
          while (stack.isNotEmpty && stack.last.type != TokenType.leftParen) {
            output.add(stack.removeLast());
          }
          break;
          
        case TokenType.plus:
        case TokenType.minus:
          while (stack.isNotEmpty && 
                 _isOperator(stack.last.type) && 
                 _precedence(stack.last.type) >= _precedence(token.type)) {
            output.add(stack.removeLast());
          }
          stack.add(token);
          break;
          
        case TokenType.multiply:
        case TokenType.divide:
        case TokenType.modulo:
          while (stack.isNotEmpty && 
                 _isOperator(stack.last.type) && 
                 _precedence(stack.last.type) > _precedence(token.type)) {
            output.add(stack.removeLast());
          }
          stack.add(token);
          break;
          
        case TokenType.power:
          // Right-associative
          while (stack.isNotEmpty && 
                 _isOperator(stack.last.type) && 
                 _precedence(stack.last.type) > _precedence(token.type)) {
            output.add(stack.removeLast());
          }
          stack.add(token);
          break;
          
        case TokenType.factorial:
          output.add(token);
          break;
          
        case TokenType.nPr:
        case TokenType.nCr:
          while (stack.isNotEmpty && 
                 _isOperator(stack.last.type) && 
                 _precedence(stack.last.type) >= _precedence(token.type)) {
            output.add(stack.removeLast());
          }
          stack.add(token);
          break;
          
        case TokenType.percent:
          output.add(token);
          break;
          
        case TokenType.dot:
          output.add(token);
          break;
          
        case TokenType.eof:
          break;
      }
    }
    
    while (stack.isNotEmpty) {
      if (stack.last.type == TokenType.leftParen) {
        throw FormatException('Mismatched parentheses');
      }
      output.add(stack.removeLast());
    }
    
    return output;
  }
  
  static bool _isOperator(TokenType type) {
    return type == TokenType.plus ||
           type == TokenType.minus ||
           type == TokenType.multiply ||
           type == TokenType.divide ||
           type == TokenType.modulo ||
           type == TokenType.power;
  }
  
  static int _precedence(TokenType type) {
    switch (type) {
      case TokenType.plus:
      case TokenType.minus:
        return 1;
      case TokenType.multiply:
      case TokenType.divide:
      case TokenType.modulo:
        return 2;
      case TokenType.power:
        return 3;
      case TokenType.factorial:
        return 4;
      case TokenType.nPr:
      case TokenType.nCr:
        return 2;
      default:
        return 0;
    }
  }
  
  /// Convert RPN tokens back to a string
  static String rpnToString(List<Token> rpn) {
    final stack = <String>[];
    
    for (final token in rpn) {
      if (token.type == TokenType.number) {
        stack.add(token.value);
      } else if (_isOperator(token.type)) {
        if (stack.length >= 2) {
          final b = stack.removeLast();
          final a = stack.removeLast();
          stack.add('($a ${token.value} $b)');
        }
      }
    }
    
    return stack.isNotEmpty ? stack.last : '';
  }
}
