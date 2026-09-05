/// Angle mode for trigonometric calculations
enum AngleMode {
  degree('Degree', '°', 'deg'),
  radian('Radian', 'rad', 'rad'),
  gradian('Gradian', 'grad', 'grad');

  final String displayName;
  final String symbol;
  final String code;

  const AngleMode(this.displayName, this.symbol, this.code);

  /// Convert the given angle (in this mode) to radians
  double toRadians(double angle) {
    switch (this) {
      case AngleMode.degree:
        return angle * (3.141592653589793 / 180.0);
      case AngleMode.radian:
        return angle;
      case AngleMode.gradian:
        return angle * (3.141592653589793 / 200.0);
    }
  }

  /// Convert radians to this angle mode
  double fromRadians(double radians) {
    switch (this) {
      case AngleMode.degree:
        return radians * (180.0 / 3.141592653589793);
      case AngleMode.radian:
        return radians;
      case AngleMode.gradian:
        return radians * (200.0 / 3.141592653589793);
    }
  }
}
