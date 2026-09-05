import 'dart:math' as math;


/// Complex number representation
class Complex {
  final double real;
  final double imaginary;
  
  const Complex(this.real, this.imaginary);
  
  /// Create from polar form
  factory Complex.fromPolar(double modulus, double argument) {
    return Complex(
      modulus * math.cos(argument),
      modulus * math.sin(argument),
    );
  }
  
  /// Parse from string like "3+4i" or "3-4i"
  factory Complex.parse(String s) {
    s = s.replaceAll(' ', '');
    // Handle pure imaginary
    if (s == 'i' || s == '+i') return const Complex(0, 1);
    if (s == '-i') return const Complex(0, -1);
    
    // Match pattern like a+bi or a-bi
    final match = RegExp(r'^([+-]?[\d.]+)?([+-][\d.]*)?i$').firstMatch(s);
    if (match != null) {
      final double realPart = match.group(1) != null ? double.parse(match.group(1)!) : 0.0;
      final imagStr = match.group(2);
      double imagPart;
      if (imagStr == null || imagStr == '+') {
        imagPart = 1;
      } else if (imagStr == '-') {
        imagPart = -1;
      } else {
        imagPart = double.parse(imagStr);
      }
      return Complex(realPart, imagPart);
    }
    
    throw FormatException('Cannot parse complex number: $s');
  }
  
  static const Complex zero = Complex(0, 0);
  static const Complex one = Complex(1, 0);
  static const Complex i = Complex(0, 1);
  
  // Arithmetic
  Complex operator +(Complex other) => Complex(real + other.real, imaginary + other.imaginary);
  Complex operator -(Complex other) => Complex(real - other.real, imaginary - other.imaginary);
  Complex operator *(Complex other) => Complex(
    real * other.real - imaginary * other.imaginary,
    real * other.imaginary + imaginary * other.real,
  );
  
  Complex operator /(Complex other) {
    final denom = other.real * other.real + other.imaginary * other.imaginary;
    if (denom == 0) throw ArgumentError('Division by zero complex number');
    return Complex(
      (real * other.real + imaginary * other.imaginary) / denom,
      (imaginary * other.real - real * other.imaginary) / denom,
    );
  }
  
  Complex operator -() => Complex(-real, -imaginary);
  
  /// Conjugate
  Complex get conjugate => Complex(real, -imaginary);
  
  /// Modulus (absolute value)
  double get modulus => math.sqrt(real * real + imaginary * imaginary);
  
  /// Argument (angle in radians)
  double get argument => math.atan2(imaginary, real);
  
  /// Modulus squared (avoids sqrt)
  double get modulusSquared => real * real + imaginary * imaginary;
  
  /// Power: z^n using De Moivre's theorem
  Complex pow(double n) => Complex.fromPolar(math.pow(modulus, n).toDouble(), argument * n);
  
  /// Square root
  Complex get sqrt => Complex.fromPolar(math.sqrt(modulus), argument / 2);
  
  /// Exponential: e^z
  Complex get exp => Complex(
    math.exp(real) * math.cos(imaginary),
    math.exp(real) * math.sin(imaginary),
  );
  
  /// Natural logarithm
  Complex get ln => Complex(math.log(modulus), argument);
  
  /// Sine
  Complex get sin => Complex(
    math.sin(real) * _cosh(imaginary),
    math.cos(real) * _sinh(imaginary),
  );
  
  /// Cosine
  Complex get cos => Complex(
    math.cos(real) * _cosh(imaginary),
    -math.sin(real) * _sinh(imaginary),
  );
  
  /// Tangent
  Complex get tan => sin / cos;
  
  /// In polar form string
  String toPolarString() {
    final r = modulus;
    final theta = argument * 180 / math.pi;
    return '${r.toStringAsFixed(6)}∠${theta.toStringAsFixed(2)}°';
  }
  
  /// Is approximately real?
  bool get isReal => imaginary.abs() < 1e-10;
  
  /// Is approximately imaginary?
  bool get isImaginary => real.abs() < 1e-10;
  
  @override
  String toString() {
    if (isReal) return real.toStringAsFixed(6);
    if (isImaginary) {
      if (imaginary == 1) return 'i';
      if (imaginary == -1) return '-i';
      return '${imaginary.toStringAsFixed(6)}i';
    }
    final sign = imaginary >= 0 ? '+' : '-';
    return '${real.toStringAsFixed(6)} $sign ${imaginary.abs().toStringAsFixed(6)}i';
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Complex) return false;
    return (real - other.real).abs() < 1e-10 &&
           (imaginary - other.imaginary).abs() < 1e-10;
  }
  
  @override
  int get hashCode => Object.hash(real, imaginary);

  // Hyperbolic helpers (dart:math sinh/cosh not in Dart 3.3)
  static double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
  static double _cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;
}

/// Complex number functions
class ComplexFunctions {
  ComplexFunctions._();
  
  /// De Moivre's theorem: z^n = r^n (cos(nθ) + i·sin(nθ))
  static Complex deMoivre(Complex z, int n) {
    final r = z.modulus;
    final theta = z.argument;
    return Complex.fromPolar(math.pow(r, n).toDouble(), theta * n);
  }
  
  /// Roots of unity: n-th roots of z
  static List<Complex> roots(Complex z, int n) {
    final r = math.pow(z.modulus, 1.0 / n).toDouble();
    final theta = z.argument;
    return List.generate(n, (k) {
      return Complex.fromPolar(r, (theta + 2 * math.pi * k) / n);
    });
  }
  
  /// Euler's formula: e^(iθ) = cos(θ) + i·sin(θ)
  static Complex euler(double theta) {
    return Complex(math.cos(theta), math.sin(theta));
  }
  
  /// Convert rectangular to polar
  static (double r, double theta) toPolar(double real, double imag) {
    final r = math.sqrt(real * real + imag * imag);
    final theta = math.atan2(imag, real);
    return (r, theta);
  }
  
  /// Convert polar to rectangular
  static (double real, double imag) toRectangular(double r, double theta) {
    return (r * math.cos(theta), r * math.sin(theta));
  }
}
