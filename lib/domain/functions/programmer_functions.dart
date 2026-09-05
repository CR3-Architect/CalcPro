import 'dart:typed_data';
import '../../core/enums/number_base.dart';

/// Programmer mode functions: bitwise operations, base conversion, IEEE 754
class ProgrammerFunctions {
  ProgrammerFunctions._();
  
  // --- Bitwise Operations ---
  
  static int bitwiseAnd(int a, int b) => a & b;
  
  static int bitwiseOr(int a, int b) => a | b;
  
  static int bitwiseXor(int a, int b) => a ^ b;
  
  static int bitwiseNot(int a) => ~a;
  
  static int bitwiseNand(int a, int b) => ~(a & b);
  
  static int bitwiseNor(int a, int b) => ~(a | b);
  
  static int shiftLeft(int a, int shift) => a << shift;
  
  static int shiftRight(int a, int shift) => a >> shift;
  
  /// Two's complement
  static int twosComplement(int value, {int bits = 8}) {
    final mask = (1 << bits) - 1;
    return (~value + 1) & mask;
  }
  
  /// One's complement
  static int onesComplement(int value, {int bits = 8}) {
    final mask = (1 << bits) - 1;
    return ~value & mask;
  }
  
  // --- Base Conversion ---
  
  static String convert(String value, NumberBase from, NumberBase to) {
    final decimalValue = NumberBase.toDecimal(value, from);
    return NumberBase.fromDecimal(decimalValue, to);
  }
  
  /// Convert string in given base to integer
  static int parseValue(String value, NumberBase base) {
    return NumberBase.toDecimal(value, base);
  }
  
  /// Format integer to given base string
  static String formatValue(int value, NumberBase base) {
    return NumberBase.fromDecimal(value, base);
  }
  
  // --- IEEE 754 ---
  
  /// IEEE 754 single precision (32-bit) representation
  static IEEE754 float32(double value) {
    final bytes = _floatToBytes(value, true);
    final bits = _bytesToUint32(bytes);
    
    final sign = (bits >> 31) & 1;
    final exponent = (bits >> 23) & 0xFF;
    final mantissa = bits & 0x7FFFFF;
    
    return IEEE754(
      value: value,
      sign: sign,
      exponent: exponent,
      mantissa: mantissa,
      bits: bits,
      hex: '0x${bits.toRadixString(16).toUpperCase().padLeft(8, '0')}',
      binary: _intToBinaryString(bits, 32),
      exponentBiased: exponent - 127,
    );
  }
  
  /// IEEE 754 double precision (64-bit) representation
  static IEEE754 float64(double value) {
    final bytes = _floatToBytes(value, false);
    final bits64 = _bytesToUint64(bytes);
    
    final sign = (bits64 >> 63) & 1;
    final exponent = (bits64 >> 52) & 0x7FF;
    final mantissa = bits64 & 0xFFFFFFFFFFFFF;
    
    return IEEE754(
      value: value,
      sign: sign,
      exponent: exponent,
      mantissa: mantissa,
      bits: bits64,
      hex: '0x${bits64.toRadixString(16).toUpperCase().padLeft(16, '0')}',
      binary: _intToBinaryString(bits64, 64),
      exponentBiased: exponent - 1023,
    );
  }
  
  /// Number of set bits (popcount)
  static int popcount(int value) {
    value = value & 0xFFFFFFFF;
    value = value - ((value >> 1) & 0x55555555);
    value = (value & 0x33333333) + ((value >> 2) & 0x33333333);
    value = (value + (value >> 4)) & 0x0F0F0F0F;
    value = value + (value >> 8);
    value = value + (value >> 16);
    return value & 0x3F;
  }
  
  /// Count trailing zeros
  static int ctz(int value) {
    if (value == 0) return 32;
    int n = 0;
    if ((value & 0xFFFFFFFF) == 0) { n += 32; value >>= 32; }
    if ((value & 0xFFFF) == 0) { n += 16; value >>= 16; }
    if ((value & 0xFF) == 0) { n += 8; value >>= 8; }
    if ((value & 0xF) == 0) { n += 4; value >>= 4; }
    if ((value & 0x3) == 0) { n += 2; value >>= 2; }
    if ((value & 0x1) == 0) { n += 1; }
    return n;
  }
  
  /// Count leading zeros
  static int clz(int value) {
    if (value == 0) return 32;
    int n = 0;
    if ((value & 0xFFFF0000) == 0) { n += 16; value <<= 16; }
    if ((value & 0xFF000000) == 0) { n += 8; value <<= 8; }
    if ((value & 0xF0000000) == 0) { n += 4; value <<= 4; }
    if ((value & 0xC0000000) == 0) { n += 2; value <<= 2; }
    if ((value & 0x80000000) == 0) { n += 1; }
    return n;
  }
  
  // --- Internal helpers ---
  
  static List<int> _floatToBytes(double value, bool single) {
    if (single) {
      final bd = ByteData(4)..setFloat32(0, value);
      return List<int>.generate(4, (i) => bd.getUint8(i));
    } else {
      final bd = ByteData(8)..setFloat64(0, value);
      return List<int>.generate(8, (i) => bd.getUint8(i));
    }
  }
  
  static int _bytesToUint32(List<int> bytes) {
    return (bytes[0] & 0xFF) |
        ((bytes[1] & 0xFF) << 8) |
        ((bytes[2] & 0xFF) << 16) |
        ((bytes[3] & 0xFF) << 24);
  }
  
  static int _bytesToUint64(List<int> bytes) {
    int result = 0;
    for (int i = 0; i < 8; i++) {
      result |= (bytes[i] & 0xFF).toUnsigned(8) << (i * 8);
    }
    return result;
  }
  
  static String _intToBinaryString(int value, int bits) {
    final buffer = StringBuffer();
    for (int i = bits - 1; i >= 0; i--) {
      buffer.write((value >> i) & 1);
      if (i > 0 && i % 4 == 0) buffer.write(' ');
    }
    return buffer.toString();
  }
}

/// IEEE 754 floating point representation
class IEEE754 {
  final double value;
  final int sign;
  final int exponent;
  final int mantissa;
  final int bits;
  final String hex;
  final String binary;
  final int exponentBiased;
  
  const IEEE754({
    required this.value,
    required this.sign,
    required this.exponent,
    required this.mantissa,
    required this.bits,
    required this.hex,
    required this.binary,
    required this.exponentBiased,
  });
  
  String get signBit => sign == 0 ? '+' : '-';
  
  @override
  String toString() => '''
Value: $value
Sign: $signBit (${sign})
Exponent: $exponent ($exponentBiased)
Mantissa: 0x${mantissa.toRadixString(16).toUpperCase()}
Hex: $hex
Binary: $binary
''';
}
