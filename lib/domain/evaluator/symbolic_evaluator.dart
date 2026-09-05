import '../ast/ast_node.dart';
import '../../core/constants/math_constants.dart';

/// Symbolic CAS evaluation - provides symbolic manipulation
/// This is a simplified symbolic evaluator for common operations
class SymbolicEvaluator {
  SymbolicEvaluator._();
  
  /// Simplify an expression symbolically where possible
  static ASTNode simplify(ASTNode node) {
    if (node is NumberNode) return node;
    if (node is ConstantNode) return node;
    if (node is VariableNode) return node;
    
    if (node is BinOpNode) {
      final left = simplify(node.left);
      final right = simplify(node.right);
      
      // Constant folding
      if (left is NumberNode && right is NumberNode) {
        return _foldConstants(left, node.operator, right);
      }
      
      // Identity simplifications
      if (node.operator == BinOperator.add) {
        if (left is NumberNode && left.value == 0) return right;
        if (right is NumberNode && right.value == 0) return left;
      }
      
      if (node.operator == BinOperator.multiply) {
        if (left is NumberNode) {
          if (left.value == 0) return NumberNode(0);
          if (left.value == 1) return right;
          if (left.value == -1) {
            return UnaryOpNode(UnaryOperator.negate, right);
          }
        }
        if (right is NumberNode) {
          if (right.value == 0) return NumberNode(0);
          if (right.value == 1) return left;
          if (right.value == -1) {
            return UnaryOpNode(UnaryOperator.negate, left);
          }
        }
      }
      
      if (node.operator == BinOperator.divide) {
        if (right is NumberNode && right.value == 1) return left;
        if (left is NumberNode && right is NumberNode && right.value != 0) {
          return NumberNode(left.value / right.value);
        }
      }
      
      return BinOpNode(left, node.operator, right);
    }
    
    if (node is UnaryOpNode) {
      final operand = simplify(node.operand);
      
      if (node.operator == UnaryOperator.negate && operand is NumberNode) {
        return NumberNode(-operand.value);
      }
      
      if (node.operator == UnaryOperator.positive) return operand;
      
      return UnaryOpNode(node.operator, operand);
    }
    
    if (node is PowerNode) {
      final base = simplify(node.base);
      final exp = simplify(node.exponent);
      
      if (exp is NumberNode) {
        if (exp.value == 0) return NumberNode(1);
        if (exp.value == 1) return base;
      }
      
      if (base is NumberNode && base.value == 1) return NumberNode(1);
      if (base is NumberNode && base.value == 0) return NumberNode(0);
      
      if (base is NumberNode && exp is NumberNode) {
        return NumberNode(_safePow(base.value, exp.value));
      }
      
      return PowerNode(base, exp);
    }
    
    if (node is FactorialNode) {
      final inner = simplify(node.expression);
      if (inner is NumberNode) {
        return NumberNode(_factorial(inner.value));
      }
      return FactorialNode(inner);
    }
    
    if (node is FuncNode) {
      final args = node.arguments.map(simplify).toList();
      if (args.every((a) => a is NumberNode)) {
        // Could evaluate the function symbolically
        // For now, just return the simplified function
      }
      return FuncNode(node.name, args);
    }
    
    if (node is ParenNode) {
      return ParenNode(simplify(node.inner));
    }
    
    return node;
  }
  
  /// Compute derivative d/dx of an expression (symbolic)
  static ASTNode derivative(ASTNode node, String variable) {
    if (node is NumberNode) return NumberNode(0);
    if (node is ConstantNode) return NumberNode(0);
    
    if (node is VariableNode) {
      if (node.name == variable) return NumberNode(1);
      return NumberNode(0);
    }
    
    if (node is BinOpNode) {
      final dl = derivative(node.left, variable);
      final dr = derivative(node.right, variable);
      
      switch (node.operator) {
        case BinOperator.add:
          return BinOpNode(dl, BinOperator.add, dr);
        case BinOperator.subtract:
          return BinOpNode(dl, BinOperator.subtract, dr);
        case BinOperator.multiply:
          // Product rule: (fg)' = f'g + fg'
          return BinOpNode(
            BinOpNode(dl, BinOperator.multiply, node.right),
            BinOperator.add,
            BinOpNode(node.left, BinOperator.multiply, dr),
          );
        case BinOperator.divide:
          // Quotient rule: (f/g)' = (f'g - fg') / g²
          return BinOpNode(
            BinOpNode(
              BinOpNode(dl, BinOperator.multiply, node.right),
              BinOperator.subtract,
              BinOpNode(node.left, BinOperator.multiply, dr),
            ),
            BinOperator.divide,
            PowerNode(node.right, NumberNode(2)),
          );
        default:
          return NumberNode(0);
      }
    }
    
    if (node is PowerNode) {
      // Power rule: d/dx(x^n) = n * x^(n-1)
      if (node.base is VariableNode && 
          (node.base as VariableNode).name == variable &&
          node.exponent is NumberNode) {
        final n = (node.exponent as NumberNode).value;
        return BinOpNode(
          node.exponent,
          BinOperator.multiply,
          PowerNode(
            node.base,
            NumberNode(n - 1),
          ),
        );
      }
    }
    
    if (node is FuncNode) {
      if (node.arguments.length == 1) {
        final innerDeriv = derivative(node.arguments[0], variable);
        
        // Chain rule with known derivatives
        ASTNode? outerDeriv;
        switch (node.name) {
          case 'sin':
            outerDeriv = FuncNode('cos', node.arguments);
            break;
          case 'cos':
            outerDeriv = UnaryOpNode(
              UnaryOperator.negate,
              FuncNode('sin', node.arguments),
            );
            break;
          case 'tan':
            outerDeriv = PowerNode(
              FuncNode('cos', node.arguments),
              NumberNode(-2),
            );
            break;
          case 'ln':
            outerDeriv = BinOpNode(NumberNode(1), BinOperator.divide, node.arguments[0]);
            break;
          case 'exp':
            outerDeriv = FuncNode('exp', node.arguments);
            break;
          case 'sqrt':
            outerDeriv = BinOpNode(
              NumberNode(0.5),
              BinOperator.divide,
              FuncNode('sqrt', node.arguments),
            );
            break;
        }
        
        if (outerDeriv != null) {
          return BinOpNode(outerDeriv, BinOperator.multiply, innerDeriv);
        }
      }
    }
    
    if (node is ParenNode) {
      return ParenNode(derivative(node.inner, variable));
    }
    
    return NumberNode(0);
  }
  
  static ASTNode _foldConstants(NumberNode left, BinOperator op, NumberNode right) {
    double result;
    switch (op) {
      case BinOperator.add:
        result = left.value + right.value;
        break;
      case BinOperator.subtract:
        result = left.value - right.value;
        break;
      case BinOperator.multiply:
        result = left.value * right.value;
        break;
      case BinOperator.divide:
        if (right.value == 0) return BinOpNode(left, op, right);
        result = left.value / right.value;
        break;
      case BinOperator.modulo:
        if (right.value == 0) return BinOpNode(left, op, right);
        result = left.value % right.value;
        break;
      case BinOperator.logBase:
        if (right.value <= 0 || left.value <= 0 || left.value == 1) {
          return BinOpNode(left, op, right);
        }
        result = _logBase(right.value, left.value);
        break;
      default:
        return BinOpNode(left, op, right);
    }
    return NumberNode(result);
  }
  
  static double _safePow(double base, double exp) {
    if (base == 0 && exp > 0) return 0;
    if (base == 0 && exp == 0) return 1;
    if (base < 0 && exp != exp.roundToDouble()) return double.nan;
    return _exp(exp * _ln(base.abs())) * (base < 0 ? (exp.roundToDouble().toInt().isEven ? 1 : -1) : 1);
  }
  
  static double _factorial(double x) {
    if (x < 0 || x != x.roundToDouble()) return double.nan;
    double result = 1;
    for (int i = 2; i <= x.toInt(); i++) {
      result *= i;
    }
    return result;
  }
  
  static double _ln(double x) {
    if (x <= 0) return double.nan;
    int k = 0;
    double m = x;
    while (m >= 2) { m /= 2; k++; }
    while (m < 1) { m *= 2; k--; }
    final z = (m - 1) / (m + 1);
    final z2 = z * z;
    double sum = z;
    double term = z;
    for (int i = 3; i < 40; i += 2) {
      term *= z2;
      sum += term / i;
    }
    return 2 * sum + k * MathConstants.ln2;
  }
  
  static double _exp(double x) {
    if (x.isNaN) return double.nan;
    if (x > 700) return double.infinity;
    if (x < -700) return 0;
    int k = (x / MathConstants.ln2).round();
    final r = x - k * MathConstants.ln2;
    double sum = 1.0;
    double term = 1.0;
    for (int i = 1; i < 30; i++) {
      term *= r / i;
      sum += term;
    }
    return sum * (k >= 0 ? (1 << k).toDouble() : 1.0 / (1 << -k).toDouble());
  }
  
  static double _logBase(double base, double x) {
    return _ln(x) / _ln(base);
  }
}

