import 'dart:convert';

/// A single calculation history entry
class CalculationEntry {
  final String id;
  final String expression;
  final String result;
  final DateTime timestamp;
  final String mode;
  final bool isFavorite;
  
  const CalculationEntry({
    required this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
    this.mode = 'Standard',
    this.isFavorite = false,
  });
  
  CalculationEntry copyWith({
    String? expression,
    String? result,
    DateTime? timestamp,
    String? mode,
    bool? isFavorite,
  }) {
    return CalculationEntry(
      id: id,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
      mode: mode ?? this.mode,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
  
  /// Serialize to JSON map
  Map<String, dynamic> toJson() => {
    'id': id,
    'expression': expression,
    'result': result,
    'timestamp': timestamp.toIso8601String(),
    'mode': mode,
    'isFavorite': isFavorite,
  };
  
  /// Deserialize from JSON map
  factory CalculationEntry.fromJson(Map<String, dynamic> json) {
    return CalculationEntry(
      id: json['id'] as String,
      expression: json['expression'] as String,
      result: json['result'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      mode: json['mode'] as String? ?? 'Standard',
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
  
  /// Serialize to JSON string
  String toJsonString() => jsonEncode(toJson());
  
  /// Deserialize from JSON string
  factory CalculationEntry.fromJsonString(String jsonString) {
    return CalculationEntry.fromJson(jsonDecode(jsonString));
  }
  
  @override
  String toString() => '$expression = $result';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CalculationEntry && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
