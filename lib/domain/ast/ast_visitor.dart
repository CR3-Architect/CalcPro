import 'ast_node.dart';

/// A visitor that traverses the AST and returns the same type
class ASTTraversalVisitor implements ASTVisitor<void> {
  @override
  void visitNumber(NumberNode node) {}
  
  @override
  void visitBinOp(BinOpNode node) {
    node.left.accept(this);
    node.right.accept(this);
  }
  
  @override
  void visitUnaryOp(UnaryOpNode node) {
    node.operand.accept(this);
  }
  
  @override
  void visitFunc(FuncNode node) {
    for (final arg in node.arguments) {
      arg.accept(this);
    }
  }
  
  @override
  void visitVariable(VariableNode node) {}
  
  @override
  void visitConstant(ConstantNode node) {}
  
  @override
  void visitPower(PowerNode node) {
    node.base.accept(this);
    node.exponent.accept(this);
  }
  
  @override
  void visitParen(ParenNode node) {
    node.inner.accept(this);
  }
  
  @override
  void visitFactorial(FactorialNode node) {
    node.expression.accept(this);
  }
}

/// A visitor that converts AST back to string representation
class ASTToStringVisitor implements ASTVisitor<String> {
  @override
  String visitNumber(NumberNode node) {
    if (node.value == node.value.roundToDouble() && node.value.abs() < 1e15) {
      return node.value.toInt().toString();
    }
    return node.value.toString();
  }
  
  @override
  String visitBinOp(BinOpNode node) {
    return '(${node.left.accept(this)} ${node.operator.symbol} ${node.right.accept(this)})';
  }
  
  @override
  String visitUnaryOp(UnaryOpNode node) {
    return '${node.operator.symbol}${node.operand.accept(this)}';
  }
  
  @override
  String visitFunc(FuncNode node) {
    final args = node.arguments.map((a) => a.accept(this)).join(', ');
    return '${node.name}($args)';
  }
  
  @override
  String visitVariable(VariableNode node) => node.name;
  
  @override
  String visitConstant(ConstantNode node) => node.name;
  
  @override
  String visitPower(PowerNode node) {
    return '${node.base.accept(this)}^${node.exponent.accept(this)}';
  }
  
  @override
  String visitParen(ParenNode node) {
    return '(${node.inner.accept(this)})';
  }
  
  @override
  String visitFactorial(FactorialNode node) {
    return '${node.expression.accept(this)}!';
  }
}

/// A visitor that pretty-prints the AST for debugging
class ASTPrettyPrintVisitor extends ASTTraversalVisitor {
  final StringBuffer _buffer = StringBuffer();
  int _indent = 0;
  
  String print(ASTNode node) {
    _buffer.clear();
    _indent = 0;
    node.accept(this);
    return _buffer.toString();
  }
  
  void _writeIndent() {
    _buffer.write('  ' * _indent);
  }
  
  @override
  void visitNumber(NumberNode node) {
    _writeIndent();
    _buffer.writeln('Number: ${node.value}');
  }
  
  @override
  void visitBinOp(BinOpNode node) {
    _writeIndent();
    _buffer.writeln('BinOp [${node.operator.symbol}]:');
    _indent++;
    node.left.accept(this);
    node.right.accept(this);
    _indent--;
  }
  
  @override
  void visitUnaryOp(UnaryOpNode node) {
    _writeIndent();
    _buffer.writeln('UnaryOp [${node.operator.symbol}]:');
    _indent++;
    node.operand.accept(this);
    _indent--;
  }
  
  @override
  void visitFunc(FuncNode node) {
    _writeIndent();
    _buffer.writeln('Func [${node.name}]:');
    _indent++;
    for (final arg in node.arguments) {
      arg.accept(this);
    }
    _indent--;
  }
  
  @override
  void visitVariable(VariableNode node) {
    _writeIndent();
    _buffer.writeln('Variable: ${node.name}');
  }
  
  @override
  void visitConstant(ConstantNode node) {
    _writeIndent();
    _buffer.writeln('Constant: ${node.name} = ${node.value}');
  }
  
  @override
  void visitPower(PowerNode node) {
    _writeIndent();
    _buffer.writeln('Power:');
    _indent++;
    _writeIndent();
    _buffer.writeln('Base:');
    _indent++;
    node.base.accept(this);
    _indent--;
    _writeIndent();
    _buffer.writeln('Exponent:');
    _indent++;
    node.exponent.accept(this);
    _indent -= 2;
  }
  
  @override
  void visitParen(ParenNode node) {
    _writeIndent();
    _buffer.writeln('Paren:');
    _indent++;
    node.inner.accept(this);
    _indent--;
  }
  
  @override
  void visitFactorial(FactorialNode node) {
    _writeIndent();
    _buffer.writeln('Factorial:');
    _indent++;
    node.expression.accept(this);
    _indent--;
  }
}
