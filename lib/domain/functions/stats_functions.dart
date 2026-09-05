import 'dart:math' as math;

/// Statistics and probability functions
class StatsFunctions {
  StatsFunctions._();
  
  // --- Descriptive Statistics ---
  
  static double mean(List<double> data) {
    if (data.isEmpty) throw ArgumentError('Cannot compute mean of empty dataset');
    return data.reduce((a, b) => a + b) / data.length;
  }
  
  static double median(List<double> data) {
    if (data.isEmpty) throw ArgumentError('Cannot compute median of empty dataset');
    final sorted = List<double>.from(data)..sort();
    final n = sorted.length;
    if (n.isOdd) return sorted[n ~/ 2];
    return (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2;
  }
  
  static List<double> mode(List<double> data) {
    if (data.isEmpty) throw ArgumentError('Cannot compute mode of empty dataset');
    final freq = <double, int>{};
    for (final value in data) {
      freq[value] = (freq[value] ?? 0) + 1;
    }
    final maxFreq = freq.values.reduce(math.max);
    return freq.entries
        .where((e) => e.value == maxFreq)
        .map((e) => e.key)
        .toList()
      ..sort();
  }
  
  static double variance(List<double> data, {bool population = false}) {
    if (data.length < 2 && !population) throw ArgumentError('Need at least 2 data points');
    if (data.isEmpty) throw ArgumentError('Cannot compute variance of empty dataset');
    
    final m = mean(data);
    final sumSqDiff = data.map((x) => (x - m) * (x - m)).reduce((a, b) => a + b);
    final divisor = population ? data.length : data.length - 1;
    return sumSqDiff / divisor;
  }
  
  static double stdDev(List<double> data, {bool population = false}) {
    return math.sqrt(variance(data, population: population));
  }
  
  static double min(List<double> data) {
    if (data.isEmpty) throw ArgumentError('Cannot compute min of empty dataset');
    return data.reduce(math.min);
  }
  
  static double max(List<double> data) {
    if (data.isEmpty) throw ArgumentError('Cannot compute max of empty dataset');
    return data.reduce(math.max);
  }
  
  static double range(List<double> data) {
    return max(data) - min(data);
  }
  
  static double q1(List<double> data) {
    final sorted = List<double>.from(data)..sort();
    return median(sorted.sublist(0, sorted.length ~/ 2));
  }
  
  static double q3(List<double> data) {
    final sorted = List<double>.from(data)..sort();
    final mid = sorted.length ~/ 2;
    return median(sorted.sublist(mid));
  }
  
  static double iqr(List<double> data) => q3(data) - q1(data);
  
  static double percentile(List<double> data, double p) {
    final sorted = List<double>.from(data)..sort();
    final index = (p / 100) * (sorted.length - 1);
    final lower = index.floor().clamp(0, sorted.length - 1);
    final upper = index.ceil().clamp(0, sorted.length - 1);
    final frac = index - index.floorToDouble();
    return sorted[lower] + frac * (sorted[upper] - sorted[lower]);
  }
  
  static double geometricMean(List<double> data) {
    if (data.isEmpty) throw ArgumentError('Cannot compute geometric mean of empty dataset');
    if (data.any((x) => x <= 0)) throw ArgumentError('All values must be positive');
    final logSum = data.map(math.log).reduce((a, b) => a + b);
    return math.exp(logSum / data.length);
  }
  
  static double harmonicMean(List<double> data) {
    if (data.isEmpty) throw ArgumentError('Cannot compute harmonic mean of empty dataset');
    if (data.any((x) => x <= 0)) throw ArgumentError('All values must be positive');
    final recipSum = data.map((x) => 1 / x).reduce((a, b) => a + b);
    return data.length / recipSum;
  }
  
  // --- 2-Variable Statistics ---
  
  static double covariance(List<double> x, List<double> y) {
    if (x.length != y.length) throw ArgumentError('Datasets must have same length');
    if (x.length < 2) throw ArgumentError('Need at least 2 data points');
    final mx = mean(x);
    final my = mean(y);
    double sum = 0;
    for (int i = 0; i < x.length; i++) {
      sum += (x[i] - mx) * (y[i] - my);
    }
    return sum / (x.length - 1);
  }
  
  static double correlation(List<double> x, List<double> y) {
    final cov = covariance(x, y);
    final sx = stdDev(x);
    final sy = stdDev(y);
    if (sx == 0 || sy == 0) return 0;
    return cov / (sx * sy);
  }
  
  static LinearRegression linearRegression(List<double> x, List<double> y) {
    if (x.length != y.length) throw ArgumentError('Datasets must have same length');
    if (x.length < 2) throw ArgumentError('Need at least 2 data points');
    
    final mx = mean(x);
    final my = mean(y);
    
    double sumXY = 0, sumX2 = 0;
    for (int i = 0; i < x.length; i++) {
      sumXY += (x[i] - mx) * (y[i] - my);
      sumX2 += (x[i] - mx) * (x[i] - mx);
    }
    
    if (sumX2 == 0) throw ArgumentError('x values have no variation');
    
    final slope = sumXY / sumX2;
    final intercept = my - slope * mx;
    
    return LinearRegression(slope, intercept);
  }
  
  static QuadraticRegression quadraticRegression(List<double> x, List<double> y) {
    if (x.length != y.length || x.length < 3) {
      throw ArgumentError('Need at least 3 data points');
    }
    
    final n = x.length;
    // Set up normal equations for quadratic fit y = a + bx + cx²
    double sum1 = 0, sumX = 0, sumX2 = 0, sumX3 = 0, sumX4 = 0;
    double sumY = 0, sumXY = 0, sumX2Y = 0;
    
    for (int i = 0; i < n; i++) {
      final xi = x[i];
      final yi = y[i];
      final x2 = xi * xi;
      sum1 += 1;
      sumX += xi;
      sumX2 += x2;
      sumX3 += x2 * xi;
      sumX4 += x2 * x2;
      sumY += yi;
      sumXY += xi * yi;
      sumX2Y += x2 * yi;
    }
    
    // Solve 3x3 system using Cramer's rule
    final det = sum1 * (sumX2 * sumX4 - sumX3 * sumX3) -
        sumX * (sumX * sumX4 - sumX3 * sumX2) +
        sumX2 * (sumX * sumX3 - sumX2 * sumX2);
    
    if (det.abs() < 1e-15) throw ArgumentError('Cannot fit quadratic regression');
    
    final a = (sumY * (sumX2 * sumX4 - sumX3 * sumX3) -
        sumX * (sumXY * sumX4 - sumX3 * sumX2Y) +
        sumX2 * (sumXY * sumX3 - sumX2 * sumX2Y)) / det;
    
    final b = (sum1 * (sumXY * sumX4 - sumX3 * sumX2Y) -
        sumY * (sumX * sumX4 - sumX3 * sumX2) +
        sumX2 * (sumX * sumX2Y - sumXY * sumX2)) / det;
    
    final c = (sum1 * (sumX2 * sumX2Y - sumXY * sumX3) -
        sumX * (sumX * sumX2Y - sumXY * sumX2) +
        sumY * (sumX * sumX3 - sumX2 * sumX2)) / det;
    
    return QuadraticRegression(a, b, c);
  }
  
  // --- Probability ---
  
  static double normalPDF(double x, {double mean = 0, double stdDev = 1}) {
    final coeff = 1 / (stdDev * math.sqrt(2 * math.pi));
    final exp = -0.5 * math.pow((x - mean) / stdDev, 2);
    return coeff * math.exp(exp);
  }
  
  static double normalCDF(double x, {double mean = 0, double stdDev = 1}) {
    return 0.5 * (1 + _erf((x - mean) / (stdDev * math.sqrt(2))));
  }
  
  static double normalInv(double p, {double mean = 0, double stdDev = 1}) {
    if (p <= 0 || p >= 1) throw ArgumentError('p must be in (0, 1)');
    // Rational approximation (Abramowitz & Stegun)
    final t = p < 0.5
        ? math.sqrt(-2 * math.log(p))
        : math.sqrt(-2 * math.log(1 - p));
    final c0 = 2.515517;
    final c1 = 0.802853;
    final c2 = 0.010328;
    final d1 = 1.432788;
    final d2 = 0.189269;
    final d3 = 0.001308;
    final z = t - (c0 + c1 * t + c2 * t * t) / (1 + d1 * t + d2 * t * t + d3 * t * t * t);
    return p < 0.5 ? -z * stdDev + mean : z * stdDev + mean;
  }
  
  static double binomialPMF(int k, int n, double p) {
    if (k < 0 || k > n) return 0;
    return _logBinomial(n, k) + k * math.log(p) + (n - k) * math.log(1 - p);
    // Actually:
    // return math.exp(_logBinomial(n, k) + k * math.log(p) + (n - k) * math.log(1 - p));
  }
  
  static double binomialCDF(int k, int n, double p) {
    double sum = 0;
    for (int i = 0; i <= k; i++) {
      sum += math.exp(_logBinomial(n, i) + i * math.log(p) + (n - i) * math.log(1 - p));
    }
    return sum;
  }
  
  static double poissonPMF(int k, double lambda) {
    if (k < 0 || lambda <= 0) return 0;
    return math.exp(k * math.log(lambda) - lambda - _logFactorial(k));
  }
  
  static double poissonCDF(int k, double lambda) {
    double sum = 0;
    for (int i = 0; i <= k; i++) {
      sum += math.exp(i * math.log(lambda) - lambda - _logFactorial(i));
    }
    return sum;
  }
  
  static double tPDF(double x, int df) {
    return math.exp(_logGamma((df + 1) / 2) - _logGamma(df / 2) -
        0.5 * math.log(df * math.pi) -
        (df + 1) / 2 * math.log(1 + x * x / df));
  }
  
  static double chiSquarePDF(double x, int df) {
    if (x <= 0) return 0;
    return math.exp((df / 2 - 1) * math.log(x) - x / 2 - 
        df / 2 * math.log(2) - _logGamma(df / 2));
  }
  
  /// p-value for t-test
  static double tTestPValue(double t, int df) {
    return 2 * (1 - studentTCDF(t.abs(), df));
  }
  
  /// Student's t CDF approximation
  static double studentTCDF(double t, int df) {
    final x = df / (df + t * t);
    return 1 - 0.5 * _incompleteBeta(df / 2.0, 0.5, x);
  }
  
  // --- Helpers ---
  
  static double _erf(double x) {
    final a1 = 0.254829592;
    final a2 = -0.284496736;
    final a3 = 1.421413741;
    final a4 = -1.453152027;
    final a5 = 1.061405429;
    final p = 0.3275911;
    
    final sign = x >= 0 ? 1 : -1;
    x = x.abs();
    
    final t = 1.0 / (1.0 + p * x);
    final y = 1.0 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * math.exp(-x * x);
    return sign * y;
  }
  
  static double _logBinomial(int n, int k) {
    return _logFactorial(n) - _logFactorial(k) - _logFactorial(n - k);
  }
  
  static double _logFactorial(int n) {
    if (n <= 1) return 0;
    return _logGamma(n + 1);
  }
  
  static double _logGamma(double x) {
    final c = [
      76.18009172947146, -86.50532032941677, 24.01409824083091,
      -1.231739572450155, 0.1208650973866179e-2, -0.5395239384953e-5,
    ];
    double y = x;
    double tmp = x + 5.5;
    tmp -= (x + 0.5) * math.log(tmp);
    double sum = 1.000000000190015;
    for (int j = 0; j < 6; j++) {
      sum += c[j] / ++y;
    }
    return -tmp + math.log(2.5066282746310005 * sum / x);
  }
  
  static double _incompleteBeta(double a, double b, double x) {
    // Simple numerical integration for incomplete beta
    final n = 200;
    final dx = x / n;
    double sum = 0;
    for (int i = 0; i < n; i++) {
      final t = (i + 0.5) * dx;
      sum += math.pow(t, a - 1) * math.pow(1 - t, b - 1) * dx;
    }
    return sum * math.exp(_logGamma(a + b) - _logGamma(a) - _logGamma(b));
  }
}

/// Linear regression result: y = slope * x + intercept
class LinearRegression {
  final double slope;
  final double intercept;
  
  const LinearRegression(this.slope, this.intercept);
  
  double predict(double x) => slope * x + intercept;
  
  @override
  String toString() => 'y = ${slope.toStringAsFixed(6)}x + ${intercept.toStringAsFixed(6)}';
}

/// Quadratic regression result: y = a + bx + cx²
class QuadraticRegression {
  final double a;
  final double b;
  final double c;
  
  const QuadraticRegression(this.a, this.b, this.c);
  
  double predict(double x) => a + b * x + c * x * x;
  
  @override
  String toString() => 'y = ${a.toStringAsFixed(6)} + ${b.toStringAsFixed(6)}x + ${c.toStringAsFixed(6)}x²';
}
