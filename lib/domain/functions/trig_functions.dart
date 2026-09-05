import 'dart:math' as math;
import '../../core/enums/angle_mode.dart';
import '../../core/constants/math_constants.dart';

/// Trigonometric functions with angle mode support
class TrigFunctions {
  TrigFunctions._();
  
  // Basic trig with angle conversion
  static double sin(double angle, AngleMode mode) {
    final radians = mode.toRadians(angle);
    return _sin(radians);
  }
  
  static double cos(double angle, AngleMode mode) {
    final radians = mode.toRadians(angle);
    return _cos(radians);
  }
  
  static double tan(double angle, AngleMode mode) {
    final radians = mode.toRadians(angle);
    final cosVal = _cos(radians);
    if (cosVal.abs() < 1e-15) {
      throw ArgumentError('tan is undefined at this angle');
    }
    return _sin(radians) / cosVal;
  }
  
  // Inverse trig
  static double asin(double x, AngleMode mode) {
    if (x < -1 || x > 1) throw ArgumentError('asin domain: [-1, 1]');
    return mode.fromRadians(_asin(x));
  }
  
  static double acos(double x, AngleMode mode) {
    if (x < -1 || x > 1) throw ArgumentError('acos domain: [-1, 1]');
    return mode.fromRadians(_acos(x));
  }
  
  static double atan(double x, AngleMode mode) {
    return mode.fromRadians(_atan(x));
  }
  
  static double atan2(double y, double x, AngleMode mode) {
    return mode.fromRadians(_atan2(y, x));
  }
  
  // Hyperbolic
  static double sinh(double x) => (exp(x) - exp(-x)) / 2;
  static double cosh(double x) => (exp(x) + exp(-x)) / 2;
  static double tanh(double x) => sinh(x) / cosh(x);
  
  static double asinh(double x) => _ln(x + _sqrt(x * x + 1));
  static double acosh(double x) {
    if (x < 1) throw ArgumentError('acosh domain: [1, ∞)');
    return _ln(x + _sqrt(x * x - 1));
  }
  static double atanh(double x) {
    if (x <= -1 || x >= 1) throw ArgumentError('atanh domain: (-1, 1)');
    return 0.5 * _ln((1 + x) / (1 - x));
  }
  
  // Secant, cosecant, cotangent
  static double sec(double angle, AngleMode mode) {
    final c = cos(angle, mode);
    if (c.abs() < 1e-15) throw ArgumentError('sec is undefined at this angle');
    return 1 / c;
  }
  
  static double csc(double angle, AngleMode mode) {
    final s = sin(angle, mode);
    if (s.abs() < 1e-15) throw ArgumentError('csc is undefined at this angle');
    return 1 / s;
  }
  
  static double cot(double angle, AngleMode mode) {
    final t = tan(angle, mode);
    if (t.abs() < 1e-15) throw ArgumentError('cot is undefined at this angle');
    return 1 / t;
  }
  
  // --- Internal approximations ---
  
  static double _sin(double x) {
    x = x % (2 * MathConstants.pi);
    if (x > MathConstants.pi) x -= 2 * MathConstants.pi;
    if (x < -MathConstants.pi) x += 2 * MathConstants.pi;
    
    double sum = x;
    double term = x;
    for (int i = 1; i < 20; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      sum += term;
    }
    return sum;
  }
  
  static double _cos(double x) => _sin(x + MathConstants.pi / 2);
  
  static double _atan(double x) {
    if (x > 1) return MathConstants.pi / 2 - _atan(1 / x);
    if (x < -1) return -MathConstants.pi / 2 - _atan(-1 / x);
    double sum = x;
    double term = x;
    for (int i = 1; i < 30; i++) {
      term *= -x * x;
      sum += term / (2 * i + 1);
    }
    return sum;
  }
  
  static double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + MathConstants.pi;
    if (x < 0 && y < 0) return _atan(y / x) - MathConstants.pi;
    if (x == 0 && y > 0) return MathConstants.pi / 2;
    if (x == 0 && y < 0) return -MathConstants.pi / 2;
    return 0; // x == 0 && y == 0
  }
  
  static double _asin(double x) => _atan(x / _sqrt(1 - x * x));
  static double _acos(double x) => MathConstants.pi / 2 - _asin(x);
  
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
  
  static double _sqrt(double x) => math.sqrt(x);
  
  static double exp(double x) => math.exp(x);
}
