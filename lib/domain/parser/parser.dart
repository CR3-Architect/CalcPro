import '../ast/ast_node.dart';
import 'lexer.dart';
import '../../core/constants/math_constants.dart';

/// Recursive descent parser: tokens → AST
class Parser {
  final List<Token> _tokens;
  int _pos = 0;
  
  Parser(this._tokens);
  
  /// Parse tokens into an AST
  ASTNode parse() {
    final result = _parseExpression();
    _expect(TokenType.eof, 'Unexpected token after expression');
    return result;
  }
  
  /// Expression: Term (('+' | '-') Term)*
  ASTNode _parseExpression() {
    ASTNode left = _parseTerm();
    
    while (_match(TokenType.plus) || _match(TokenType.minus)) {
      final op = _previous().type == TokenType.plus
          ? BinOperator.add
          : BinOperator.subtract;
      final right = _parseTerm();
      left = BinOpNode(left, op, right);
    }
    
    return left;
  }
  
  /// Term: Power (('*' | '/' | '%') Power)*
  ASTNode _parseTerm() {
    ASTNode left = _parsePower();
    
    while (_match(TokenType.multiply) || _match(TokenType.divide) || _match(TokenType.modulo)) {
      BinOperator op;
      switch (_previous().type) {
        case TokenType.multiply:
          op = BinOperator.multiply;
          break;
        case TokenType.divide:
          op = BinOperator.divide;
          break;
        case TokenType.modulo:
          op = BinOperator.modulo;
          break;
        default:
          op = BinOperator.multiply;
      }
      final right = _parsePower();
      left = BinOpNode(left, op, right);
    }
    
    return left;
  }
  
  /// Power: Unary ('^' Unary)*
  ASTNode _parsePower() {
    ASTNode left = _parseUnary();
    
    while (_match(TokenType.power)) {
      final right = _parseUnary();
      left = PowerNode(left, right);
    }
    
    return left;
  }
  
  /// Unary: ('-' | '+') Unary | Postfix
  ASTNode _parseUnary() {
    if (_match(TokenType.minus)) {
      final operand = _parseUnary();
      return UnaryOpNode(UnaryOperator.negate, operand);
    }
    if (_match(TokenType.plus)) {
      final operand = _parseUnary();
      return UnaryOpNode(UnaryOperator.positive, operand);
    }
    return _parsePostfix();
  }
  
  /// Postfix: Primary ('!')*
  ASTNode _parsePostfix() {
    ASTNode node = _parsePrimary();
    
    while (_match(TokenType.factorial)) {
      node = FactorialNode(node);
    }
    
    return node;
  }
  
  /// Primary: number | identifier | '(' Expression ')' | function
  ASTNode _parsePrimary() {
    // Number literal
    if (_match(TokenType.number)) {
      final value = double.parse(_previous().value);
      return NumberNode(value);
    }
    
    // Parenthesized expression
    if (_match(TokenType.leftParen)) {
      final expr = _parseExpression();
      _expect(TokenType.rightParen, 'Expected closing parenthesis');
      return ParenNode(expr);
    }
    
    // Identifier: constant, variable, or function
    if (_match(TokenType.identifier)) {
      final name = _previous().value.toLowerCase();
      
      // Check if it's followed by '(' => function call
      if (_check(TokenType.leftParen)) {
        return _parseFunction(name);
      }
      
      // Check for known constants
      return _resolveIdentifier(name);
    }
    
    // Handle nPr and nCr as binary operators
    if (_match(TokenType.nPr) || _match(TokenType.nCr)) {
      // These are handled as binary operators in the expression level
      // But we might reach here if they appear unexpectedly
      throw ParseException('Unexpected token: ${_previous().value}');
    }
    
    throw ParseException('Unexpected token: ${_peek().value}');
  }
  
  ASTNode _parseFunction(String name) {
    _expect(TokenType.leftParen, 'Expected "(" after function name');
    
    final args = <ASTNode>[];
    if (!_check(TokenType.rightParen)) {
      args.add(_parseExpression());
      while (_match(TokenType.comma)) {
        args.add(_parseExpression());
      }
    }
    
    _expect(TokenType.rightParen, 'Expected ")" after function arguments');
    
    return FuncNode(name, args);
  }
  
  ASTNode _resolveIdentifier(String name) {
    switch (name) {
      case 'pi':
      case 'π':
        return ConstantNode('π', MathConstants.pi);
      case 'e':
        return ConstantNode('e', MathConstants.e);
      case 'phi':
      case 'φ':
        return ConstantNode('φ', MathConstants.phi);
      case 'tau':
      case 'τ':
        return ConstantNode('τ', 2 * MathConstants.pi);
      default:
        return VariableNode(name);
    }
  }
  
  // Token helpers
  
  bool _match(TokenType type) {
    if (_check(type)) {
      _pos++;
      return true;
    }
    return false;
  }
  
  bool _check(TokenType type) {
    if (_pos >= _tokens.length) return false;
    return _tokens[_pos].type == type;
  }
  
  Token _peek() {
    if (_pos >= _tokens.length) {
      return Token(TokenType.eof, '', -1);
    }
    return _tokens[_pos];
  }
  
  Token _previous() {
    if (_pos <= 0) {
      return Token(TokenType.eof, '', -1);
    }
    return _tokens[_pos - 1];
  }
  
  void _expect(TokenType type, String message) {
    if (!_match(type)) {
      throw ParseException('$message at position ${_peek().position}');
    }
  }
}

/// Parser exception
class ParseException implements Exception {
  final String message;
  const ParseException(this.message);
  
  @override
  String toString() => 'ParseException: $message';
}

/// Convenience: parse a string expression into an AST
ASTNode parseExpression(String input) {
  final lexer = Lexer(input);
  final tokens = lexer.tokenize();
  final parser = Parser(tokens);
  return parser.parse();
}
