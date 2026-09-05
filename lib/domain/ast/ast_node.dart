/// Base class for all AST nodes
abstract class ASTNode {
  T accept<T>(ASTVisitor<T> visitor);
}

/// A numeric literal value
class NumberNode extends ASTNode {
  final double value;
  
  NumberNode(this.value);
  
  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitNumber(this);
  
  @override
  String toString() => 'Number($value)';
}

/// Binary operation: left op right
class BinOpNode extends ASTNode {
  final ASTNode left;
  final ASTNode right;
  final BinOperator operator;
  
  BinOpNode(this.left, this.operator, this.right);
  
  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitBinOp(this);
  
  @override
  String toString() => 'BinOp($left $operator $right)';
}

/// Unary operation: op operand
class UnaryOpNode extends ASTNode {
  final UnaryOperator operator;
  final ASTNode operand;
  
  UnaryOpNode(this.operator, this.operand);
  
  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitUnaryOp(this);
  
  @override
  String toString() => 'UnaryOp($operator $operand)';
}

/// Function call: name(args)
class FuncNode extends ASTNode {
  final String name;
  final List<ASTNode> arguments;
  
  FuncNode(this.name, this.arguments);
  
  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitFunc(this);
  
  @override
  String toString() => 'Func($name, $arguments)';
}

/// Variable reference
class VariableNode extends ASTNode {
  final String name;
  
  VariableNode(this.name);
  
  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitVariable(this);
  
  @override
  String toString() => 'Variable($name)';
}

/// Constant reference (π, e, φ, etc.)
class ConstantNode extends ASTNode {
  final String name;
  final double value;
  
  ConstantNode(this.name, this.value);
  
  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitConstant(this);
  
  @override
  String toString() => 'Constant($name=$value)';
}

/// Power/exponentiation: base^exponent
class PowerNode extends ASTNode {
  final ASTNode base;
  final ASTNode exponent;
  
  PowerNode(this.base, this.exponent);
  
  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitPower(this);
  
  @override
  String toString() => 'Power($base ^ $exponent)';
}

/// Parenthesized expression
class ParenNode extends ASTNode {
  final ASTNode inner;
  
  ParenNode(this.inner);
  
  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitParen(this);
  
  @override
  String toString() => 'Paren($inner)';
}

/// Factorial: expression!
class FactorialNode extends ASTNode {
  final ASTNode expression;
  
  FactorialNode(this.expression);
  
  @override
  T accept<T>(ASTVisitor<T> visitor) => visitor.visitFactorial(this);
  
  @override
  String toString() => 'Factorial($expression)';
}

/// Binary operators
enum BinOperator {
  add('+'),
  subtract('-'),
  multiply('×'),
  divide('÷'),
  modulo('%'),
  nPr('nPr'),
  nCr('nCr'),
  logBase('log');
  
  final String symbol;
  const BinOperator(this.symbol);
  
  @override
  String toString() => symbol;
}

/// Unary operators
enum UnaryOperator {
  negate('-'),
  positive('+'),
  factorial('!');
  
  final String symbol;
  const UnaryOperator(this.symbol);
  
  @override
  String toString() => symbol;
}

/// Visitor interface for AST traversal
abstract class ASTVisitor<T> {
  T visitNumber(NumberNode node);
  T visitBinOp(BinOpNode node);
  T visitUnaryOp(UnaryOpNode node);
  T visitFunc(FuncNode node);
  T visitVariable(VariableNode node);
  T visitConstant(ConstantNode node);
  T visitPower(PowerNode node);
  T visitParen(ParenNode node);
  T visitFactorial(FactorialNode node);
}
