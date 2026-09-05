/// Number base for programmer mode
enum NumberBase {
  binary('Binary', 'BIN', 2, '01'),
  octal('Octal', 'OCT', 8, '01234567'),
  decimal('Decimal', 'DEC', 10, '0123456789'),
  hexadecimal('Hexadecimal', 'HEX', 16, '0123456789ABCDEF');

  final String displayName;
  final String abbreviation;
  final int radix;
  final String validDigits;

  const NumberBase(this.displayName, this.abbreviation, this.radix, this.validDigits);

  /// Convert a value from decimal to this base
  static String fromDecimal(int value, NumberBase base) {
    if (value < 0) {
      return '-${fromDecimal(-value, base)}';
    }
    switch (base) {
      case NumberBase.binary:
        return value.toRadixString(2);
      case NumberBase.octal:
        return value.toRadixString(8);
      case NumberBase.decimal:
        return value.toString();
      case NumberBase.hexadecimal:
        return value.toRadixString(16).toUpperCase();
    }
  }

  /// Convert from this base to decimal
  static int toDecimal(String value, NumberBase base) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
    if (cleaned.isEmpty) return 0;
    return int.parse(cleaned, radix: base.radix);
  }
}
