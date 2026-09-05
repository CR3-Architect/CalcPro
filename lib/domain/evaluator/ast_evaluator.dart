import 'dart:math' as math;

import '../ast/ast_node.dart';
import '../../core/enums/angle_mode.dart';

/// Numeric evaluation of AST nodes
class ASTEvaluator implements ASTVisitor<double> {
  final AngleMode angleMode;
  final Map<String, double> variables;
  final Map<String, double> memory;
  
  ASTEvaluator({
    this.angleMode = AngleMode.degree,
    this.variables = const {},
    this.memory = const {},
  });
  
  double evaluate(ASTNode node) => node.accept(this);
  
  @override
  double visitNumber(NumberNode node) => node.value;
  
  @override
  double visitBinOp(BinOpNode node) {
    final left = node.left.accept(this);
    final right = node.right.accept(this);
    switch (node.operator) {
      case BinOperator.add: return left + right;
      case BinOperator.subtract: return left - right;
      case BinOperator.multiply: return left * right;
      case BinOperator.divide:
        if (right == 0) throw EvaluationException('Division by zero');
        return left / right;
      case BinOperator.modulo:
        if (right == 0) throw EvaluationException('Division by zero');
        return left % right;
      case BinOperator.nPr: return _permutations(left.toInt(), right.toInt());
      case BinOperator.nCr: return _combinations(left.toInt(), right.toInt());
      case BinOperator.logBase:
        if (left <= 0 || right <= 0) throw EvaluationException('Invalid argument for log');
        return _logBase(left, right);
    }
  }
  
  @override
  double visitUnaryOp(UnaryOpNode node) {
    final value = node.operand.accept(this);
    switch (node.operator) {
      case UnaryOperator.negate: return -value;
      case UnaryOperator.positive: return value;
      case UnaryOperator.factorial: return _factorial(value);
    }
  }
  
  @override
  double visitFunc(FuncNode node) {
    final args = node.arguments.map((a) => a.accept(this)).toList();
    return _callFunction(node.name.toLowerCase(), args);
  }
  
  @override
  double visitVariable(VariableNode node) {
    if (variables.containsKey(node.name)) return variables[node.name]!;
    if (memory.containsKey(node.name)) return memory[node.name]!;
    throw EvaluationException('Unknown variable: ${node.name}');
  }
  
  @override
  double visitConstant(ConstantNode node) => node.value;
  
  @override
  double visitPower(PowerNode node) {
    final base = node.base.accept(this);
    final exp = node.exponent.accept(this);
    return _safePow(base, exp);
  }
  
  @override
  double visitParen(ParenNode node) => node.inner.accept(this);
  
  @override
  double visitFactorial(FactorialNode node) {
    return _factorial(node.expression.accept(this));
  }
  
  double _callFunction(String name, List<double> args) {
    switch (name) {
      case 'sin': return _sin(args[0]);
      case 'cos': return _cos(args[0]);
      case 'tan': return _tan(args[0]);
      case 'asin': return _asin(args[0]);
      case 'acos': return _acos(args[0]);
      case 'atan': return _atan(args[0]);
      case 'sinh': return (math.exp(args[0]) - math.exp(-args[0])) / 2;
      case 'cosh': return (math.exp(args[0]) + math.exp(-args[0])) / 2;
      case 'tanh': return _tanH(args[0]);
      case 'asinh': return math.log(args[0] + math.sqrt(args[0] * args[0] + 1));
      case 'acosh': {
        if (args[0] < 1) throw EvaluationException('acosh domain: [1, ∞)');
        return math.log(args[0] + math.sqrt(args[0] * args[0] - 1));
      }
      case 'atanh': {
        if (args[0] <= -1 || args[0] >= 1) throw EvaluationException('atanh domain: (-1, 1)');
        return 0.5 * math.log((1 + args[0]) / (1 - args[0]));
      }
      case 'log':
        if (args.length == 2) return _logBase(args[1], args[0]);
        return _log10(args[0]);
      case 'ln': return _ln(args[0]);
      case 'log2': return _log2(args[0]);
      case 'sqrt':
        if (args[0] < 0) throw EvaluationException('Square root of negative number');
        return math.sqrt(args[0]);
      case 'cbrt': return math.pow(args[0], 1.0 / 3.0).toDouble();
      case 'pow':
        if (args.length < 2) throw EvaluationException('pow requires 2 arguments');
        return _safePow(args[0], args[1]);
      case 'root':
        if (args.length < 2) throw EvaluationException('root requires 2 arguments');
        return _nthRoot(args[0], args[1]);
      case 'exp': return math.exp(args[0]);
      case 'exp2': return math.pow(2, args[0]).toDouble();
      case 'exp10': return math.pow(10, args[0]).toDouble();
      case 'floor': return args[0].floorToDouble();
      case 'ceil': return args[0].ceilToDouble();
      case 'round': return args[0].roundToDouble();
      case 'trunc': return args[0].truncateToDouble();
      case 'abs': return args[0].abs();
      case 'sign': return args[0].sign;
      case 'factorial': return _factorial(args[0]);
      case 'npr': return _permutations(args[0].toInt(), args[1].toInt());
      case 'ncr': return _combinations(args[0].toInt(), args[1].toInt());
      case 'gcd': return _gcd(args[0].toInt(), args[1].toInt()).toDouble();
      case 'lcm': return _lcm(args[0].toInt(), args[1].toInt()).toDouble();
      case 'min': return args.reduce((a, b) => a < b ? a : b);
      case 'max': return args.reduce((a, b) => a > b ? a : b);
      default: throw EvaluationException('Unknown function: $name');
    }
  }
  
  // --- Trig functions with angle conversion ---
  
  double _sin(double x) {
    final radians = angleMode.toRadians(x);
    return math.sin(radians);
  }
  
  double _cos(double x) {
    final radians = angleMode.toRadians(x);
    return math.cos(radians);
  }
  
  double _tan(double x) {
    final radians = angleMode.toRadians(x);
    return math.tan(radians);
  }
  
  double _asin(double x) {
    if (x < -1 || x > 1) throw EvaluationException('asin domain: [-1, 1]');
    return angleMode.fromRadians(math.asin(x));
  }
  
  double _acos(double x) {
    if (x < -1 || x > 1) throw EvaluationException('acos domain: [-1, 1]');
    return angleMode.fromRadians(math.acos(x));
  }
  
  double _atan(double x) {
    return angleMode.fromRadians(math.atan(x));
  }
  
  // --- Logarithms ---
  
  double _ln(double x) {
    if (x <= 0) throw EvaluationException('ln domain: (0, ∞)');
    return math.log(x);
  }
  
  double _log10(double x) {
    if (x <= 0) throw EvaluationException('log₁₀ domain: (0, ∞)');
    return math.log(x) / math.ln10;
  }
  
  double _log2(double x) {
    if (x <= 0) throw EvaluationException('log₂ domain: (0, ∞)');
    return math.log(x) / math.ln2;
  }
  
  double _logBase(double base, double x) {
    if (x <= 0) throw EvaluationException('log domain: (0, ∞)');
    if (base <= 0 || base == 1) throw EvaluationException('log base must be positive and ≠ 1');
    return math.log(x) / math.log(base);
  }
  
  // --- Power ---
  
  double _nthRoot(double n, double x) {
    if (n == 0) throw EvaluationException('Cannot take 0th root');
    return math.pow(x, 1.0 / n).toDouble();
  }
  
  // --- Combinatorics ---
  
  double _factorial(double x) {
    if (x < 0 || x != x.roundToDouble()) {
      return _gammaApprox(x + 1);
    }
    final n = x.toInt();
    if (n > 170) throw EvaluationException('Factorial too large');
    if (n < 0) throw EvaluationException('Factorial of negative number');
    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }
  
  double _permutations(int n, int r) {
    if (n < 0 || r < 0 || r > n) throw EvaluationException('Invalid permutation arguments');
    return _factorial(n.toDouble()) / _factorial((n - r).toDouble());
  }
  
  double _combinations(int n, int r) {
    if (n < 0 || r < 0 || r > n) throw EvaluationException('Invalid combination arguments');
    return _factorial(n.toDouble()) / (_factorial(r.toDouble()) * _factorial((n - r).toDouble()));
  }
  
  int _gcd(int a, int b) {
    a = a.abs(); b = b.abs();
    while (b != 0) { final t = b; b = a % b; a = t; }
    return a;
  }
  
  int _lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a.abs() * b.abs()) ~/ _gcd(a, b);
  }
  
  // --- Hyperbolic helpers ---
  static double _tanH(double x) {
    final e2x = math.exp(2 * x);
    return (e2x - 1) / (e2x + 1);
  }

  // --- Safe pow ---
  
  static double _safePow(double base, double exp) {
    return math.pow(base, exp).toDouble();
  }
  
  static double _gammaApprox(double x) {
    if (x <= 0) return double.nan;
    if (x < 0.5) {
      return math.pi / (math.sin(math.pi * x) * _gammaApprox(1 - x));
    }
    x -= 1;
    final c = [
      0.99999999999980993, 676.5203681218851, -1259.1392167224028,
      771.32342877765313, -176.61502916214059, 12.507343278686905,
      -0.13857109526572012, 9.9843695780195716e-6, 1.5056327351493116e-7,
    ];
    double ag = c[0];
    final y = x + 7.5;
    for (int i = 1; i < 9; i++) {
      ag += c[i] / (x + i);
    }
    return math.sqrt(2 * math.pi) * math.pow(y, x + 0.5) * math.exp(-y) * ag;
  }
}

/// Evaluation exception
class EvaluationException implements Exception {
  final String message;
  const EvaluationException(this.message);
  @override
  String toString() => 'EvaluationException: $message';
}
