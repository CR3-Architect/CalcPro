/// Token types for the lexer
enum TokenType {
  // Literals
  number,
  identifier,
  
  // Operators
  plus,
  minus,
  multiply,
  divide,
  modulo,
  power,
  
  // Delimiters
  leftParen,
  rightParen,
  comma,
  
  // Special
  factorial,
  percent,
  dot,
  
  // Compound operators
  nPr,
  nCr,
  
  // End of input
  eof,
}

/// A single token from the lexer
class Token {
  final TokenType type;
  final String value;
  final int position;
  
  const Token(this.type, this.value, this.position);
  
  @override
  String toString() => 'Token($type, "$value", pos:$position)';
}

/// Tokenizer: converts string input to a list of tokens
class Lexer {
  final String _input;
  int _pos = 0;
  
  Lexer(this._input);
  
  /// Tokenize the full input
  List<Token> tokenize() {
    final tokens = <Token>[];
    
    while (_pos < _input.length) {
      _skipWhitespace();
      if (_pos >= _input.length) break;
      
      final char = _input[_pos];
      
      // Skip commas used as thousand separators ONLY inside number reading (_readNumber)
      // Main-loop commas are always tokenized (function args, etc.)
      
      // Numbers (including decimals and negatives after operators)
      if (RegExp(r'[0-9]').hasMatch(char) || 
          (char == '.' && _pos + 1 < _input.length && RegExp(r'[0-9]').hasMatch(_input[_pos + 1]))) {
        tokens.add(_readNumber());
        continue;
      }
      
      // Identifiers (functions, variables, constants)
      if (RegExp(r'[a-zA-Zπeφ]').hasMatch(char)) {
        tokens.add(_readIdentifier());
        continue;
      }
      
      // Single character tokens
      switch (char) {
        case '+':
          tokens.add(Token(TokenType.plus, '+', _pos));
          _pos++;
          break;
        case '-':
          tokens.add(Token(TokenType.minus, '-', _pos));
          _pos++;
          break;
        case '×':
        case '*':
          tokens.add(Token(TokenType.multiply, '×', _pos));
          _pos++;
          break;
        case '÷':
        case '/':
          tokens.add(Token(TokenType.divide, '÷', _pos));
          _pos++;
          break;
        case '%':
          tokens.add(Token(TokenType.percent, '%', _pos));
          _pos++;
          break;
        case '^':
          tokens.add(Token(TokenType.power, '^', _pos));
          _pos++;
          break;
        case '(':
          tokens.add(Token(TokenType.leftParen, '(', _pos));
          _pos++;
          break;
        case ')':
          tokens.add(Token(TokenType.rightParen, ')', _pos));
          _pos++;
          break;
        case ',':
          tokens.add(Token(TokenType.comma, ',', _pos));
          _pos++;
          break;
        case '!':
          tokens.add(Token(TokenType.factorial, '!', _pos));
          _pos++;
          break;
        case '|':
          // Handle as absolute value
          tokens.add(Token(TokenType.identifier, 'abs', _pos));
          _pos++;
          break;
        case '√':
          tokens.add(Token(TokenType.identifier, 'sqrt', _pos));
          _pos++;
          break;
        default:
          // Unknown character - skip
          _pos++;
          break;
      }
    }
    
    tokens.add(Token(TokenType.eof, '', _pos));
    return tokens;
  }
  
  Token _readNumber() {
    final start = _pos;
    final buffer = StringBuffer();
    bool hasDecimal = false;
    
    while (_pos < _input.length) {
      final char = _input[_pos];
      if (char == '.') {
        if (hasDecimal) break;
        hasDecimal = true;
        buffer.write(char);
        _pos++;
      } else if (RegExp(r'[0-9]').hasMatch(char)) {
        buffer.write(char);
        _pos++;
      } else if (char == ',' && _pos + 2 < _input.length &&
          RegExp(r'[0-9]').hasMatch(_input[_pos + 1]) &&
          RegExp(r'[0-9]').hasMatch(_input[_pos + 2]) &&
          (_pos + 3 >= _input.length || !RegExp(r'[0-9]').hasMatch(_input[_pos + 3]))) {
        _pos++; // Skip comma as thousand separator (groups of 3 digits only)
      } else {
        break;
      }
    }
    
    // Handle scientific notation like 1e10 or 1E-5
    if (_pos < _input.length && 
        (_input[_pos] == 'e' || _input[_pos] == 'E') &&
        _pos + 1 < _input.length) {
      final nextChar = _input[_pos + 1];
      if (RegExp(r'[0-9+\-]').hasMatch(nextChar)) {
        buffer.write(_input[_pos]); // 'e' or 'E'
        _pos++;
        if (_input[_pos] == '+' || _input[_pos] == '-') {
          buffer.write(_input[_pos]);
          _pos++;
        }
        while (_pos < _input.length && RegExp(r'[0-9]').hasMatch(_input[_pos])) {
          buffer.write(_input[_pos]);
          _pos++;
        }
      }
    }
    
    return Token(TokenType.number, buffer.toString(), start);
  }
  
  Token _readIdentifier() {
    final start = _pos;
    final buffer = StringBuffer();
    
    while (_pos < _input.length) {
      final char = _input[_pos];
      if (RegExp(r'[a-zA-Z0-9πeφ_]').hasMatch(char)) {
        buffer.write(char);
        _pos++;
      } else {
        break;
      }
    }
    
    final value = buffer.toString();
    final lower = value.toLowerCase();
    
    // Check for compound operators (only when NOT used as function call nPr(...))
    // Also handle cases like "5nPr2" where digits follow the operator name
    if (lower == 'npr' || lower == 'ncr') {
      final type = lower == 'npr' ? TokenType.nPr : TokenType.nCr;
      // If followed by '(' it's a function call: re-emit as identifier
      int lookahead = _pos;
      while (lookahead < _input.length && RegExp(r'[\s]').hasMatch(_input[lookahead])) {
        lookahead++;
      }
      if (lookahead < _input.length && _input[lookahead] == '(') {
        return Token(TokenType.identifier, value, start);
      }
      return Token(type, value, start);
    }
    
    // Handle "nPr2" / "nCr5" style: name followed by digits (e.g. from 5nPr2)
    final opMatch = RegExp(r'^(npr|ncr)(\d)').firstMatch(lower);
    if (opMatch != null) {
      final opLen = opMatch.group(1)!.length;
      // Rewind to just after the operator name
      _pos = start + opLen;
      final opType = opMatch.group(1) == 'npr' ? TokenType.nPr : TokenType.nCr;
      return Token(opType, opMatch.group(1)!, start);
    }
    
    return Token(TokenType.identifier, value, start);
  }
  
  void _skipWhitespace() {
    while (_pos < _input.length && RegExp(r'[\s\t]').hasMatch(_input[_pos])) {
      _pos++;
    }
  }
}
