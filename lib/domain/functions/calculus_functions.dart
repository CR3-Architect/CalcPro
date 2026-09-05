/// Calculus functions: derivatives, integrals, limits, summation
class CalculusFunctions {
  CalculusFunctions._();
  
  /// Numerical derivative using central difference
  /// f'(x) ≈ [f(x+h) - f(x-h)] / 2h
  static double derivative(double Function(double) f, double x, {double h = 1e-8}) {
    if (h <= 0) throw ArgumentError('Step size must be positive');
    final forward = f(x + h);
    final backward = f(x - h);
    return (forward - backward) / (2 * h);
  }
  
  /// Numerical second derivative
  static double secondDerivative(double Function(double) f, double x, {double h = 1e-5}) {
    return (f(x + h) - 2 * f(x) + f(x - h)) / (h * h);
  }
  
  /// Numerical n-th derivative using finite differences
  static double nthDerivative(double Function(double) f, double x, int n, {double h = 1e-5}) {
    if (n == 0) return f(x);
    if (n == 1) return derivative(f, x, h: h);
    if (n == 2) return secondDerivative(f, x, h: h);
    
    // General finite difference for n-th derivative
    double result = 0;
    for (int k = 0; k <= n; k++) {
      double coeff = _binomialCoefficient(n, k) * (k.isEven ? 1.0 : -1.0);
      result += coeff * f(x + (n / 2 - k) * h);
    }
    return result / _pow(h, n);
  }
  
  /// Numerical integration using Simpson's rule
  static double integrate(double Function(double) f, double a, double b, {int n = 1000}) {
    if (a == b) return 0;
    if (a > b) return -integrate(f, b, a, n: n);
    if (n.isOdd) n++;
    
    final h = (b - a) / n;
    double sum = f(a) + f(b);
    
    for (int i = 1; i < n; i++) {
      final x = a + i * h;
      sum += (i.isOdd ? 4 : 2) * f(x);
    }
    
    return sum * h / 3;
  }
  
  /// Numerical integration using Gaussian quadrature (7-point)
  static double gaussianQuadrature(double Function(double) f, double a, double b) {
    // 7-point Gauss-Legendre quadrature
    const nodes = [
      0.0,
      0.4058451513773971,
      -0.4058451513773971,
      0.7415311855993945,
      -0.7415311855993945,
      0.9491079123427585,
      -0.9491079123427585,
    ];
    const weights = [
      0.4179591836734694,
      0.3818300505051189,
      0.3818300505051189,
      0.2797053914892766,
      0.2797053914892766,
      0.1294849661688697,
      0.1294849661688697,
    ];
    
    final mid = (a + b) / 2;
    final half = (b - a) / 2;
    
    double sum = 0;
    for (int i = 0; i < nodes.length; i++) {
      sum += weights[i] * f(mid + half * nodes[i]);
    }
    
    return sum * half;
  }
  
  /// Numerical limit: lim x→a f(x)
  static double limit(double Function(double) f, double a, {double h = 1e-10}) {
    final right = f(a + h);
    final left = f(a - h);
    
    if ((right - left).abs() < 1e-8) {
      return (right + left) / 2;
    }
    
    // Try smaller h
    final h2 = h / 10;
    final right2 = f(a + h2);
    final left2 = f(a - h2);
    
    // If converging, return average
    if ((right2 - left2).abs() < (right - left).abs()) {
      return (right2 + left2) / 2;
    }
    
    return (right + left) / 2;
  }
  
  /// Left-hand limit
  static double limitLeft(double Function(double) f, double a, {double h = 1e-10}) {
    double prevResult = f(a - h);
    for (int i = 0; i < 10; i++) {
      h /= 10;
      final result = f(a - h);
      if ((result - prevResult).abs() < 1e-15) return result;
      prevResult = result;
    }
    return prevResult;
  }
  
  /// Right-hand limit
  static double limitRight(double Function(double) f, double a, {double h = 1e-10}) {
    double prevResult = f(a + h);
    for (int i = 0; i < 10; i++) {
      h /= 10;
      final result = f(a + h);
      if ((result - prevResult).abs() < 1e-15) return result;
      prevResult = result;
    }
    return prevResult;
  }
  
  /// Infinite limit (x → ∞)
  static double limitInfinity(double Function(double) f) {
    double prevResult = f(1000);
    double x = 1000;
    for (int i = 0; i < 20; i++) {
      x *= 10;
      final result = f(x);
      if ((result - prevResult).abs() < 1e-10) return result;
      prevResult = result;
    }
    return prevResult;
  }
  
  /// Summation: Σ f(k) for k = start to end
  static double summation(double Function(int) f, int start, int end) {
    double sum = 0;
    for (int k = start; k <= end; k++) {
      sum += f(k);
    }
    return sum;
  }
  
  /// Product: Π f(k) for k = start to end
  static double product(double Function(int) f, int start, int end) {
    double result = 1;
    for (int k = start; k <= end; k++) {
      result *= f(k);
    }
    return result;
  }
  
  /// Taylor series expansion of f around a, evaluated at x
  static double taylorSeries(
    double Function(double) f, 
    double a, 
    double x, 
    int terms,
  ) {
    double sum = 0;
    double term = f(a);
    
    for (int n = 0; n < terms; n++) {
      sum += term;
      
      // Compute next term using n-th derivative
      final deriv = nthDerivative(f, a, n + 1);
      term = deriv * _pow(x - a, n + 1) / _factorial(n + 1);
    }
    
    return sum;
  }
  
  /// Arc length: ∫ sqrt(1 + (f'(x))²) dx from a to b
  static double arcLength(double Function(double) f, double a, double b) {
    return integrate(
      (x) {
        final dx = derivative(f, x);
        return _sqrt(1 + dx * dx);
      },
      a,
      b,
    );
  }
  
  /// Average value of f on [a, b]: (1/(b-a)) * ∫ f(x) dx
  static double averageValue(double Function(double) f, double a, double b) {
    if (a == b) return f(a);
    return integrate(f, a, b) / (b - a);
  }
  
  // --- Helpers ---
  
  static int _factorial(int n) {
    if (n <= 1) return 1;
    int result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }
  
  static int _binomialCoefficient(int n, int k) {
    if (k < 0 || k > n) return 0;
    if (k == 0 || k == n) return 1;
    int result = 1;
    for (int i = 0; i < k; i++) {
      result = result * (n - i) ~/ (i + 1);
    }
    return result;
  }
  
  static double _pow(double base, int exp) {
    if (exp == 0) return 1;
    if (exp < 0) return 1.0 / _pow(base, -exp);
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
  
  static double _sqrt(double x) {
    if (x < 0) return double.nan;
    if (x == 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 50; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }
}
