import '../../core/enums/angle_mode.dart';
import '../../core/enums/calc_mode.dart';
import '../../core/enums/number_base.dart';
import '../../domain/models/calculation_entry.dart';

/// Calculator state
class CalculatorState {
  final String expression;
  final String displayExpression;
  final String result;
  final String error;
  final CalcMode mode;
  final AngleMode angleMode;
  final NumberBase numberBase;
  final bool isDegree;
  final bool highContrastMode;
  final int precision;
  final bool hapticFeedback;
  final List<double> memory;
  final List<CalculationEntry> history;
  final List<String> undoStack;
  final List<String> redoStack;
  final int themeIndex;
  
  const CalculatorState({
    this.expression = '',
    this.displayExpression = '',
    this.result = '',
    this.error = '',
    this.mode = CalcMode.standard,
    this.angleMode = AngleMode.degree,
    this.numberBase = NumberBase.decimal,
    this.isDegree = true,
    this.highContrastMode = false,
    this.precision = 10,
    this.hapticFeedback = true,
    this.memory = const [0, 0, 0, 0, 0],
    this.history = const [],
    this.undoStack = const [],
    this.redoStack = const [],
    this.themeIndex = 0,
  });
  
  CalculatorState copyWith({
    String? expression,
    String? displayExpression,
    String? result,
    String? error,
    CalcMode? mode,
    AngleMode? angleMode,
    NumberBase? numberBase,
    bool? isDegree,
    bool? highContrastMode,
    int? precision,
    bool? hapticFeedback,
    List<double>? memory,
    List<CalculationEntry>? history,
    List<String>? undoStack,
    List<String>? redoStack,
    int? themeIndex,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      displayExpression: displayExpression ?? this.displayExpression,
      result: result ?? this.result,
      error: error ?? this.error,
      mode: mode ?? this.mode,
      angleMode: angleMode ?? this.angleMode,
      numberBase: numberBase ?? this.numberBase,
      isDegree: isDegree ?? this.isDegree,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      precision: precision ?? this.precision,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      memory: memory ?? this.memory,
      history: history ?? this.history,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
      themeIndex: themeIndex ?? this.themeIndex,
    );
  }
  
  bool get hasExpression => expression.isNotEmpty;
  bool get hasResult => result.isNotEmpty;
  bool get canUndo => undoStack.isNotEmpty;
  bool get canRedo => redoStack.isNotEmpty;
  
  /// Get formatted result based on precision
  String get formattedResult {
    if (result.isEmpty) return '';
    final value = double.tryParse(result);
    if (value == null) return result;
    
    if (precision == 0 || precision >= 10) {
      return _formatAuto(value);
    }
    
    return value.toStringAsFixed(precision);
  }
  
  String _formatAuto(double value) {
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';
    if (value == 0) return '0';
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    if (value.abs() >= 1e15 || (value.abs() < 1e-6 && value != 0)) {
      return value.toStringAsExponential(6);
    }
    return value.toStringAsFixed(10).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  
  @override
  String toString() => 'CalculatorState(expression: $expression, result: $result, mode: $mode)';
}
